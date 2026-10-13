import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import 'cart_notifier.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final String orderId;
  final String cashierName;
  final List<CartItem> items;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final int cashTenderedCents;
  final int changeDueCents;
  final VoidCallback onPrint;
  final VoidCallback onNewSale;

  const ReceiptPreviewDialog({
    super.key,
    required this.orderId,
    required this.cashierName,
    required this.items,
    required this.subtotalCents,
    required this.taxCents,
    required this.totalCents,
    required this.cashTenderedCents,
    required this.changeDueCents,
    required this.onPrint,
    required this.onNewSale,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: 24,
      ),
      child: Container(
        width: 440,
        constraints: const BoxConstraints(maxHeight: 740),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7F2), // Papel térmico marfil suave
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header con botones de acción superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFECE6DC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.backgroundDeep, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    AppStrings.digitalReceipt,
                    style: TextStyle(
                      color: AppColors.backgroundDeep,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.backgroundDeep),
                    onPressed: onNewSale,
                    tooltip: AppStrings.close,
                  ),
                ],
              ),
            ),

            // Contenido desplazable del recibo estilo térmico
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Datos de la panadería
                    const Center(
                      child: Text(
                        AppStrings.bakeryName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Av. Revolución 104, Centro Historico\nRFC: PANA-940812-ART\nTel: (55) 4120-8890',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Metadatos de la venta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ticket: $orderId', style: _monoMetaStyle()),
                        Text(dateStr, style: _monoMetaStyle()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cajero: $cashierName', style: _monoMetaStyle()),
                        Text('Caja: REG-01', style: _monoMetaStyle()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDashedLine(),
                    const SizedBox(height: 10),

                    // Encabezado de columnas
                    Row(
                      children: const [
                        Expanded(flex: 5, child: Text('DESCRIPCIÓN', style: TextStyle(fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('CANT', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('IMPORTE', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Lista de artículos
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  item.displayName,
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.black87),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.black87),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '\$${(item.itemTotalCents / 100).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 10),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Desglose de totales
                    _buildTotalRow(AppStrings.subtotal, '\$${(subtotalCents / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    _buildTotalRow(AppStrings.taxVat, '\$${(taxCents / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _buildDashedLine(),
                    const SizedBox(height: 6),
                    _buildTotalRow(
                      AppStrings.total,
                      '\$${(totalCents / 100).toStringAsFixed(2)}',
                      isBold: true,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 8),
                    _buildTotalRow(AppStrings.cashReceived, '\$${(cashTenderedCents / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    _buildTotalRow(
                      AppStrings.changeDue,
                      '\$${(changeDueCents / 100).toStringAsFixed(2)}',
                      highlightColor: const Color(0xFF1B6A42),
                      isBold: true,
                    ),

                    const SizedBox(height: 16),
                    _buildDashedLine(),
                    const SizedBox(height: 12),

                    // Código de barras simulado / Pie
                    const Center(
                      child: Text(
                        '||| | ||||| |||| | |||||| |||| | |||',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 16,
                          letterSpacing: 2,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        AppStrings.thanksForVisiting,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Conserve este ticket para cualquier aclaración',
                        style: TextStyle(fontFamily: 'Courier', fontSize: 10, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botonera de acciones inferiores
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECE6DC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.backgroundDeep,
                        side: const BorderSide(color: AppColors.backgroundDeep, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onPrint,
                      icon: const Icon(Icons.print_rounded),
                      label: const Text(
                        AppStrings.printReceipt,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: onNewSale,
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text(
                        AppStrings.newSale,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => const Text('-', style: TextStyle(fontFamily: 'Courier', color: Colors.black38, fontSize: 11)),
          ),
        );
      },
    );
  }

  TextStyle _monoMetaStyle() => const TextStyle(
        fontFamily: 'Courier',
        fontSize: 10,
        color: Colors.black87,
      );

  Widget _buildTotalRow(String label, String value, {bool isBold = false, double fontSize = 12, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: highlightColor ?? Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: highlightColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
