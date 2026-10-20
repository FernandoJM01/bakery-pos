import 'package:uuid/uuid.dart';
import 'payment_gateway_plugin.dart';

class CashPaymentService implements PaymentGatewayPlugin {
  static const _uuid = Uuid();

  @override
  String get name => 'CASH';

  @override
  Future<PaymentResult> processPayment({
    required int amountCents,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    final cashTendered = metadata?['cashTenderedCents'] as int? ?? amountCents;

    if (cashTendered < amountCents) {
      return PaymentResult(
        isSuccess: false,
        transactionId: '',
        paymentMethod: name,
        amountCents: amountCents,
        errorMessage: 'Cash tendered (\$${(cashTendered / 100).toStringAsFixed(2)}) is less than total amount (\$${(amountCents / 100).toStringAsFixed(2)})',
      );
    }

    return PaymentResult(
      isSuccess: true,
      transactionId: 'CASH-${_uuid.v4().substring(0, 8).toUpperCase()}',
      paymentMethod: name,
      amountCents: amountCents,
      metadata: {'changeDueCents': cashTendered - amountCents},
    );
  }
}
