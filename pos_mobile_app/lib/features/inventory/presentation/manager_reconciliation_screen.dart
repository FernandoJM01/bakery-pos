import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
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

  // Shift & Cash Drawer Baseline
  static const int _openingFloatCents = 20000; // $200.00
  static const int _systemExpectedCashSalesCents = 74550; // $745.50
  static const int _systemExpectedCardSalesCents = 51225; // $512.25
  static const int _totalOrdersCount = 48;

  // Touch Counters for Cash Drawer Denominations
  late final List<DenominationRowData> _denominations;

  bool _isLockingDrawer = false;
  String? _statusBannerMessage;
  bool _isZReportPrinted = false;

  @override
  void initState() {
    super.initState();
    _denominations = [
      DenominationRowData(label: '\$100 Bills', valueCents: 10000, count: 5), // $500.00
      DenominationRowData(label: '\$50 Bills', valueCents: 5000, count: 4),   // $200.00
      DenominationRowData(label: '\$20 Bills', valueCents: 2000, count: 8),   // $160.00
      DenominationRowData(label: '\$10 Bills', valueCents: 1000, count: 6),   // $60.00
      DenominationRowData(label: '\$5 Bills', valueCents: 500, count: 4),     // $20.00
      DenominationRowData(label: '\$1 Coins/Bills', valueCents: 100, count: 5), // $5.00
      DenominationRowData(label: 'Coins (Rolls & Change)', valueCents: 10, count: 5), // $0.50
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
      _statusBannerMessage = 'Denominations reset to zero.';
    });
  }

  Future<void> _printZReport() async {
    final printer = ref.read(receiptPrinterProvider);
    await printer.connect();

    final lineItems = [
      ReceiptLineItem(
        name: 'Morning Opening Float',
        quantity: 1,
        unitPriceCents: _openingFloatCents,
        totalPriceCents: _openingFloatCents,
      ),
      ReceiptLineItem(
        name: 'Gross Cash Sales',
        quantity: 1,
        unitPriceCents: _systemExpectedCashSalesCents,
        totalPriceCents: _systemExpectedCashSalesCents,
      ),
      ReceiptLineItem(
        name: 'Gross Card Payments',
        quantity: 1,
        unitPriceCents: _systemExpectedCardSalesCents,
        totalPriceCents: _systemExpectedCardSalesCents,
      ),
      ReceiptLineItem(
        name: 'Variance Cash Adjustment',
        quantity: 1,
        unitPriceCents: _varianceCents,
        totalPriceCents: _varianceCents,
      ),
    ];

    await printer.printReceipt(
      branchName: 'ARTISAN BAKERY (Downtown BR-01)',
      receiptNumber: 'Z-REPORT-${DateFormat('yyyyMMdd-HHmm').format(_currentTime)}',
      cashierName: widget.manager?.fullName ?? 'Elena Rostova',
      timestamp: _currentTime,
      items: lineItems,
      subtotalCents: _expectedDrawerTotalCents,
      taxCents: (_expectedDrawerTotalCents * 0.08).round(),
      totalCents: _actualDrawerCountCents,
      paymentMethod: 'DRAWER RECONCILIATION Z-CLOSE',
    );

    if (mounted) {
      setState(() {
        _isZReportPrinted = true;
        _statusBannerMessage = 'Z-Report printed successfully via ESC/POS to console & thermal receipt.';
      });
    }
  }

  Future<void> _lockDrawerAndCloseShift() async {
    setState(() => _isLockingDrawer = true);

    try {
      final invRepo = ref.read(inventoryRepositoryProvider);

      // Record closing shift audit ledger event
      final auditEvent = LedgerEvent(
        clientEventId: 'audit-${DateTime.now().millisecondsSinceEpoch}',
        branchId: widget.manager?.branchId ?? 'a0000000-0000-0000-0000-000000000001',
        terminalId: 'REG-01',
        eventType: LedgerEventType.auditAdjustment,
        userId: widget.manager?.id ?? 'b0000000-0000-0000-0000-00000003',
        productId: 'c0000000-0000-0000-0000-000000000001', // system audit target
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

      // Pop to PIN Screen
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
              Text('Shift Closed & Drawer Locked', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Shift report saved locally and queued for Cloud Sync.\nActual drawer total: \$${(_actualDrawerCountCents / 100).toStringAsFixed(2)}\nVariance: \$${(_varianceCents / 100).toStringAsFixed(2)}',
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
              child: const Text('Return to Staff Login', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLockingDrawer = false;
          _statusBannerMessage = 'Failed to close shift: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(_currentTime);
    final managerName = widget.manager?.fullName ?? 'Elena Rostova';

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Enterprise POS Header Bar
            _buildTopHeader(timeStr, managerName),

            if (_statusBannerMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: AppColors.primaryAmber.withValues(alpha: 0.15),
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

            // 2. Main Content Split View (Left 50%: Cash Drawer Count / Right 50%: Shift Performance & Outbox)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left 50% — Physical Drawer Cash Count
                    Expanded(
                      flex: 5,
                      child: _buildCashDrawerReconciliationCard(),
                    ),

                    const SizedBox(width: 20),

                    // Right 50% — Shift Summary & Outbox Status
                    Expanded(
                      flex: 5,
                      child: _buildShiftPerformanceCard(),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action Bar (Print Z-Report & Close Shift)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(String timeStr, String managerName) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          // Bakery Logo & Branch
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryAmber, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'MANAGER RECONCILIATION',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Shift End & Drawer Audit (BR-01)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Manager Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_pin_rounded, color: AppColors.primaryAmber, size: 18),
                const SizedBox(width: 8),
                Text(
                  managerName,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 6),
                const Text(
                  '• Store Manager',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Live Clock
          Text(
            timeStr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(width: 12),

          // Edge Sync Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreenBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Local Edge Online',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Exit / Return Button
          IconButton(
            tooltip: 'Return to Staff PIN Pad',
            icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.textMuted),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PinLoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCashDrawerReconciliationCard() {
    final variance = _varianceCents;
    final isBalanced = variance == 0;
    final isOver = variance > 0;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.point_of_sale_rounded, color: AppColors.primaryAmber, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Physical Drawer Cash Count',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _resetDrawerCounts,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textMuted),
                label: const Text('Reset', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Expected Drawer Overview Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Row(
              children: [
                Expanded(child: _buildMetricCol('OPENING FLOAT', '\$${(_openingFloatCents / 100).toStringAsFixed(2)}')),
                Expanded(child: _buildMetricCol('CASH SALES', '\$${(_systemExpectedCashSalesCents / 100).toStringAsFixed(2)}')),
                Expanded(child: _buildMetricCol('EXPECTED DRAWER', '\$${(_expectedDrawerTotalCents / 100).toStringAsFixed(2)}', highlight: true)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Denomination Counters List
          Expanded(
            child: ListView.separated(
              itemCount: _denominations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _denominations[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceHighlight.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      // Denomination Label
                      Expanded(
                        flex: 4,
                        child: Text(
                          item.label,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),

                      // Stepper (-1, +1, +5)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStepperButton(Icons.remove, () => _incrementDenomination(item, -1)),
                          Container(
                            constraints: const BoxConstraints(minWidth: 38),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.count}',
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          _buildStepperButton(Icons.add, () => _incrementDenomination(item, 1)),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _incrementDenomination(item, 5),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighlight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('+5', style: TextStyle(color: AppColors.primaryAmber, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Line Total
                      SizedBox(
                        width: 75,
                        child: Text(
                          '\$${(item.totalCents / 100).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Total Actual vs Variance Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isBalanced
                  ? AppColors.successGreenBg
                  : (isOver ? AppColors.surfaceElevated : AppColors.alertRedBg),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isBalanced
                    ? AppColors.successGreen.withValues(alpha: 0.4)
                    : (isOver ? AppColors.primaryAmber.withValues(alpha: 0.4) : AppColors.alertRed.withValues(alpha: 0.4)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACTUAL DRAWER COUNT', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '\$${(_actualDrawerCountCents / 100).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBalanced
                        ? AppColors.successGreen
                        : (isOver ? AppColors.primaryAmber : AppColors.alertRed),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBalanced ? Icons.check_circle_rounded : (isOver ? Icons.arrow_upward_rounded : Icons.warning_rounded),
                        color: Colors.black,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBalanced
                            ? 'BALANCED (\$0.00)'
                            : '${isOver ? "+ OVER" : "- SHORT"} \$${(variance.abs() / 100).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftPerformanceCard() {
    const totalSalesCents = _systemExpectedCashSalesCents + _systemExpectedCardSalesCents;
    final cashPercent = (_systemExpectedCashSalesCents / totalSalesCents * 100).round();
    final cardPercent = 100 - cashPercent;

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.analytics_rounded, color: AppColors.primaryAmber, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Shift Performance & Outbox Ledger',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Key Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildShiftMetricTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Total Shift Orders',
                    value: '$_totalOrdersCount Orders',
                    subtitle: 'Avg \$${((totalSalesCents / _totalOrdersCount) / 100).toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShiftMetricTile(
                    icon: Icons.monetization_on_rounded,
                    title: 'Net Shift Sales',
                    value: '\$${(totalSalesCents / 100).toStringAsFixed(2)}',
                    subtitle: 'Cash + Card Terminal',
                    valueColor: AppColors.primaryAmber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Payment Distribution Visualizer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Payment Distribution',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('Cash $cashPercent% • Card $cardPercent%', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: cashPercent,
                          child: Container(height: 10, color: AppColors.primaryAmber),
                        ),
                        Expanded(
                          flex: cardPercent,
                          child: Container(height: 10, color: AppColors.surfaceHighlight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Cash: \$${(_systemExpectedCashSalesCents / 100).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryAmber, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        child: Text('Card: \$${(_systemExpectedCardSalesCents / 100).toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Outbox Sync & Resilience Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.sync_rounded, color: AppColors.successGreen, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline-First Outbox Status',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('0 Pending', style: TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All order sales, batch restocks, and cash movements are stored in local SQLite ledger and synchronized upstream to Postgres via /sync/push idempotent batches.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Manager Audit Sign-off Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_user_rounded, color: AppColors.primaryAmber, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Submitting Z-Close logs an immutable AUDIT_ADJUSTMENT ledger entry tied to this manager session.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
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

  Widget _buildShiftMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color valueColor = AppColors.textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryAmber, size: 20),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primaryAmber : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceHighlight,
          foregroundColor: AppColors.textPrimary,
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          // Print Z-Report Button
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: _isZReportPrinted ? AppColors.successGreen : AppColors.primaryAmber),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: _printZReport,
              icon: Icon(
                _isZReportPrinted ? Icons.check_circle_rounded : Icons.print_rounded,
                color: _isZReportPrinted ? AppColors.successGreen : AppColors.primaryAmber,
                size: 20,
              ),
              label: Text(
                _isZReportPrinted ? 'Z-REPORT PRINTED' : 'PRINT Z-REPORT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _isZReportPrinted ? AppColors.successGreen : AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Lock Drawer & Close Shift Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: AppColors.backgroundDeep,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isLockingDrawer ? null : _lockDrawerAndCloseShift,
                icon: _isLockingDrawer
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.backgroundDeep, strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_rounded, size: 20),
                label: Text(
                  _isLockingDrawer ? 'CLOSING SHIFT...' : 'LOCK DRAWER & CLOSE SHIFT',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
