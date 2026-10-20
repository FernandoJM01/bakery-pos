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
      return const CheckoutResult(isSuccess: false, orderId: '', changeDueCents: 0, errorMessage: 'El carrito está vacío');
    }

    if (cashTenderedCents < cart.totalCents) {
      return const CheckoutResult(
        isSuccess: false,
        orderId: '',
        changeDueCents: 0,
        errorMessage: 'El importe entregado es menor al total a cobrar',
      );
    }

    state = true; // Procesando
    try {
      final changeDueCents = cashTenderedCents - cart.totalCents;
      final orderId = 'ORD-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final stockNotifier = _ref.read(stockNotifierProvider.notifier);

      // Descontar inventario optimista y registrar eventos
      for (final item in cart.itemsList) {
        final event = LedgerEvent(
          clientEventId: _uuid.v4(),
          branchId: cashier.branchId,
          terminalId: terminalId,
          eventType: LedgerEventType.saleCompleted,
          userId: cashier.id,
          productId: item.product.id,
          quantityChange: -item.quantity,
          referenceId: orderId,
          clientTimestamp: DateTime.now(),
        );

        // Disparo seguro (optimista + persistencia en background)
        stockNotifier.recordEvent(event);
      }

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
        errorMessage: 'Error al procesar cobro: $e',
      );
    }
  }
}

final checkoutNotifierProvider = StateNotifierProvider<CheckoutNotifier, bool>((ref) {
  return CheckoutNotifier(ref);
});
