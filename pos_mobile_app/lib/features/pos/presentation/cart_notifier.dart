import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/domain/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  int get itemTotalCents => product.priceCents * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final Map<String, CartItem> items; // Key: productId

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

  void addProduct(Product product) {
    final existing = state.items[product.id];
    final updatedMap = Map<String, CartItem>.from(state.items);

    if (existing != null) {
      updatedMap[product.id] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedMap[product.id] = CartItem(product: product, quantity: 1);
    }
    state = CartState(items: updatedMap);
  }

  void removeProduct(String productId) {
    final existing = state.items[productId];
    if (existing == null) return;

    final updatedMap = Map<String, CartItem>.from(state.items);
    if (existing.quantity > 1) {
      updatedMap[productId] = existing.copyWith(quantity: existing.quantity - 1);
    } else {
      updatedMap.remove(productId);
    }
    state = CartState(items: updatedMap);
  }

  void deleteItem(String productId) {
    final updatedMap = Map<String, CartItem>.from(state.items)..remove(productId);
    state = CartState(items: updatedMap);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
