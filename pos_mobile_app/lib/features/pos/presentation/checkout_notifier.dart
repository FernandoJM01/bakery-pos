import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/domain/user.dart';
import '../../inventory/domain/ledger_event.dart';
import '../../inventory/presentation/stock_notifier.dart';
import 'cart_notifier.dart';

class CheckoutResult {
  final bool isSuccess;
  final String orderId;
  final int changeDueCents;
  final String? errorMessage;

  const CheckoutResult({
    required this.isSuccess,
    required this.orderId,
    required this.changeDueCents,
    this.errorMessage,
  });
}

class CheckoutNotifier extends StateNotifier<bool> {
  final Ref _ref;
  static const _uuid = Uuid();

  CheckoutNotifier(this._ref) : super(false);

  Future<CheckoutResult> processCashCheckout({
    required int cashTenderedCents,
    required User cashier,
    required String terminalId,
  }) async {
    final cart = _ref.read(cartNotifierProvider);
    if (cart.isEmpty) {
      return const CheckoutResult(isSuccess: false, orderId: '', changeDueCents: 0, errorMessage: 'Cart is empty');
    }

    if (cashTenderedCents < cart.totalCents) {
      return CheckoutResult(
        isSuccess: false,
        orderId: '',
        changeDueCents: 0,
        errorMessage: 'Tendered amount is less than total due',
      );
    }

    state = true; // Processing
    try {
      final changeDueCents = cashTenderedCents - cart.totalCents;
      final orderId = 'ORD-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final stockNotifier = _ref.read(stockNotifierProvider.notifier);

      // Record SALE_COMPLETED events for each cart item
      for (final item in cart.itemsList) {
        final event = LedgerEvent(
          clientEventId: _uuid.v4(),
          branchId: cashier.branchId,
          terminalId: terminalId,
          eventType: LedgerEventType.saleCompleted,
          userId: cashier.id,
          productId: item.product.id,
          quantityChange: -item.quantity, // Stock decrement
          referenceId: orderId,
          clientTimestamp: DateTime.now(),
        );

        await stockNotifier.recordEvent(event);
      }

      // Clear ticket
      _ref.read(cartNotifierProvider.notifier).clearCart();
      state = false;

      return CheckoutResult(
        isSuccess: true,
        orderId: orderId,
        changeDueCents: changeDueCents,
      );
    } catch (e) {
      state = false;
      return CheckoutResult(
        isSuccess: false,
        orderId: '',
        changeDueCents: 0,
        errorMessage: 'Checkout failed: $e',
      );
    }
  }
}

final checkoutNotifierProvider = StateNotifierProvider<CheckoutNotifier, bool>((ref) {
  return CheckoutNotifier(ref);
});
