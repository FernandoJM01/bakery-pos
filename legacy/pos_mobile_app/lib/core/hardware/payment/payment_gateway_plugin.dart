abstract class PaymentGatewayPlugin {
  String get name;
  Future<PaymentResult> processPayment({
    required int amountCents,
    required String currency,
    Map<String, dynamic>? metadata,
  });
}

class PaymentResult {
  final bool isSuccess;
  final String transactionId;
  final String paymentMethod;
  final int amountCents;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  PaymentResult({
    required this.isSuccess,
    required this.transactionId,
    required this.paymentMethod,
    required this.amountCents,
    this.errorMessage,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
