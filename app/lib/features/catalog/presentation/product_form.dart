import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/catalog_writes.dart';
import 'package:bakery_pos/core/api/generated/models/branch.dart';
import 'package:bakery_pos/core/api/generated/models/branch_price_set.dart';
import 'package:bakery_pos/core/api/generated/models/product.dart';
import 'package:bakery_pos/core/api/generated/models/product_create.dart';
import 'package:bakery_pos/core/api/generated/models/product_unit.dart';
import 'package:bakery_pos/core/api/generated/models/tax_kind.dart';
import 'package:bakery_pos/core/api/generated/models/tax_rate.dart';
import 'package:bakery_pos/core/api/generated/models/variant.dart';
import 'package:bakery_pos/core/api/generated/models/variant_create.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/money/tax_split.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/catalog/data/catalog_admin_service.dart';
import 'package:bakery_pos/features/catalog/presentation/catalog_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One editable variant row. [original] is null for a new row.
class _VariantRow {
  _VariantRow([this.original])
    : name = TextEditingController(text: original?.name),
      price = TextEditingController(
        text: original == null ? '' : centsToInput(original.priceCents),
      ),
      sku = TextEditingController(text: original?.sku),
      barcode = TextEditingController(text: original?.barcode),
      cost = TextEditingController(
        text: original?.costCents == null
            ? ''
            : centsToInput(original!.costCents!),
      ),
      tray = TextEditingController(text: original?.unitsPerTray?.toString());

  final Variant? original;
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController sku;
  final TextEditingController barcode;
  final TextEditingController cost;
  final TextEditingController tray;
  final branchPrices = <String, TextEditingController>{};

  TextEditingController branchPrice(String branchId) =>
      branchPrices.putIfAbsent(branchId, () {
        final bp = original?.branchPrices
            .where((b) => b.branchId == branchId)
            .firstOrNull;
        return TextEditingController(
          text: bp == null ? '' : centsToInput(bp.priceCents),
        );
      });

  void dispose() {
    for (final c in [
      name,
      price,
      sku,
      barcode,
      cost,
      tray,
      ...branchPrices.values,
    ]) {
      c.dispose();
    }
  }
}

String? _blankToNull(String s) => s.trim().isEmpty ? null : s.trim();

/// Create or edit a product with its variants, photo, taxes, day-old rule and
/// branch prices, all in one dialog (M2 brief 4.1).
class ProductFormDialog extends ConsumerStatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _form = GlobalKey<FormState>();
  late final Product? _p = widget.product;
  late final _name = TextEditingController(text: _p?.name);
  late final _description = TextEditingController(text: _p?.description);
  late final _discountDays = TextEditingController(
    text: _p?.dayOldDiscountAfterDays?.toString(),
  );
  late final _discountPercent = TextEditingController(
    text: _p?.dayOldDiscountBp == null
        ? ''
        : formatBasisPoints(_p!.dayOldDiscountBp!),
  );
  late final _wasteDays = TextEditingController(
    text: _p?.dayOldWasteAfterDays?.toString(),
  );
  late String? _categoryId = _p?.categoryId;
  late ProductUnit _unit = _p?.unit ?? ProductUnit.piece;
  late String? _ivaId = _p?.ivaRateId;
  late String? _iepsId = _p?.iepsRateId;
  late bool _active = _p?.isActive ?? true;
  late String? _photoId = _p?.photoId;
  PickedPhoto? _picked;
  late final List<_VariantRow> _rows = _p == null
      ? [_VariantRow()]
      : [
          for (final v in _p.variants)
            if (v.isActive) _VariantRow(v),
        ];
  final _removed = <Variant>[];
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _description,
      _discountDays,
      _discountPercent,
      _wasteDays,
    ]) {
      c.dispose();
    }
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  int? _int(TextEditingController c) =>
      c.text.trim().isEmpty ? null : int.tryParse(c.text.trim());

  /// Day-old rule as the contract wants it, or a message for the form.
  ({int? days, int? bp, int? waste, String? error}) _dayOld(
    AppLocalizations l10n,
  ) {
    final days = _int(_discountDays);
    final bp = _discountPercent.text.trim().isEmpty
        ? null
        : parsePercentBp(_discountPercent.text);
    final waste = _int(_wasteDays);
    String? error;
    if ((days == null) != (bp == null)) error = l10n.catalogDayOldPair;
    if (days != null && waste != null && waste <= days) {
      error = l10n.catalogDayOldWasteAfter;
    }
    return (days: days, bp: bp, waste: waste, error: error);
  }

  String _conflictMessage(AppLocalizations l10n, Object e) {
    if (apiErrorCode(e) != 'CONFLICT') return commonAdminError(l10n, e);
    final data = e is DioException ? e.response?.data : null;
    final field = data is Map && data['details'] is Map
        ? (data['details'] as Map)['field']
        : null;
    return switch (field) {
      'sku' => l10n.catalogSkuInUse,
      'barcode' => l10n.catalogBarcodeInUse,
      _ => l10n.catalogNeedsActiveVariant,
    };
  }

  Future<void> _pickPhoto() async {
    final photo = await ref.read(photoPickerProvider)();
    if (photo != null) setState(() => _picked = photo);
  }

  Future<void> _save(List<Branch> branches) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    if (_rows.isEmpty) return setState(() => _error = l10n.catalogNeedsVariant);
    final dayOld = _dayOld(l10n);
    if (dayOld.error != null) return setState(() => _error = dayOld.error);

    setState(() => _saving = true);
    final api = ref.read(restClientProvider).catalog;
    final writes = ref.read(catalogWritesProvider);
    try {
      var photoId = _photoId;
      if (_picked != null) {
        try {
          photoId = (await writes.uploadPhoto(
            _picked!.bytes,
            _picked!.name,
          )).id;
        } catch (_) {
          setState(() {
            _saving = false;
            _error = l10n.catalogPhotoUploadFailed;
          });
          return;
        }
      }
      final fields = <String, Object?>{
        'categoryId': _categoryId,
        'name': _name.text.trim(),
        'description': _blankToNull(_description.text),
        'unit': _unit.json,
        'photoId': photoId,
        'ivaRateId': _ivaId,
        'iepsRateId': _iepsId,
        'dayOldDiscountAfterDays': dayOld.days,
        'dayOldDiscountBp': dayOld.bp,
        'dayOldWasteAfterDays': dayOld.waste,
      };

      final saved = <(_VariantRow, String)>[];
      final p = _p;
      if (p == null) {
        final created = await api.createProduct(
          body: ProductCreate(
            categoryId: _categoryId!,
            name: _name.text.trim(),
            description: _blankToNull(_description.text),
            unit: _unit,
            photoId: photoId,
            ivaRateId: _ivaId!,
            iepsRateId: _iepsId,
            dayOldDiscountAfterDays: dayOld.days,
            dayOldDiscountBp: dayOld.bp,
            dayOldWasteAfterDays: dayOld.waste,
            variants: [
              for (final (i, r) in _rows.indexed)
                VariantCreate(
                  name: r.name.text.trim(),
                  priceCents: parseCents(r.price.text)!,
                  sku: _blankToNull(r.sku.text),
                  barcode: _blankToNull(r.barcode.text),
                  sortOrder: i,
                ),
            ],
          ),
        );
        for (final (i, v) in created.variants.indexed) {
          saved.add((_rows[i], v.id));
        }
      } else {
        // New variants first, so the product never drops to zero active ones.
        for (final (i, r) in _rows.indexed) {
          final body = <String, Object?>{
            'name': r.name.text.trim(),
            'priceCents': parseCents(r.price.text),
            'sku': _blankToNull(r.sku.text),
            'barcode': _blankToNull(r.barcode.text),
            'sortOrder': i,
          };
          final original = r.original;
          if (original == null) {
            final v = await api.createVariant(
              productId: p.id,
              body: VariantCreate(
                name: body['name']! as String,
                priceCents: body['priceCents']! as int,
                sku: body['sku'] as String?,
                barcode: body['barcode'] as String?,
                sortOrder: i,
              ),
            );
            saved.add((r, v.id));
          } else {
            await writes.patchVariant(original.id, {
              ...body,
              'costCents': parseCents(r.cost.text),
              'unitsPerTray': int.tryParse(r.tray.text),
            });
            saved.add((r, original.id));
          }
        }
        for (final v in _removed) {
          await writes.patchVariant(v.id, {'isActive': false});
        }
        await writes.patchProduct(p.id, {...fields, 'isActive': _active});
      }

      for (final (row, variantId) in saved) {
        for (final b in branches) {
          final text = row.branchPrice(b.id).text;
          final had =
              row.original?.branchPrices.any((x) => x.branchId == b.id) ??
              false;
          final cents = parseCents(text);
          if (cents != null) {
            await api.setBranchPrice(
              variantId: variantId,
              branchId: b.id,
              body: BranchPriceSet(priceCents: cents),
            );
          } else if (had) {
            await api.removeBranchPrice(variantId: variantId, branchId: b.id);
          }
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = _conflictMessage(l10n, e);
      });
    }
  }

  String? _priceValidator(
    String? v,
    AppLocalizations l10n, {
    bool optional = false,
  }) {
    if (optional && (v ?? '').trim().isEmpty) return null;
    final c = parseCents(v ?? '');
    return c == null || c <= 0 ? l10n.catalogPriceInvalid : null;
  }

  Widget _photo(AppLocalizations l10n) {
    final baseUrl = ref.watch(serverBaseUrlProvider);
    final Widget preview;
    if (_picked != null) {
      preview = Image.memory(_picked!.bytes, fit: BoxFit.cover);
    } else if (_photoId != null) {
      preview = Image.network(
        photoUrl(baseUrl, _photoId!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
      );
    } else {
      preview = Center(child: Text(l10n.catalogPhotoNone));
    }
    return Row(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: preview,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Flexible(
          child: Wrap(
            spacing: AppDimensions.paddingSmall,
            children: [
              OutlinedButton.icon(
                key: const Key('photo-choose-button'),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.catalogPhotoChoose),
                onPressed: _pickPhoto,
              ),
              if (_picked != null || _photoId != null)
                TextButton(
                  key: const Key('photo-remove-button'),
                  onPressed: () => setState(() {
                    _picked = null;
                    _photoId = null;
                  }),
                  child: Text(l10n.catalogPhotoRemove),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _variantRow(
    AppLocalizations l10n,
    _VariantRow r,
    List<Branch> branches,
    int ivaBp,
    int iepsBp,
  ) {
    final cents = parseCents(r.price.text);
    final split = cents == null ? null : splitTax(cents, ivaBp, iepsBp);
    final index = _rows.indexOf(r);
    Widget field(
      TextEditingController c,
      String label,
      String key, {
      String? Function(String?)? validator,
      bool money = false,
      String? hint,
    }) => SizedBox(
      width: 150,
      child: TextFormField(
        key: Key('$key-$index'),
        controller: c,
        validator: validator,
        keyboardType: money
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onChanged: money ? (_) => setState(() {}) : null,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppDimensions.paddingSmall,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                field(
                  r.name,
                  l10n.catalogVariantName,
                  'variant-name',
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? l10n.catalogRequired : null,
                ),
                field(
                  r.price,
                  l10n.catalogVariantPrice,
                  'variant-price',
                  money: true,
                  validator: (v) => _priceValidator(v, l10n),
                ),
                field(r.sku, l10n.catalogVariantSku, 'variant-sku'),
                field(r.barcode, l10n.catalogVariantBarcode, 'variant-barcode'),
                if (r.original != null) ...[
                  field(
                    r.cost,
                    l10n.catalogVariantCost,
                    'variant-cost',
                    money: true,
                    validator: (v) => _priceValidator(v, l10n, optional: true),
                  ),
                  field(r.tray, l10n.catalogVariantTray, 'variant-tray'),
                ],
                for (final b in branches)
                  field(
                    r.branchPrice(b.id),
                    l10n.catalogBranchPrice(b.code),
                    'variant-branch-${b.code}',
                    money: true,
                    hint: l10n.catalogBranchPriceHint,
                    validator: (v) => _priceValidator(v, l10n, optional: true),
                  ),
                IconButton(
                  key: Key('variant-remove-$index'),
                  tooltip: l10n.catalogRemoveVariant,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() {
                    _rows.remove(r);
                    if (r.original != null) _removed.add(r.original!);
                  }),
                ),
              ],
            ),
            if (split != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
                child: Text(
                  l10n.catalogTaxSplit(
                    formatCents(split.baseCents),
                    formatCents(split.iepsCents),
                    formatCents(split.ivaCents),
                  ),
                  key: Key('variant-split-$index'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lists = [
      ref.watch(taxRatesProvider),
      ref.watch(adminCategoriesProvider),
      ref.watch(branchesServiceProvider),
    ];
    // Selects need their options before they can show a saved value.
    if (lists.any((l) => !l.hasValue)) {
      return AlertDialog(
        content: SizedBox(
          height: 120,
          child: Center(
            child: lists.any((l) => l.hasError)
                ? Text(l10n.catalogErrorLoading)
                : const CircularProgressIndicator(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
        ],
      );
    }
    final rates = ref.watch(taxRatesProvider).value ?? const <TaxRate>[];
    final categories = ref.watch(adminCategoriesProvider).value ?? const [];
    final branches =
        (ref.watch(branchesServiceProvider).value ?? const <Branch>[])
            .where((b) => b.isActive)
            .toList();
    // Inactive choices stay listed only when this product already uses them.
    bool usable(bool active, String id, String? current) =>
        active || id == current;
    final ivas = rates.where(
      (t) => t.kind == TaxKind.iva && usable(t.isActive, t.id, _ivaId),
    );
    final iepss = rates.where(
      (t) => t.kind == TaxKind.ieps && usable(t.isActive, t.id, _iepsId),
    );
    int bpOf(String? id) =>
        rates.where((t) => t.id == id).firstOrNull?.rateBp ?? 0;
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return AlertDialog(
      title: Text(
        _p == null ? l10n.catalogNewProduct : l10n.catalogEditProduct,
      ),
      content: SizedBox(
        width: 880,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) AdminErrorBanner(message: _error!),
                _photo(l10n),
                const SizedBox(height: AppDimensions.paddingMedium),
                Wrap(
                  spacing: AppDimensions.paddingMedium,
                  runSpacing: AppDimensions.paddingSmall,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        key: const Key('product-name-field'),
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: l10n.catalogProductName,
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.catalogRequired
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        key: const Key('product-category-field'),
                        isExpanded: true,
                        initialValue: _categoryId,
                        decoration: InputDecoration(
                          labelText: l10n.catalogProductCategory,
                        ),
                        items: [
                          for (final c in categories)
                            if (usable(c.isActive, c.id, _categoryId))
                              DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                        ],
                        validator: (v) =>
                            v == null ? l10n.catalogRequired : null,
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<ProductUnit>(
                        key: const Key('product-unit-field'),
                        isExpanded: true,
                        initialValue: _unit,
                        decoration: InputDecoration(
                          labelText: l10n.catalogProductUnit,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: ProductUnit.piece,
                            child: Text(l10n.catalogUnitPiece),
                          ),
                          DropdownMenuItem(
                            value: ProductUnit.kg,
                            child: Text(l10n.catalogUnitKg),
                          ),
                          DropdownMenuItem(
                            value: ProductUnit.package,
                            child: Text(l10n.catalogUnitPackage),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _unit = v ?? ProductUnit.piece),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        key: const Key('product-iva-field'),
                        isExpanded: true,
                        initialValue: _ivaId,
                        decoration: InputDecoration(labelText: l10n.catalogIva),
                        items: [
                          for (final t in ivas)
                            DropdownMenuItem(value: t.id, child: Text(t.name)),
                        ],
                        validator: (v) =>
                            v == null ? l10n.catalogRequired : null,
                        onChanged: (v) => setState(() => _ivaId = v),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String?>(
                        key: const Key('product-ieps-field'),
                        isExpanded: true,
                        initialValue: _iepsId,
                        decoration: InputDecoration(
                          labelText: l10n.catalogIeps,
                        ),
                        items: [
                          DropdownMenuItem(child: Text(l10n.catalogNoIeps)),
                          for (final t in iepss)
                            DropdownMenuItem(value: t.id, child: Text(t.name)),
                        ],
                        onChanged: (v) => setState(() => _iepsId = v),
                      ),
                    ),
                    if (_p != null)
                      SizedBox(
                        width: 200,
                        child: SwitchListTile(
                          key: const Key('product-active-switch'),
                          title: Text(l10n.catalogActive),
                          value: _active,
                          onChanged: (v) => setState(() => _active = v),
                        ),
                      ),
                  ],
                ),
                TextFormField(
                  key: const Key('product-description-field'),
                  controller: _description,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.catalogProductDescription,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  l10n.catalogDayOld,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Wrap(
                  spacing: AppDimensions.paddingMedium,
                  children: [
                    for (final (c, label, key) in [
                      (
                        _discountDays,
                        l10n.catalogDayOldDiscountDays,
                        'dayold-days',
                      ),
                      (
                        _discountPercent,
                        l10n.catalogDayOldDiscountPercent,
                        'dayold-percent',
                      ),
                      (_wasteDays, l10n.catalogDayOldWasteDays, 'dayold-waste'),
                    ])
                      SizedBox(
                        width: 220,
                        child: TextFormField(
                          key: Key(key),
                          controller: c,
                          inputFormatters: key == 'dayold-percent'
                              ? null
                              : digits,
                          decoration: InputDecoration(labelText: label),
                          validator: (v) =>
                              key == 'dayold-percent' &&
                                  (v ?? '').trim().isNotEmpty &&
                                  (parsePercentBp(v!) ?? 0) < 1
                              ? l10n.catalogTaxRateInvalid
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  l10n.catalogVariants,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                for (final r in _rows)
                  _variantRow(l10n, r, branches, bpOf(_ivaId), bpOf(_iepsId)),
                TextButton.icon(
                  key: const Key('add-variant-button'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.catalogAddVariant),
                  onPressed: () => setState(() => _rows.add(_VariantRow())),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('product-save-button'),
          onPressed: _saving ? null : () => _save(branches),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
