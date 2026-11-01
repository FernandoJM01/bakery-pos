import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/appearance_settings.dart';
import '../../../l10n/app_localizations.dart';
import '../data/photo_cache.dart';
import '../../sync/data/sync_worker.dart';
import '../data/till_catalog_repository.dart';

/// Pushes the outbox and pulls the catalog now, then reloads the grid.
/// Offline is normal: the till keeps showing what it already has.
Future<bool> refreshTillCatalog(WidgetRef ref) async {
  final ok = await ref.read(syncWorkerProvider).syncNow();
  ref.invalidate(tillCatalogProvider);
  return ok;
}

/// The product grid from the approved wireframe; the sale screen puts it
/// beside the ticket and passes [onProductTap]. It shows the local copy;
/// pulls happen from the top bar's sync button and the sync worker, so the
/// grid works the same online and offline.
class ProductGridScreen extends ConsumerStatefulWidget {
  const ProductGridScreen({super.key, this.onProductTap});

  final void Function(GridProduct product)? onProductTap;

  @override
  ConsumerState<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends ConsumerState<ProductGridScreen> {
  String? _categoryId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = ref.watch(tillCatalogProvider);
    final style = ref.watch(appearanceSettingsProvider).buttonStyle;

    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.gridEmpty)),
      data: (c) {
        if (c.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.gridEmpty, key: const Key('grid-empty')),
                const SizedBox(height: AppDimensions.paddingMedium),
                OutlinedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.gridRefresh),
                  onPressed: () => refreshTillCatalog(ref),
                ),
              ],
            ),
          );
        }
        final colors = {for (final cat in c.categories) cat.id: cat.color};
        final inCategory = _categoryId == null
            ? c.products
            : c.products.where((p) => p.categoryId == _categoryId).toList();
        final shown = searchProducts(inCategory, _query);

        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('grid-search'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.gridSearchHint,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              SizedBox(
                height: AppDimensions.preferredTouchTarget,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final cat in [null, ...c.categories])
                      Padding(
                        padding: const EdgeInsets.only(
                          right: AppDimensions.paddingSmall,
                        ),
                        child: ChoiceChip(
                          key: Key('grid-tab-${cat?.id ?? 'all'}'),
                          label: Text(cat?.name ?? l10n.gridAll),
                          selected: _categoryId == cat?.id,
                          onSelected: (_) =>
                              setState(() => _categoryId = cat?.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Expanded(
                child: shown.isEmpty
                    ? Center(child: Text(l10n.gridNoMatches))
                    : GridView.builder(
                        key: const Key('product-grid'),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              mainAxisSpacing: AppDimensions.paddingSmall,
                              crossAxisSpacing: AppDimensions.paddingSmall,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: shown.length,
                        itemBuilder: (context, i) => ProductTile(
                          product: shown[i],
                          color: colors[shown[i].categoryId],
                          showPhoto: style == ProductButtonStyle.photoAndName,
                          onTap: widget.onProductTap == null
                              ? null
                              : () => widget.onProductTap!(shown[i]),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Color? _hex(String? hex) {
  final v = hex == null || hex.length != 7
      ? null
      : int.tryParse(hex.substring(1), radix: 16);
  return v == null ? null : Color(0xFF000000 | v);
}

/// Two letters for the placeholder: "Concha de vainilla" → "CV" (short
/// words like "de" are skipped), "Bolillo" → "BO".
String productInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2)
      .toList();
  if (words.length >= 2) return (words[0][0] + words[1][0]).toUpperCase();
  final word = words.isEmpty ? name.trim() : words.first;
  return word.substring(0, word.length < 2 ? word.length : 2).toUpperCase();
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.color,
    required this.showPhoto,
    this.onTap,
  });

  final GridProduct product;
  final String? color;
  final bool showPhoto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final price = formatCents(product.lowestPriceCents);
    return Card(
      key: Key('grid-tile-${product.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showPhoto)
              Expanded(
                child: _PhotoSlot(
                  photoId: product.photoId,
                  name: product.name,
                  color: _hex(color) ?? scheme.surfaceContainerHighest,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    product.hasPriceRange ? l10n.gridPriceFrom(price) : price,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The product photo, or the category color with initials while it loads or
/// when there is none. Never a broken image.
class _PhotoSlot extends ConsumerWidget {
  const _PhotoSlot({
    required this.photoId,
    required this.name,
    required this.color,
  });

  final String? photoId;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = ColoredBox(
      color: color,
      child: Center(
        child: Text(
          productInitials(name),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color.computeLuminance() > 0.5
                ? Colors.black87
                : Colors.white,
          ),
        ),
      ),
    );
    final id = photoId;
    if (id == null) return placeholder;
    return FutureBuilder<Uint8List?>(
      future: ref.read(photoCacheProvider).get(id),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes == null) return placeholder;
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => placeholder,
        );
      },
    );
  }
}
