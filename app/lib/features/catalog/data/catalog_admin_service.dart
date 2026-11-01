import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/category.dart';
import '../../../core/api/generated/models/product.dart';
import '../../../core/api/generated/models/tax_rate.dart';

/// Every tax rate, active or not, for the Impuestos tab and the product form.
final taxRatesProvider = FutureProvider.autoDispose<List<TaxRate>>(
  (ref) => ref.watch(restClientProvider).catalog.listTaxRates(),
);

/// Every category in display order, active or not.
final adminCategoriesProvider = FutureProvider.autoDispose<List<Category>>(
  (ref) => ref
      .watch(restClientProvider)
      .catalog
      .listCategories(includeInactive: true),
);

class ProductFilter {
  const ProductFilter({
    this.q = '',
    this.categoryId,
    this.includeInactive = false,
  });

  final String q;
  final String? categoryId;
  final bool includeInactive;
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
      ProductFilterNotifier.new,
    );

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void set({
    String? q,
    String? categoryId,
    bool clearCategory = false,
    bool? includeInactive,
  }) {
    state = ProductFilter(
      q: q ?? state.q,
      categoryId: clearCategory ? null : (categoryId ?? state.categoryId),
      includeInactive: includeInactive ?? state.includeInactive,
    );
  }
}

/// Products matching the filter. Riverpod drops the result of a superseded
/// request when the filter changes, so a slow search never overwrites a
/// newer one.
final adminProductsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final filter = ref.watch(productFilterProvider);
  final page = await ref
      .watch(restClientProvider)
      .catalog
      .listProducts(
        q: filter.q.trim().isEmpty ? null : filter.q.trim(),
        categoryId: filter.categoryId,
        includeInactive: filter.includeInactive,
        limit: 200,
      );
  return page.items;
});

typedef PickedPhoto = ({Uint8List bytes, String name});

/// Opens the system picker for one image; tests override it.
final photoPickerProvider = Provider<Future<PickedPhoto?> Function()>(
  (ref) => () async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return null;
    return (bytes: await file.readAsBytes(), name: file.name);
  },
);
