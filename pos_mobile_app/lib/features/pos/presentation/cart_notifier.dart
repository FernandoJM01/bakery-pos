import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/domain/product.dart';

class CartItem {
  final Product product;
  final ProductVariant? selectedVariant;
  final int quantity;

  const CartItem({
    required this.product,
    this.selectedVariant,
    required this.quantity,
  });

  String get cartKey => selectedVariant == null ? product.id : '${product.id}_${selectedVariant!.id}';

  int get unitPriceCents => product.priceCents + (selectedVariant?.priceDeltaCents ?? 0);

  int get itemTotalCents => unitPriceCents * quantity;

  String get displayName => selectedVariant == null ? product.name : '${product.name} (${selectedVariant!.name})';

  CartItem copyWith({int? quantity, ProductVariant? selectedVariant}) {
    return CartItem(
      product: product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final Map<String, CartItem> items; // Key: cartKey

  const CartState({this.items = const {}});

  List<CartItem> get itemsList => items.values.toList();
  int get itemCount => items.values.fold(0, (sum, i) => sum + i.quantity);
  int get subtotalCents => items.values.fold(0, (sum, i) => sum + i.itemTotalCents);
  int get taxCents => (subtotalCents * 0.08).round(); // 8% local tax
  int get totalCents => subtotalCents + taxCents;

  bool get isEmpty => items.isEmpty;
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(Product product, {ProductVariant? variant}) {
    final itemKey = variant == null ? product.id : '${product.id}_${variant.id}';
    final existing = state.items[itemKey];
    final updatedMap = Map<String, CartItem>.from(state.items);

    if (existing != null) {
      updatedMap[itemKey] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedMap[itemKey] = CartItem(
        product: product,
        selectedVariant: variant,
        quantity: 1,
      );
    }
    state = CartState(items: updatedMap);
  }

  void removeProduct(String itemKey) {
    final existing = state.items[itemKey];
    if (existing == null) return;

    final updatedMap = Map<String, CartItem>.from(state.items);
    if (existing.quantity > 1) {
      updatedMap[itemKey] = existing.copyWith(quantity: existing.quantity - 1);
    } else {
      updatedMap.remove(itemKey);
    }
    state = CartState(items: updatedMap);
  }

  void deleteItem(String itemKey) {
    final updatedMap = Map<String, CartItem>.from(state.items)..remove(itemKey);
    state = CartState(items: updatedMap);
  }

  void clearCart() {
    state = const CartState();
  }

  void restoreItems(List<CartItem> items) {
    final updatedMap = <String, CartItem>{};
    for (final item in items) {
      updatedMap[item.cartKey] = item;
    }
    state = CartState(items: updatedMap);
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
