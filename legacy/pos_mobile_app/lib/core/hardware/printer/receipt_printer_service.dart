abstract class ReceiptPrinterService {
  Future<bool> connect();
  Future<void> disconnect();
  Future<bool> isConnected();

  /// Prints a receipt using ESC/POS formatting commands
  Future<bool> printReceipt({
    required String branchName,
    required String receiptNumber,
    required String cashierName,
    required DateTime timestamp,
    required List<ReceiptLineItem> items,
    required int subtotalCents,
    required int taxCents,
    required int totalCents,
    required String paymentMethod,
    int? cashTenderedCents,
    int? changeDueCents,
  });

  /// Sends raw ESC/POS byte sequence
  Future<void> sendRaw(List<int> bytes);
}

class ReceiptLineItem {
  final String name;
  final int quantity;
  final int unitPriceCents;
  final int totalPriceCents;

  const ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
    required this.totalPriceCents,
  });
}
