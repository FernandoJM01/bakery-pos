import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/hardware/printer/console_printer_service.dart';
import '../../../core/hardware/printer/receipt_printer_service.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../inventory/domain/ledger_event.dart';
import '../../inventory/data/inventory_repository.dart';

final receiptPrinterProvider = Provider<ReceiptPrinterService>((ref) => ConsolePrinterService());
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => InventoryRepositoryImpl());

class DenominationRowData {
  final String label;
  final int valueCents;
  int count;

  DenominationRowData({
    required this.label,
    required this.valueCents,
    this.count = 0,
  });

  int get totalCents => valueCents * count;
}

class ManagerReconciliationScreen extends ConsumerStatefulWidget {
  final User? manager;

  const ManagerReconciliationScreen({
    super.key,
    this.manager,
  });

  @override
  ConsumerState<ManagerReconciliationScreen> createState() => _ManagerReconciliationScreenState();
}

class _ManagerReconciliationScreenState extends ConsumerState<ManagerReconciliationScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  static const int _openingFloatCents = 20000; // $200.00
  static const int _systemExpectedCashSalesCents = 74550; // $745.50
  static const int _systemExpectedCardSalesCents = 51225; // $512.25
  static const int _totalOrdersCount = 48;

  late final List<DenominationRowData> _denominations;

  bool _isLockingDrawer = false;
  String? _statusBannerMessage;
  bool _isZReportPrinted = false;

  @override
  void initState() {
    super.initState();
    _denominations = [
      DenominationRowData(label: 'Billetes \$100', valueCents: 10000, count: 5), // $500.00
      DenominationRowData(label: 'Billetes \$50', valueCents: 5000, count: 4),   // $200.00
      DenominationRowData(label: 'Billetes \$20', valueCents: 2000, count: 8),   // $160.00
      DenominationRowData(label: 'Billetes \$10', valueCents: 1000, count: 6),   // $60.00
      DenominationRowData(label: 'Billetes \$5', valueCents: 500, count: 4),     // $20.00
      DenominationRowData(label: 'Monedas \$1', valueCents: 100, count: 5),     // $5.00
      DenominationRowData(label: 'Monedas Cambio/Centavos', valueCents: 10, count: 5), // $0.50
    ];

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  int get _actualDrawerCountCents {
    return _denominations.fold<int>(0, (sum, d) => sum + d.totalCents);
  }

  int get _expectedDrawerTotalCents => _openingFloatCents + _systemExpectedCashSalesCents;

  int get _varianceCents => _actualDrawerCountCents - _expectedDrawerTotalCents;

  void _incrementDenomination(DenominationRowData item, int step) {
    setState(() {
      item.count = (item.count + step).clamp(0, 9999);
      _statusBannerMessage = null;
    });
  }

  void _resetDrawerCounts() {
    setState(() {
      for (final d in _denominations) {
        d.count = 0;
      }
      _statusBannerMessage = 'Conteo de denominaciones reiniciado a cero.';
    });
  }

  Future<void> _printZReport() async {
    final printer = ref.read(receiptPrinterProvider);
    await printer.connect();

    final lineItems = [
      ReceiptLineItem(
        name: 'Fondo de Caja Inicial',
        quantity: 1,
        unitPriceCents: _openingFloatCents,
        totalPriceCents: _openingFloatCents,
      ),
      ReceiptLineItem(
        name: 'Ventas en Efectivo',
        quantity: 1,
        unitPriceCents: _systemExpectedCashSalesCents,
        totalPriceCents: _systemExpectedCashSalesCents,
      ),
      ReceiptLineItem(
        name: 'Ventas con Tarjeta',
        quantity: 1,
        unitPriceCents: _systemExpectedCardSalesCents,
        totalPriceCents: _systemExpectedCardSalesCents,
      ),
      ReceiptLineItem(
        name: 'Ajuste de Diferencia en Caja',
        quantity: 1,
        unitPriceCents: _varianceCents,
        totalPriceCents: _varianceCents,
      ),
    ];

    await printer.printReceipt(
      branchName: AppStrings.branchDowntown,
      receiptNumber: 'CORTE-Z-${DateFormat('yyyyMMdd-HHmm').format(_currentTime)}',
      cashierName: widget.manager?.fullName ?? 'Elena Rostova',
      timestamp: _currentTime,
      items: lineItems,
      subtotalCents: _expectedDrawerTotalCents,
      taxCents: (_expectedDrawerTotalCents * 0.08).round(),
      totalCents: _actualDrawerCountCents,
      paymentMethod: 'ARQUEO DE CAJA CORTE Z',
    );

    if (mounted) {
      setState(() {
        _isZReportPrinted = true;
        _statusBannerMessage = 'Reporte Z impreso exitosamente via ESC/POS a consola e impresora térmica.';
      });
    }
  }

  Future<void> _lockDrawerAndCloseShift() async {
    setState(() => _isLockingDrawer = true);

    try {
      final invRepo = ref.read(inventoryRepositoryProvider);

      final auditEvent = LedgerEvent(
        clientEventId: 'audit-${DateTime.now().millisecondsSinceEpoch}',
        branchId: widget.manager?.branchId ?? 'a0000000-0000-0000-0000-000000000001',
        terminalId: 'REG-01',
        eventType: LedgerEventType.auditAdjustment,
        userId: widget.manager?.id ?? 'b0000000-0000-0000-0000-00000003',
        productId: 'c0000000-0000-0000-0000-000000000001',
        quantityChange: 0,
        metadata: {
          'reason': 'SHIFT_CLOSE_RECONCILIATION',
          'opening_float_cents': _openingFloatCents,
          'expected_cash_cents': _expectedDrawerTotalCents,
          'actual_drawer_cents': _actualDrawerCountCents,
          'variance_cents': _varianceCents,
          'total_orders': _totalOrdersCount,
          'closed_by': widget.manager?.fullName ?? 'Elena Rostova',
        },
        clientTimestamp: DateTime.now(),
        syncStatus: 'PENDING',
        retryCount: 0,
      );

      await invRepo.recordEventAndUpdateStock(auditEvent);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.lock_clock_rounded, color: AppColors.primaryAmber, size: 28),
              SizedBox(width: 12),
              Text('Turno Cerrado y Caja Bloqueada', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'El reporte de turno se guardó localmente y se encoló para sincronización Cloud.\nTotal físico en caja: \$${(_actualDrawerCountCents / 100).toStringAsFixed(2)}\nDiferencia: \$${(_varianceCents / 100).toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAmber,
                foregroundColor: AppColors.backgroundDeep,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PinLoginScreen()),
                );
              },
              child: const Text('Volver al Login de Personal', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLockingDrawer = false;
          _statusBannerMessage = 'Error al cerrar el turno: $e';
        });
      }
    }
  }

  void _confirmLogout(BuildContext context, User? manager) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceHighlight),
        ),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.primaryAmber, size: 24),
            SizedBox(width: 10),
            Text(AppStrings.confirmLogout, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          '¿Deseas salir del panel gerencial y volver al acceso con PIN, ${manager?.fullName ?? "Elena Rostova"}?',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PinLoginScreen()),
              );
            },
            child: const Text(AppStrings.logOut, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(_currentTime);
    final managerName = widget.manager?.fullName ?? 'Elena Rostova';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // Barra Superior
            _buildTopHeader(timeStr, managerName, isMobile),

            if (_statusBannerMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: AppColors.primaryAmber.withOpacity(0.15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primaryAmber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusBannerMessage!,
                        style: const TextStyle(color: AppColors.primaryAmber, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Contenido Principal Responsive
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14.0 : 24.0,
                  vertical: 14.0,
                ),
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCashDrawerReconciliationCard(),
                            const SizedBox(height: 20),
                            _buildShiftSummaryAndOutboxCard(),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Izquierda 50%: Conteo de Caja
                          Expanded(
                            flex: 5,
                            child: _buildCashDrawerReconciliationCard(),
                          ),
                          const SizedBox(width: 20),
                          // Derecha 50%: Resumen y Acciones
                          Expanded(
                            flex: 5,
                            child: _buildShiftSummaryAndOutboxCard(),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(String timeStr, String managerName, bool isMobile) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14.0 : 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            tooltip: AppStrings.logOut,
            onPressed: () => _confirmLogout(context, widget.manager),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: widget.manager?.avatarAsset != null
                      ? Image.asset(
                          widget.manager!.avatarAsset!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.badge_rounded, color: AppColors.primaryAmber, size: 18),
                        )
                      : const Icon(Icons.badge_rounded, color: AppColors.primaryAmber, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  '$managerName (Gerencia)',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            timeStr,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCashDrawerReconciliationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.point_of_sale_rounded, color: AppColors.primaryAmber, size: 22),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Conteo Físico de Efectivo',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _resetDrawerCounts,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.alertRed),
                label: const Text('Reiniciar', style: TextStyle(color: AppColors.alertRed, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Actual Conteo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Conteo Físico:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                Text(
                  '\$${(_actualDrawerCountCents / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primaryAmber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Lista de Denominaciones
          Expanded(
            child: ListView.separated(
              itemCount: _denominations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final d = _denominations[idx];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          d.label,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      // Stepper [-] [Count] [+]
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textMuted, size: 20),
                            onPressed: () => _incrementDenomination(d, -1),
                          ),
                          Text(
                            '${d.count}',
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryAmber, size: 20),
                            onPressed: () => _incrementDenomination(d, 1),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '\$${(d.totalCents / 100).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSummaryAndOutboxCard() {
    final variance = _varianceCents;
    final isSurplus = variance > 0;
    final isBalanced = variance == 0;
    final varianceColor = isBalanced
        ? AppColors.successGreen
        : (isSurplus ? AppColors.primaryAmber : AppColors.alertRed);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.analytics_rounded, color: AppColors.primaryAmber, size: 22),
              SizedBox(width: 8),
              Text(
                'Balance del Turno y Auditoría',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Resumen de Esperados
          _buildSummaryRow(AppStrings.openingFloat, '\$${(_openingFloatCents / 100).toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(AppStrings.expectedCash, '\$${(_systemExpectedCashSalesCents / 100).toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(AppStrings.expectedCard, '\$${(_systemExpectedCardSalesCents / 100).toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Esperado en Caja:', '\$${(_expectedDrawerTotalCents / 100).toStringAsFixed(2)}', isBold: true),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.surfaceHighlight),
          const SizedBox(height: 14),

          // Tarjeta de Diferencia
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: varianceColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: varianceColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBalanced ? 'Caja Cuadrada' : (isSurplus ? 'Sobrante en Caja' : 'Faltante en Caja'),
                        style: TextStyle(color: varianceColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Diferencia respecto a ventas',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isSurplus ? '+' : ''}\$${(variance / 100).toStringAsFixed(2)}',
                  style: TextStyle(color: varianceColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Acciones: Imprimir Corte Z y Cerrar Turno
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.surfaceHighlight),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _printZReport,
                  icon: const Icon(Icons.print_rounded),
                  label: const Text(AppStrings.printZReport, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLockingDrawer ? null : _lockDrawerAndCloseShift,
                  icon: _isLockingDrawer
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.lock_clock_rounded),
                  label: const Text('CERRAR TURNO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
