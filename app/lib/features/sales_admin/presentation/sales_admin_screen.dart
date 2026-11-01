import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/device.dart';
import 'package:bakery_pos/core/api/generated/models/discount_kind.dart';
import 'package:bakery_pos/core/api/generated/models/discount_reason.dart';
import 'package:bakery_pos/core/api/generated/models/refund_kind.dart';
import 'package:bakery_pos/core/api/generated/models/refund_reason.dart';
import 'package:bakery_pos/core/api/generated/models/sale.dart';
import 'package:bakery_pos/core/api/generated/models/sale_status.dart';
import 'package:bakery_pos/core/api/generated/models/sale_summary.dart';
import 'package:bakery_pos/core/api/generated/models/staff.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/sale/presentation/discount_dialog.dart';
import 'package:bakery_pos/features/staff/data/staff_admin_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Devices for naming the till of a sale. Managers without
/// `devices.manage` get an error here, and the screen shows a dash instead.
final salesDevicesProvider = FutureProvider.autoDispose<List<Device>>(
  (ref) => ref.read(restClientProvider).devices.listDevices(),
);

String saleStatusLabel(SaleStatus status, AppLocalizations l10n) =>
    switch (status) {
      SaleStatus.completed => l10n.salesStatusCompleted,
      SaleStatus.partiallyRefunded => l10n.salesStatusPartiallyRefunded,
      SaleStatus.refunded => l10n.salesStatusRefunded,
      SaleStatus.voided => l10n.salesStatusVoided,
      _ => status.json ?? '—',
    };

String _discountReasonLabel(DiscountReason r, AppLocalizations l10n) =>
    switch (r) {
      DiscountReason.frequentCustomer => l10n.saleReasonFrequent,
      DiscountReason.damaged => l10n.saleReasonDamaged,
      DiscountReason.promotion => l10n.saleReasonPromotion,
      DiscountReason.other => l10n.saleReasonOther,
      _ => r.json ?? '—',
    };

String _refundReasonLabel(RefundReason r, AppLocalizations l10n) => switch (r) {
  RefundReason.customerReturn => l10n.refundReasonCustomerReturn,
  RefundReason.wrongItem => l10n.refundReasonWrongItem,
  RefundReason.quality => l10n.refundReasonQuality,
  RefundReason.cashierError => l10n.refundReasonCashierError,
  RefundReason.other => l10n.refundReasonOther,
  _ => r.json ?? '—',
};

String _day(DateTime d) => formatAdminDateTime(d).split(' ').first;

/// Back office Ventas (M3 brief section 6, D11): sales by date range,
/// branch and folio with the shown totals, and each sale's full detail.
/// The owner sees every branch; a manager with `reports.branch` only their
/// own, which the server enforces.
class SalesAdminScreen extends ConsumerStatefulWidget {
  const SalesAdminScreen({super.key});

  @override
  ConsumerState<SalesAdminScreen> createState() => _SalesAdminScreenState();
}

class _SalesAdminScreenState extends ConsumerState<SalesAdminScreen> {
  static const _pageSize = 50;

  String? _branchId;
  DateTimeRange? _range;
  String? _folio;
  final _folioField = TextEditingController();

  final List<SaleSummary> _items = [];
  String? _nextCursor;
  bool _loading = true;
  String? _error;

  /// A response for an older request (a filter changed meanwhile) is
  /// dropped instead of mixing rows from two filters.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void dispose() {
    _folioField.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(restClientProvider)
          .sales
          .listSales(
            limit: _pageSize,
            branchId: _branchId,
            folio: _folio,
            from: _range?.start.toUtc(),
            // Through the end of the last chosen day.
            to: _range?.end.add(const Duration(days: 1)).toUtc(),
            cursor: reset ? null : _nextCursor,
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
      });
    } catch (e) {
      if (mounted && generation == _generation) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          if (reset) _items.clear();
          _nextCursor = null;
          _error = apiErrorCode(e) == 'PERMISSION_DENIED'
              ? l10n.salesForbidden
              : commonAdminError(l10n, e);
        });
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _setFilter(VoidCallback change) {
    setState(change);
    _load(reset: true);
  }

  void _searchFolio() {
    final text = _folioField.text.trim().toUpperCase();
    _setFilter(() => _folio = text.isEmpty ? null : text);
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked != null) _setFilter(() => _range = picked);
  }

  void _open(SaleSummary sale) {
    showDialog<void>(
      context: context,
      builder: (_) => SaleDetailDialog(saleId: sale.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final branchNames = {for (final b in branches) b.id: b.name};
    final total = _items.fold<int>(0, (s, x) => s + x.totalCents);
    final refunded = _items.fold<int>(0, (s, x) => s + x.refundedCents);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salesTitle),
        actions: [
          IconButton(
            key: const Key('refresh-sales-button'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.commonRefresh,
            onPressed: _loading ? null : () => _load(reset: true),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Wrap(
              spacing: AppDimensions.paddingMedium,
              runSpacing: AppDimensions.paddingSmall,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const Key('sales-date-filter'),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _range == null
                        ? l10n.auditAnyDate
                        : l10n.salesDateRange(
                            _day(_range!.start),
                            _day(_range!.end),
                          ),
                  ),
                  onPressed: _pickRange,
                ),
                if (_range != null)
                  IconButton(
                    key: const Key('sales-clear-dates'),
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.auditClearDates,
                    onPressed: () => _setFilter(() => _range = null),
                  ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: const Key('sales-branch-filter'),
                    initialValue: _branchId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.staffBranch),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.allBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(value: b.id, child: Text(b.name)),
                    ],
                    onChanged: (v) => _setFilter(() => _branchId = v),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    key: const Key('sales-folio-filter'),
                    controller: _folioField,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchFolio(),
                    decoration: InputDecoration(
                      labelText: l10n.salesFolioSearch,
                      suffixIcon: IconButton(
                        key: const Key('sales-folio-search'),
                        icon: const Icon(Icons.search),
                        onPressed: _searchFolio,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: AdminErrorBanner(message: _error!),
            ),
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: Text(
                l10n.salesShownSummary(
                  _items.length,
                  formatCents(total),
                  formatCents(refunded),
                ),
                key: const Key('sales-summary'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(l10n.salesEmpty, key: const Key('sales-empty')),
                  )
                : ListView(
                    key: const Key('sales-list'),
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    children: [
                      Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(label: Text(l10n.salesColFolio)),
                              DataColumn(label: Text(l10n.salesColDate)),
                              DataColumn(label: Text(l10n.staffBranch)),
                              DataColumn(label: Text(l10n.salesColCashier)),
                              DataColumn(
                                label: Text(l10n.salesColItems),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.salesColTotal),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.salesColRefunded),
                                numeric: true,
                              ),
                              DataColumn(label: Text(l10n.salesColStatus)),
                            ],
                            rows: [
                              for (final s in _items)
                                DataRow(
                                  onSelectChanged: (_) => _open(s),
                                  cells: [
                                    DataCell(
                                      Text(
                                        s.folio,
                                        key: Key('sale-${s.id}'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(formatAdminDateTime(s.occurredAt)),
                                    ),
                                    DataCell(
                                      Text(branchNames[s.branchId] ?? '—'),
                                    ),
                                    DataCell(Text(s.cashierName)),
                                    DataCell(Text(s.lineCount.toString())),
                                    DataCell(Text(formatCents(s.totalCents))),
                                    DataCell(
                                      Text(formatCents(s.refundedCents)),
                                    ),
                                    DataCell(
                                      Text(saleStatusLabel(s.status, l10n)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_nextCursor != null)
                        Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          child: Center(
                            child: OutlinedButton(
                              key: const Key('sales-load-more'),
                              onPressed: _loading
                                  ? null
                                  : () => _load(reset: false),
                              child: Text(l10n.salesLoadMore),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// One sale with its lines, discounts, tax by rate, payment, lines voided
/// before payment, and its refunds and cancels.
class SaleDetailDialog extends ConsumerWidget {
  const SaleDetailDialog({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      content: SizedBox(
        width: 640,
        child: FutureBuilder<Sale>(
          future: ref.read(restClientProvider).sales.getSale(saleId: saleId),
          builder: (context, snap) {
            if (snap.hasError) {
              return AdminErrorBanner(
                message: commonAdminError(l10n, snap.error!),
              );
            }
            if (!snap.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _SaleDetail(sale: snap.data!);
          },
        ),
      ),
      actions: [
        TextButton(
          key: const Key('sale-detail-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

class _SaleDetail extends ConsumerWidget {
  const _SaleDetail({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final devices = ref.watch(salesDevicesProvider).value ?? const <Device>[];
    final staff = ref.watch(staffAdminProvider).value ?? const <Staff>[];
    final branchName = {for (final b in branches) b.id: b.name};
    final deviceName = {for (final d in devices) d.id: d.name};
    final staffName = {for (final s in staff) s.id: s.displayName};

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.paddingMedium,
        bottom: AppDimensions.paddingSmall / 2,
      ),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    Widget none() => Text(l10n.salesNone);
    Widget amountRow(String label, int cents, {Key? key, bool bold = false}) {
      final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
      return Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(formatCents(cents), key: key, style: style),
        ],
      );
    }

    return SingleChildScrollView(
      key: Key('sale-detail-${sale.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.salesDetailTitle(sale.folio),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.paddingSmall / 2),
          Text(
            l10n.salesDetailMeta(
              formatAdminDateTime(sale.occurredAt),
              branchName[sale.branchId] ?? '—',
              deviceName[sale.deviceId] ?? '—',
              sale.cashierName,
            ),
          ),
          Text(saleStatusLabel(sale.status, l10n)),
          heading(l10n.salesDetailLines),
          for (final line in sale.lines)
            Padding(
              key: Key('sale-line-${line.lineNo}'),
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingSmall / 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.salesLineName(
                            line.productName,
                            line.variantName,
                          ),
                        ),
                        Text(
                          l10n.salesLineQty(
                            line.quantity,
                            formatCents(line.unitPriceCents),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (line.lineDiscountCents + line.orderDiscountCents >
                            0)
                          Text(
                            l10n.salesLineDiscount(
                              formatCents(
                                line.lineDiscountCents +
                                    line.orderDiscountCents,
                              ),
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        if (line.refundedQuantity > 0)
                          Text(
                            l10n.salesLineRefunded(line.refundedQuantity),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Text(formatCents(line.netCents)),
                ],
              ),
            ),
          const Divider(),
          amountRow(l10n.salesGross, sale.grossCents),
          amountRow(l10n.salesDiscountTotal, -sale.discountCents),
          amountRow(
            l10n.salesTotal,
            sale.totalCents,
            key: const Key('sale-detail-total'),
            bold: true,
          ),
          if (sale.refundedCents > 0)
            amountRow(l10n.salesRefundedTotal, -sale.refundedCents),
          heading(l10n.salesDetailDiscounts),
          if (sale.discounts.isEmpty) none(),
          for (final d in sale.discounts)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.salesDiscountRow(
                    d.lineNo == null
                        ? l10n.salesDiscountOrder
                        : l10n.salesDiscountLine(d.lineNo!),
                    d.kind == DiscountKind.percent
                        ? formatPercentBp(d.value)
                        : formatCents(d.value),
                    formatCents(d.cents),
                    d.note?.isNotEmpty == true
                        ? d.note!
                        : _discountReasonLabel(d.reason, l10n),
                  ),
                ),
                if (d.approverStaffId != null)
                  Text(
                    l10n.salesDiscountApproved(
                      staffName[d.approverStaffId] ?? '—',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          heading(l10n.salesDetailTaxes),
          if (sale.taxes.isEmpty) none(),
          for (final t in sale.taxes)
            Text(
              l10n.receiptTaxLine(
                t.kind.json ?? '—',
                formatPercentBp(t.rateBp),
                formatCents(t.baseCents),
                formatCents(t.taxCents),
              ),
            ),
          heading(l10n.salesDetailPayment),
          for (final p in sale.payments)
            Text(
              l10n.salesPaymentCash(
                formatCents(p.amountCents),
                formatCents(p.tenderedCents),
                formatCents(p.changeCents),
              ),
            ),
          heading(l10n.salesDetailVoided),
          if (sale.voidedLines.isEmpty) none(),
          for (final v in sale.voidedLines)
            Text(
              l10n.salesVoidedRow(
                v.quantity,
                formatCents(v.unitPriceCents),
                formatAdminTime(v.voidedAt),
                staffName[v.staffId] ?? '—',
              ),
            ),
          heading(l10n.salesDetailRefunds),
          if (sale.refunds.isEmpty) none(),
          for (final r in sale.refunds)
            Padding(
              key: Key('sale-refund-${r.id}'),
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingSmall / 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.salesRefundRow(
                      r.kind == RefundKind.valueVoid
                          ? l10n.salesRefundKindVoid
                          : l10n.salesRefundKindRefund,
                      formatAdminDateTime(r.occurredAt),
                      formatCents(r.totalCents),
                      r.note?.isNotEmpty == true
                          ? r.note!
                          : _refundReasonLabel(r.reason, l10n),
                    ),
                  ),
                  for (final l in r.lines)
                    Text(
                      l10n.salesRefundLineRow(
                        l.lineNo,
                        l.quantity,
                        formatCents(l.amountCents),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
