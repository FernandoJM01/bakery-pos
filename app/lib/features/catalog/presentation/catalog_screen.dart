import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/category.dart';
import 'package:bakery_pos/core/api/generated/models/category_create.dart';
import 'package:bakery_pos/core/api/generated/models/category_update.dart';
import 'package:bakery_pos/core/api/generated/models/product.dart';
import 'package:bakery_pos/core/api/generated/models/tax_kind.dart';
import 'package:bakery_pos/core/api/generated/models/tax_rate.dart';
import 'package:bakery_pos/core/api/generated/models/tax_rate_create.dart';
import 'package:bakery_pos/core/api/generated/models/tax_rate_update.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/catalog/data/catalog_admin_service.dart';
import 'package:bakery_pos/features/catalog/presentation/product_form.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Back office Catálogo: products, categories and tax rates (M2 brief 5).
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.catalogTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                key: const Key('tab-products'),
                text: l10n.catalogTabProducts,
              ),
              Tab(
                key: const Key('tab-categories'),
                text: l10n.catalogTabCategories,
              ),
              Tab(key: const Key('tab-taxes'), text: l10n.catalogTabTaxes),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ProductsTab(), _CategoriesTab(), _TaxRatesTab()],
        ),
      ),
    );
  }
}

Color? parseHexColor(String? hex) {
  if (hex == null || hex.length != 7) return null;
  final v = int.tryParse(hex.substring(1), radix: 16);
  return v == null ? null : Color(0xFF000000 | v);
}

Widget _loadError(BuildContext context, VoidCallback retry) {
  final l10n = AppLocalizations.of(context)!;
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.catalogErrorLoading,
          style: const TextStyle(color: AppColors.alertRed),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        ElevatedButton(onPressed: retry, child: Text(l10n.commonRetry)),
      ],
    ),
  );
}

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    Product? p,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(product: p),
    );
    if (saved == true && context.mounted) {
      ref.invalidate(adminProductsProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.catalogSaved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(productFilterProvider);
    final categories = ref.watch(adminCategoriesProvider).value ?? const [];
    final products = ref.watch(adminProductsProvider);
    final names = {for (final c in categories) c.id: c.name};

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Wrap(
            spacing: AppDimensions.paddingMedium,
            runSpacing: AppDimensions.paddingSmall,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 360,
                child: TextField(
                  key: const Key('product-search'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.catalogSearchHint,
                  ),
                  onChanged: (v) =>
                      ref.read(productFilterProvider.notifier).set(q: v),
                ),
              ),
              SizedBox(
                width: 240,
                child: DropdownButton<String?>(
                  key: const Key('product-category-filter'),
                  isExpanded: true,
                  value: filter.categoryId,
                  items: [
                    DropdownMenuItem(child: Text(l10n.catalogAllCategories)),
                    for (final c in categories)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => ref
                      .read(productFilterProvider.notifier)
                      .set(categoryId: v, clearCategory: v == null),
                ),
              ),
              FilterChip(
                key: const Key('product-inactive-filter'),
                label: Text(l10n.catalogShowInactive),
                selected: filter.includeInactive,
                onSelected: (v) => ref
                    .read(productFilterProvider.notifier)
                    .set(includeInactive: v),
              ),
              ElevatedButton.icon(
                key: const Key('create-product-button'),
                icon: const Icon(Icons.add),
                label: Text(l10n.catalogNewProduct),
                onPressed: () => _openForm(context, ref, null),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _loadError(
                context,
                () => ref.invalidate(adminProductsProvider),
              ),
              data: (list) => list.isEmpty
                  ? Center(child: Text(l10n.catalogNoProducts))
                  : ListView.separated(
                      key: const Key('products-list'),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final p = list[i];
                        final prices = p.variants.map((v) => v.priceCents);
                        final low = prices.isEmpty
                            ? 0
                            : prices.reduce((a, b) => a < b ? a : b);
                        final high = prices.isEmpty
                            ? 0
                            : prices.reduce((a, b) => a > b ? a : b);
                        return ListTile(
                          key: Key('product-row-${p.id}'),
                          title: Text(p.name),
                          subtitle: Text(
                            l10n.catalogProductSubtitle(
                              names[p.categoryId] ?? '',
                              l10n.catalogVariantCount(p.variants.length),
                            ),
                          ),
                          trailing: Wrap(
                            spacing: AppDimensions.paddingSmall,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (!p.isActive)
                                Chip(label: Text(l10n.catalogInactive)),
                              Text(
                                low == high
                                    ? formatCents(low)
                                    : '${formatCents(low)} – ${formatCents(high)}',
                              ),
                            ],
                          ),
                          onTap: () => _openForm(context, ref, p),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    Category c,
    CategoryUpdate body,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(restClientProvider)
          .catalog
          .updateCategory(categoryId: c.id, body: body);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(commonAdminError(l10n, e))));
      }
    }
    ref.invalidate(adminCategoriesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(adminCategoriesProvider);
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            key: const Key('create-category-button'),
            icon: const Icon(Icons.add),
            label: Text(l10n.catalogNewCategory),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const CategoryDialog(),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _loadError(
                context,
                () => ref.invalidate(adminCategoriesProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(l10n.catalogNoCategories));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final c = list[i];
                    // Moving swaps sort orders with the neighbour.
                    Future<void> swap(int j) async {
                      final other = list[j];
                      await _update(
                        context,
                        ref,
                        c,
                        CategoryUpdate(sortOrder: other.sortOrder),
                      );
                      if (context.mounted) {
                        await _update(
                          context,
                          ref,
                          other,
                          CategoryUpdate(sortOrder: c.sortOrder),
                        );
                      }
                    }

                    return ListTile(
                      key: Key('category-row-${c.id}'),
                      leading: CircleAvatar(
                        backgroundColor:
                            parseHexColor(c.color) ??
                            AppColors.surfaceHighlight,
                      ),
                      title: Text(c.name),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => CategoryDialog(category: c),
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            tooltip: l10n.catalogMoveUp,
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: i == 0 ? null : () => swap(i - 1),
                          ),
                          IconButton(
                            tooltip: l10n.catalogMoveDown,
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: i == list.length - 1
                                ? null
                                : () => swap(i + 1),
                          ),
                          Text(l10n.catalogActive),
                          Switch(
                            key: Key('category-active-${c.id}'),
                            value: c.isActive,
                            onChanged: (v) => _update(
                              context,
                              ref,
                              c,
                              CategoryUpdate(isActive: v),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Bakery-friendly swatches; the contract accepts any `#RRGGBB`.
const _swatches = [
  '#C46A2B',
  '#E0A84F',
  '#8B5A3C',
  '#D9534F',
  '#6B8E23',
  '#4A7BA7',
  '#9B59B6',
];

class CategoryDialog extends ConsumerStatefulWidget {
  const CategoryDialog({super.key, this.category});

  final Category? category;

  @override
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  late final _name = TextEditingController(text: widget.category?.name);
  late String? _color = widget.category?.color ?? _swatches.first;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = l10n.catalogRequired);
    setState(() => _saving = true);
    final api = ref.read(restClientProvider).catalog;
    try {
      final c = widget.category;
      if (c == null) {
        await api.createCategory(
          body: CategoryCreate(name: name, color: _color),
        );
      } else {
        await api.updateCategory(
          categoryId: c.id,
          body: CategoryUpdate(name: name, color: _color),
        );
      }
      ref.invalidate(adminCategoriesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = apiErrorCode(e) == 'CONFLICT'
            ? l10n.catalogNameInUse
            : commonAdminError(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.category == null
            ? l10n.catalogNewCategory
            : l10n.catalogEditCategory,
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) AdminErrorBanner(message: _error!),
            TextField(
              key: const Key('category-name-field'),
              controller: _name,
              decoration: InputDecoration(labelText: l10n.catalogCategoryName),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(l10n.catalogCategoryColor),
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              children: [
                for (final hex in _swatches)
                  ChoiceChip(
                    key: Key('swatch-$hex'),
                    label: const SizedBox(width: 16, height: 16),
                    avatar: CircleAvatar(backgroundColor: parseHexColor(hex)),
                    selected: _color == hex,
                    onSelected: (_) => setState(() => _color = hex),
                  ),
                ChoiceChip(
                  label: Text(l10n.catalogCategoryNoColor),
                  selected: _color == null,
                  onSelected: (_) => setState(() => _color = null),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('category-save-button'),
          onPressed: _saving ? null : _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class _TaxRatesTab extends ConsumerWidget {
  const _TaxRatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(taxRatesProvider);
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.catalogTaxPlaceholderNote),
          const SizedBox(height: AppDimensions.paddingSmall),
          ElevatedButton.icon(
            key: const Key('create-tax-button'),
            icon: const Icon(Icons.add),
            label: Text(l10n.catalogNewTaxRate),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const TaxRateDialog(),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  _loadError(context, () => ref.invalidate(taxRatesProvider)),
              data: (list) => ListView(
                children: [
                  for (final t in list)
                    ListTile(
                      key: Key('tax-row-${t.id}'),
                      title: Text(t.name),
                      subtitle: Text(
                        l10n.catalogTaxSubtitle(
                          t.kind == TaxKind.iva
                              ? l10n.catalogIva
                              : l10n.catalogIeps,
                          formatBasisPoints(t.rateBp),
                        ),
                      ),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => TaxRateDialog(rate: t),
                      ),
                      trailing: Switch(
                        key: Key('tax-active-${t.id}'),
                        value: t.isActive,
                        onChanged: (v) async {
                          try {
                            await ref
                                .read(restClientProvider)
                                .catalog
                                .updateTaxRate(
                                  taxRateId: t.id,
                                  body: TaxRateUpdate(isActive: v),
                                );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    apiErrorCode(e) == 'CONFLICT'
                                        ? l10n.catalogTaxInUse
                                        : commonAdminError(l10n, e),
                                  ),
                                ),
                              );
                            }
                          }
                          ref.invalidate(taxRatesProvider);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `1600` → `16`, `825` → `8.25`.
String formatBasisPoints(int bp) {
  final whole = bp ~/ 100;
  final rest = bp % 100;
  if (rest == 0) return '$whole';
  return '$whole.${rest.toString().padLeft(2, '0').replaceAll(RegExp(r'0$'), '')}';
}

/// `16` → `1600`, `8.25` → `825`; null outside 0–100 or with more decimals.
int? parsePercentBp(String text) {
  final m = RegExp(r'^(\d{1,3})(\.(\d{1,2}))?$').firstMatch(text.trim());
  if (m == null) return null;
  final bp =
      int.parse(m.group(1)!) * 100 +
      int.parse((m.group(3) ?? '').padRight(2, '0'));
  return bp > 10000 ? null : bp;
}

class TaxRateDialog extends ConsumerStatefulWidget {
  const TaxRateDialog({super.key, this.rate});

  final TaxRate? rate;

  @override
  ConsumerState<TaxRateDialog> createState() => _TaxRateDialogState();
}

class _TaxRateDialogState extends ConsumerState<TaxRateDialog> {
  late final _name = TextEditingController(text: widget.rate?.name);
  final _percent = TextEditingController();
  TaxKind _kind = TaxKind.iva;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _percent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = l10n.catalogRequired);
    final api = ref.read(restClientProvider).catalog;
    try {
      final rate = widget.rate;
      if (rate == null) {
        final bp = parsePercentBp(_percent.text);
        if (bp == null) {
          return setState(() => _error = l10n.catalogTaxRateInvalid);
        }
        await api.createTaxRate(
          body: TaxRateCreate(kind: _kind, name: name, rateBp: bp),
        );
      } else {
        await api.updateTaxRate(
          taxRateId: rate.id,
          body: TaxRateUpdate(name: name),
        );
      }
      ref.invalidate(taxRatesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = commonAdminError(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final creating = widget.rate == null;
    return AlertDialog(
      title: Text(creating ? l10n.catalogNewTaxRate : l10n.catalogEditTaxRate),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) AdminErrorBanner(message: _error!),
            if (creating)
              DropdownButtonFormField<TaxKind>(
                key: const Key('tax-kind-field'),
                isExpanded: true,
                initialValue: _kind,
                decoration: InputDecoration(labelText: l10n.catalogTaxKind),
                items: [
                  DropdownMenuItem(
                    value: TaxKind.iva,
                    child: Text(l10n.catalogIva),
                  ),
                  DropdownMenuItem(
                    value: TaxKind.ieps,
                    child: Text(l10n.catalogIeps),
                  ),
                ],
                onChanged: (v) => setState(() => _kind = v ?? TaxKind.iva),
              ),
            TextField(
              key: const Key('tax-name-field'),
              controller: _name,
              decoration: InputDecoration(labelText: l10n.catalogTaxName),
            ),
            // A rate never changes once created: old sales keep theirs.
            if (creating)
              TextField(
                key: const Key('tax-percent-field'),
                controller: _percent,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.catalogTaxRatePercent,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('tax-save-button'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
