import 'dart:typed_data';

import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/dashboard.dart';
import 'package:bakery_pos/core/api/generated/models/orders_report.dart';
import 'package:bakery_pos/core/api/generated/models/sales_group.dart';
import 'package:bakery_pos/core/api/generated/models/sales_report.dart';
import 'package:bakery_pos/core/api/generated/models/stock_report.dart';
import 'package:bakery_pos/core/download/save_file.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bar_chart.dart';

String _day(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _mime = {
  'csv': 'text/csv',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
};

/// Downloads a report file (M9.4) as bytes: the generated client would read
/// it as text and break an Excel file.
Future<void> exportReport(
  BuildContext context,
  WidgetRef ref,
  String path,
  Map<String, String> query,
  String format,
) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final res = await ref
        .read(dioProvider)
        .get<List<int>>(
          '/v1/reports/$path/export',
          queryParameters: {...query, 'format': format},
          options: Options(responseType: ResponseType.bytes),
        );
    final name =
        RegExp(r'filename="([^"]+)"')
            .firstMatch(res.headers.value('content-disposition') ?? '')
            ?.group(1) ??
        'reporte.$format';
    await saveFile(name, Uint8List.fromList(res.data!), _mime[format]!);
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportsExported(name))));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(commonAdminError(l10n, e))));
  }
}

/// Back office Reportes (M9): the owner's dashboard, sales grouped any way,
/// stock and balances, each one exported for the accountant.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _branchId;
  late DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navReports),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(key: const Key('tab-dashboard'), text: l10n.reportsDashboard),
              Tab(key: const Key('tab-sales'), text: l10n.reportsSales),
              Tab(key: const Key('tab-stock'), text: l10n.reportsStock),
              Tab(key: const Key('tab-balances'), text: l10n.reportsBalances),
            ],
          ),
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
                    key: const Key('reports-range'),
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      l10n.reportsRange(_day(_range.start), _day(_range.end)),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 2),
                        lastDate: now,
                        initialDateRange: _range,
                      );
                      if (picked != null) setState(() => _range = picked);
                    },
                  ),
                  SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<String?>(
                      key: const Key('reports-branch'),
                      isExpanded: true,
                      initialValue: _branchId,
                      decoration: InputDecoration(labelText: l10n.staffBranch),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.allBranches),
                        ),
                        for (final b in branches)
                          DropdownMenuItem(value: b.id, child: Text(b.name)),
                      ],
                      onChanged: (v) => setState(() => _branchId = v),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _DashboardTab(
                    key: ValueKey('d$_branchId${_range.end}'),
                    branchId: _branchId,
                    date: _day(_range.end),
                  ),
                  _SalesTab(
                    key: ValueKey('s$_branchId$_range'),
                    branchId: _branchId,
                    from: _day(_range.start),
                    to: _day(_range.end),
                  ),
                  _StockTab(
                    key: ValueKey('k$_branchId$_range'),
                    branchId: _branchId,
                    from: _day(_range.start),
                    to: _day(_range.end),
                  ),
                  _BalancesTab(
                    key: ValueKey('b$_branchId$_range'),
                    branchId: _branchId,
                    from: _day(_range.start),
                    to: _day(_range.end),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _loader<T>(
  AppLocalizations l10n,
  Future<T> future,
  Widget Function(T data) build,
) => FutureBuilder<T>(
  future: future,
  builder: (context, snap) {
    if (snap.hasError) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: AdminErrorBanner(message: commonAdminError(l10n, snap.error!)),
      );
    }
    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
    return build(snap.data as T);
  },
);

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, {this.note, this.alert = false, this.k});

  final String label;
  final String value;
  final String? note;
  final bool alert;
  final String? k;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                value,
                key: k == null ? null : Key(k!),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: alert ? AppColors.alertRed : null,
                ),
              ),
              if (note != null) Text(note!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab({super.key, this.branchId, required this.date});

  final String? branchId;
  final String date;

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  late final Future<Dashboard> _data = ref
      .read(restClientProvider)
      .reports
      .getDashboard(date: widget.date, branchId: widget.branchId);

  String _change(AppLocalizations l10n, int now, int before) {
    if (before == 0) return l10n.reportsNoCompare;
    final pct = ((now - before) * 100 / before).round();
    return l10n.reportsVsLastWeek(pct >= 0 ? '+$pct%' : '$pct%');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return _loader(l10n, _data, (Dashboard d) {
      return ListView(
        key: const Key('dashboard'),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          Text(l10n.reportsDayOf(d.date), style: theme.textTheme.titleLarge),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: [
              _Kpi(
                l10n.reportsNetSales,
                formatCents(d.netCents),
                note: _change(l10n, d.netCents, d.compareNetCents),
                k: 'kpi-net',
              ),
              _Kpi(
                l10n.reportsTickets,
                (d.saleCount).toString(),
                note: _change(l10n, d.saleCount, d.compareSaleCount),
                k: 'kpi-tickets',
              ),
              _Kpi(
                l10n.reportsAverageTicket,
                formatCents(d.averageTicketCents),
                k: 'kpi-average',
              ),
              _Kpi(l10n.reportsRefunds, formatCents(d.refundCents)),
              _Kpi(
                l10n.reportsWaste,
                formatCents(d.wasteCostCents),
                note: l10n.reportsUnits(d.wasteUnits),
              ),
              _Kpi(l10n.reportsPrepaid, formatCents(d.prepaidCollectedCents)),
              _Kpi(
                l10n.reportsFlaggedShifts,
                (d.flaggedShifts).toString(),
                alert: d.flaggedShifts > 0,
                k: 'kpi-flagged',
              ),
              _Kpi(
                l10n.reportsCustomersOwing,
                (d.customersOwing).toString(),
                alert: d.customersOwing > 0,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(l10n.reportsByHour, style: theme.textTheme.titleMedium),
          BarChart(
            key: const Key('chart-hours'),
            bars: [
              for (final h in d.hours)
                Bar(
                  '${h.hour}',
                  h.netCents,
                  formatCents(h.netCents).split('.').first,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(l10n.reportsLast14Days, style: theme.textTheme.titleMedium),
          BarChart(
            key: const Key('chart-days'),
            bars: [
              for (final x in d.days)
                Bar(
                  x.date.substring(8),
                  x.netCents,
                  formatCents(x.netCents).split('.').first,
                  highlight: x.date == d.date,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Wrap(
            spacing: AppDimensions.paddingLarge,
            runSpacing: AppDimensions.paddingMedium,
            children: [
              SizedBox(
                width: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.reportsTopProducts,
                      style: theme.textTheme.titleMedium,
                    ),
                    for (final p in d.topProducts)
                      ListTile(
                        dense: true,
                        title: Text(p.label),
                        subtitle: Text(l10n.reportsUnits(p.quantity)),
                        trailing: Text(formatCents(p.netCents)),
                      ),
                  ],
                ),
              ),
              if (d.branches.length > 1)
                SizedBox(
                  width: 420,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.reportsByBranch,
                        style: theme.textTheme.titleMedium,
                      ),
                      for (final b in d.branches)
                        ListTile(
                          dense: true,
                          title: Text(b.name),
                          subtitle: Text(l10n.reportsTicketsCount(b.saleCount)),
                          trailing: Text(formatCents(b.netCents)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

Widget _exportButtons(
  BuildContext context,
  WidgetRef ref,
  String path,
  Map<String, String> query,
) {
  final l10n = AppLocalizations.of(context)!;
  return Wrap(
    spacing: AppDimensions.paddingSmall,
    children: [
      OutlinedButton.icon(
        key: Key('export-$path-xlsx'),
        icon: const Icon(Icons.table_view_outlined),
        label: Text(l10n.reportsExportExcel),
        onPressed: () => exportReport(context, ref, path, query, 'xlsx'),
      ),
      OutlinedButton.icon(
        key: Key('export-$path-csv'),
        icon: const Icon(Icons.description_outlined),
        label: Text(l10n.reportsExportCsv),
        onPressed: () => exportReport(context, ref, path, query, 'csv'),
      ),
    ],
  );
}

String _groupLabel(AppLocalizations l10n, SalesGroup g) => switch (g) {
  SalesGroup.day => l10n.reportsByDay,
  SalesGroup.hour => l10n.reportsHour,
  SalesGroup.branch => l10n.staffBranch,
  SalesGroup.device => l10n.reportsTill,
  SalesGroup.cashier => l10n.reportsCashier,
  SalesGroup.product => l10n.reportsProduct,
  _ => l10n.reportsTaxRate,
};

class _SalesTab extends ConsumerStatefulWidget {
  const _SalesTab({
    super.key,
    this.branchId,
    required this.from,
    required this.to,
  });

  final String? branchId;
  final String from;
  final String to;

  @override
  ConsumerState<_SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends ConsumerState<_SalesTab> {
  SalesGroup _group = SalesGroup.day;
  late Future<SalesReport> _data = _load();

  Future<SalesReport> _load() => ref
      .read(restClientProvider)
      .reports
      .getSalesReport(
        from: widget.from,
        to: widget.to,
        groupBy: _group,
        branchId: widget.branchId,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = {
      'from': widget.from,
      'to': widget.to,
      'groupBy': _group.json ?? _group.name,
      if (widget.branchId != null) 'branchId': widget.branchId!,
    };
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        Wrap(
          spacing: AppDimensions.paddingMedium,
          runSpacing: AppDimensions.paddingSmall,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<SalesGroup>(
                key: const Key('sales-group'),
                isExpanded: true,
                initialValue: _group,
                decoration: InputDecoration(labelText: l10n.reportsGroupBy),
                items: [
                  for (final g in SalesGroup.values.where(
                    (g) => g != SalesGroup.$unknown,
                  ))
                    DropdownMenuItem(
                      value: g,
                      child: Text(_groupLabel(l10n, g)),
                    ),
                ],
                onChanged: (g) => setState(() {
                  _group = g ?? _group;
                  _data = _load();
                }),
              ),
            ),
            _exportButtons(context, ref, 'sales', query),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _loader(l10n, _data, (SalesReport r) {
          final tax = r.groupBy == SalesGroup.taxRate;
          final rows = [...r.items, r.totals];
          return Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                key: const Key('sales-table'),
                columns: [
                  DataColumn(label: Text(_groupLabel(l10n, r.groupBy))),
                  if (tax) ...[
                    DataColumn(label: Text(l10n.reportsBase), numeric: true),
                    DataColumn(label: Text(l10n.reportsTax), numeric: true),
                  ] else ...[
                    DataColumn(label: Text(l10n.reportsTickets), numeric: true),
                    if (r.groupBy == SalesGroup.product)
                      DataColumn(label: Text(l10n.stockUnits), numeric: true),
                    DataColumn(label: Text(l10n.reportsNet), numeric: true),
                    DataColumn(label: Text(l10n.reportsRefunds), numeric: true),
                    DataColumn(
                      label: Text(l10n.reportsNetSales),
                      numeric: true,
                    ),
                  ],
                ],
                rows: [
                  for (final x in rows)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(x == r.totals ? l10n.reportsTotal : x.label),
                        ),
                        if (tax) ...[
                          DataCell(Text(formatCents(x.baseCents ?? 0))),
                          DataCell(Text(formatCents(x.taxCents ?? 0))),
                        ] else ...[
                          DataCell(Text((x.saleCount).toString())),
                          if (r.groupBy == SalesGroup.product)
                            DataCell(Text((x.quantity ?? 0).toString())),
                          DataCell(Text(formatCents(x.netCents))),
                          DataCell(Text(formatCents(x.refundCents))),
                          DataCell(
                            Text(formatCents(x.netCents - x.refundCents)),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StockTab extends ConsumerStatefulWidget {
  const _StockTab({
    super.key,
    this.branchId,
    required this.from,
    required this.to,
  });

  final String? branchId;
  final String from;
  final String to;

  @override
  ConsumerState<_StockTab> createState() => _StockTabState();
}

class _StockTabState extends ConsumerState<_StockTab> {
  late final Future<StockReport> _data = ref
      .read(restClientProvider)
      .reports
      .getStockReport(
        from: widget.from,
        to: widget.to,
        branchId: widget.branchId,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        _exportButtons(context, ref, 'stock', {
          'from': widget.from,
          'to': widget.to,
          if (widget.branchId != null) 'branchId': widget.branchId!,
        }),
        const SizedBox(height: AppDimensions.paddingMedium),
        _loader(
          l10n,
          _data,
          (StockReport r) => Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                key: const Key('stock-table'),
                columns: [
                  DataColumn(label: Text(l10n.reportsProduct)),
                  DataColumn(label: Text(l10n.staffBranch)),
                  DataColumn(label: Text(l10n.reportsProduced), numeric: true),
                  DataColumn(label: Text(l10n.reportsSold), numeric: true),
                  DataColumn(label: Text(l10n.stockDayOld), numeric: true),
                  DataColumn(label: Text(l10n.stockWaste), numeric: true),
                  DataColumn(label: Text(l10n.reportsWasteCost), numeric: true),
                  DataColumn(label: Text(l10n.reportsOnHand), numeric: true),
                ],
                rows: [
                  for (final x in r.items)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            l10n.saleLineTitle(x.productName, x.variantName),
                          ),
                        ),
                        DataCell(Text(x.branchName)),
                        DataCell(Text((x.produced).toString())),
                        DataCell(Text((x.sold).toString())),
                        DataCell(Text((x.dayOldSold).toString())),
                        DataCell(Text((x.wasted).toString())),
                        DataCell(
                          Text(
                            x.wasteCostCents == null
                                ? '—'
                                : formatCents(x.wasteCostCents!),
                          ),
                        ),
                        DataCell(Text((x.onHand).toString())),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BalancesTab extends ConsumerStatefulWidget {
  const _BalancesTab({
    super.key,
    this.branchId,
    required this.from,
    required this.to,
  });

  final String? branchId;
  final String from;
  final String to;

  @override
  ConsumerState<_BalancesTab> createState() => _BalancesTabState();
}

class _BalancesTabState extends ConsumerState<_BalancesTab> {
  late final Future<OrdersReport> _data = ref
      .read(restClientProvider)
      .reports
      .getOrdersReport(
        from: widget.from,
        to: widget.to,
        branchId: widget.branchId,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        _exportButtons(context, ref, 'orders', {
          'from': widget.from,
          'to': widget.to,
          if (widget.branchId != null) 'branchId': widget.branchId!,
        }),
        const SizedBox(height: AppDimensions.paddingMedium),
        _loader(
          l10n,
          _data,
          (OrdersReport r) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final b in r.balances)
                ListTile(
                  key: Key('balance-${b.customerId}'),
                  title: Text(b.name),
                  subtitle: Text(b.phone ?? ''),
                  trailing: Text(
                    formatCents(b.balanceCents),
                    style: TextStyle(
                      color: b.balanceCents < 0 ? AppColors.alertRed : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
