import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/lines2.dart';
import 'package:bakery_pos/core/api/generated/models/lines3.dart';
import 'package:bakery_pos/core/api/generated/models/stock_check.dart';
import 'package:bakery_pos/core/api/generated/models/stock_event.dart';
import 'package:bakery_pos/core/api/generated/models/stock_event_kind.dart';
import 'package:bakery_pos/core/api/generated/models/stock_level.dart';
import 'package:bakery_pos/core/api/generated/models/transfer.dart';
import 'package:bakery_pos/core/api/generated/models/transfer_create.dart';
import 'package:bakery_pos/core/api/generated/models/transfer_receive.dart';
import 'package:bakery_pos/core/api/generated/models/transfer_status.dart';
import 'package:bakery_pos/core/api/generated/models/waste_page.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _levelsProvider = FutureProvider.autoDispose<List<StockLevel>>((
  ref,
) async {
  final res = await ref.read(restClientProvider).stock.listStockLevels();
  return res.items;
});

final _checkProvider = FutureProvider.autoDispose<StockCheck>(
  (ref) => ref.read(restClientProvider).stock.latestStockCheck(),
);

final _transfersProvider = FutureProvider.autoDispose<List<Transfer>>((
  ref,
) async {
  final res = await ref.read(restClientProvider).stock.listTransfers();
  return res.items;
});

final _wasteProvider = FutureProvider.autoDispose<WastePage>(
  (ref) => ref.read(restClientProvider).stock.listWaste(),
);

String stockEventLabel(StockEventKind kind, AppLocalizations l10n) =>
    switch (kind) {
      StockEventKind.production => l10n.stockEventProduction,
      StockEventKind.sale => l10n.stockEventSale,
      StockEventKind.refundReturn => l10n.stockEventRefund,
      StockEventKind.waste => l10n.stockEventWaste,
      StockEventKind.transferOut => l10n.stockEventTransferOut,
      StockEventKind.transferIn => l10n.stockEventTransferIn,
      StockEventKind.countAdjust => l10n.stockEventCount,
      _ => kind.json ?? '—',
    };

String _wasteReason(String reason, AppLocalizations l10n) => switch (reason) {
  'BURNT' => l10n.wasteReasonBurnt,
  'EXPIRED' => l10n.wasteReasonExpired,
  'DAMAGED' => l10n.wasteReasonDamaged,
  _ => l10n.wasteReasonUnsold,
};

/// Back office Inventario (M5 brief 5): stock by branch with each product's
/// ledger, transfers, waste with its cost, and the last nightly check.
class StockAdminScreen extends ConsumerWidget {
  const StockAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.stockInventory),
          bottom: TabBar(
            tabs: [
              Tab(key: const Key('tab-levels'), text: l10n.stockByAge),
              Tab(key: const Key('tab-transfers'), text: l10n.stockTransfers),
              Tab(key: const Key('tab-waste'), text: l10n.stockWaste),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_LevelsTab(), _TransfersTab(), _WasteTab()],
        ),
      ),
    );
  }
}

class _LevelsTab extends ConsumerWidget {
  const _LevelsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final levels = ref.watch(_levelsProvider);
    final check = ref.watch(_checkProvider).value;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final names = {for (final b in branches) b.id: b.name};
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        if (check?.checkedAt != null)
          Text(
            check!.mismatches == 0
                ? l10n.stockCheckOk(formatAdminDateTime(check.checkedAt!))
                : l10n.stockCheckBad(check.mismatches),
            key: const Key('stock-check'),
            style: TextStyle(
              color: check.mismatches == 0 ? null : AppColors.alertRed,
            ),
          ),
        const SizedBox(height: AppDimensions.paddingSmall),
        levels.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AdminErrorBanner(message: commonAdminError(l10n, e)),
          data: (rows) => rows.isEmpty
              ? Center(
                  child: Text(l10n.stockEmpty, key: const Key('stock-empty')),
                )
              : Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(label: Text(l10n.stockProduct)),
                        DataColumn(label: Text(l10n.staffBranch)),
                        DataColumn(label: Text(l10n.stockFresh), numeric: true),
                        DataColumn(
                          label: Text(l10n.stockDayOld),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(l10n.stockWasteDue),
                          numeric: true,
                        ),
                        DataColumn(label: Text(l10n.stockTotal), numeric: true),
                      ],
                      rows: [
                        for (final s in rows)
                          DataRow(
                            key: ValueKey('level-${s.branchId}-${s.variantId}'),
                            onSelectChanged: (_) => showDialog<void>(
                              context: context,
                              builder: (_) => _LedgerDialog(level: s),
                            ),
                            cells: [
                              DataCell(
                                Text(
                                  l10n.saleLineTitle(
                                    s.productName,
                                    s.variantName,
                                  ),
                                ),
                              ),
                              DataCell(Text(names[s.branchId] ?? '—')),
                              DataCell(Text(s.freshUnits.toString())),
                              DataCell(Text(s.dayOldUnits.toString())),
                              DataCell(Text(s.wasteDueUnits.toString())),
                              DataCell(
                                Text(
                                  s.onHand.toString(),
                                  style: s.onHand < 0
                                      ? const TextStyle(
                                          color: AppColors.alertRed,
                                        )
                                      : null,
                                ),
                              ),
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

class _LedgerDialog extends ConsumerWidget {
  const _LedgerDialog({required this.level});

  final StockLevel level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.saleLineTitle(level.productName, level.variantName)),
      content: SizedBox(
        width: 460,
        height: 420,
        child: FutureBuilder<List<StockEvent>>(
          future: ref
              .read(restClientProvider)
              .stock
              .listStockEvents(
                branchId: level.branchId,
                variantId: level.variantId,
              )
              .then((p) => p.items),
          builder: (context, snap) {
            if (snap.hasError) {
              return AdminErrorBanner(
                message: commonAdminError(l10n, snap.error!),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              key: const Key('ledger'),
              children: [
                for (final e in snap.data!)
                  ListTile(
                    dense: true,
                    title: Text(stockEventLabel(e.kind, l10n)),
                    subtitle: Text(formatAdminDateTime(e.occurredAt)),
                    trailing: Text(e.quantity.toString()),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

class _TransfersTab extends ConsumerWidget {
  const _TransfersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transfers = ref.watch(_transfersProvider);
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final names = {for (final b in branches) b.id: b.name};
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const Key('transfer-new'),
            icon: const Icon(Icons.local_shipping_outlined),
            label: Text(l10n.stockSendTransfer),
            onPressed: () async {
              await showDialog<void>(
                context: context,
                builder: (_) => const _SendDialog(),
              );
              ref
                ..invalidate(_transfersProvider)
                ..invalidate(_levelsProvider);
            },
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        transfers.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AdminErrorBanner(message: commonAdminError(l10n, e)),
          data: (rows) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (rows.isEmpty) Center(child: Text(l10n.stockNoTransfers)),
              for (final t in rows)
                Card(
                  child: ListTile(
                    key: Key('transfer-${t.id}'),
                    leading: t.flagged
                        ? Icon(
                            Icons.flag,
                            color: AppColors.alertRed,
                            semanticLabel: l10n.stockTransferFlagged,
                          )
                        : null,
                    title: Text(
                      l10n.stockTransferLine(
                        names[t.fromBranchId] ?? '—',
                        names[t.toBranchId] ?? '—',
                      ),
                    ),
                    subtitle: Text(
                      [
                        for (final l in t.lines)
                          l10n.stockTransferUnits(
                            l.productName,
                            l.quantityReceived?.toString() ?? '—',
                            l.quantitySent,
                          ),
                      ].join(' · '),
                    ),
                    trailing: t.status == TransferStatus.sent
                        ? TextButton(
                            key: Key('receive-${t.id}'),
                            onPressed: () async {
                              await showDialog<void>(
                                context: context,
                                builder: (_) => _ReceiveDialog(transfer: t),
                              );
                              ref
                                ..invalidate(_transfersProvider)
                                ..invalidate(_levelsProvider);
                            },
                            child: Text(l10n.stockReceive),
                          )
                        : Text(formatAdminDateTime(t.receivedAt!)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SendDialog extends ConsumerStatefulWidget {
  const _SendDialog();

  @override
  ConsumerState<_SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends ConsumerState<_SendDialog> {
  String? _from;
  String? _to;
  final _fields = <String, TextEditingController>{};
  String? _error;

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final lines = [
      for (final e in _fields.entries)
        if ((int.tryParse(e.value.text) ?? 0) > 0)
          Lines2(variantId: e.key, quantity: int.parse(e.value.text)),
    ];
    if (_from == null || _to == null || _from == _to || lines.isEmpty) {
      setState(() => _error = l10n.stockTransferIncomplete);
      return;
    }
    try {
      await ref
          .read(restClientProvider)
          .stock
          .sendTransfer(
            body: TransferCreate(
              fromBranchId: _from!,
              toBranchId: _to!,
              lines: lines,
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = apiErrorCode(e) == 'CONFLICT'
              ? l10n.stockNotEnough
              : commonAdminError(l10n, e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];
    final levels = ref.watch(_levelsProvider).value ?? const <StockLevel>[];
    final mine = levels.where((s) => s.branchId == _from && s.onHand > 0);
    Widget pick(String label, String key, ValueChanged<String?> set) =>
        DropdownButtonFormField<String>(
          key: Key(key),
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final b in branches)
              DropdownMenuItem(value: b.id, child: Text(b.name)),
          ],
          onChanged: set,
        );
    return AlertDialog(
      title: Text(l10n.stockSendTransfer),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              pick(
                l10n.stockFromBranch,
                'transfer-from',
                (v) => setState(() => _from = v),
              ),
              pick(
                l10n.stockToBranch,
                'transfer-to',
                (v) => setState(() => _to = v),
              ),
              for (final s in mine)
                TextField(
                  key: Key('transfer-${s.variantId}'),
                  controller: _fields[s.variantId] ??= TextEditingController(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.stockTransferField(
                      l10n.saleLineTitle(s.productName, s.variantName),
                      s.onHand,
                    ),
                  ),
                ),
              if (_error != null)
                Text(
                  _error!,
                  key: const Key('transfer-error'),
                  style: const TextStyle(color: AppColors.alertRed),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('transfer-send'),
          onPressed: _send,
          child: Text(l10n.stockSendTransfer),
        ),
      ],
    );
  }
}

class _ReceiveDialog extends ConsumerStatefulWidget {
  const _ReceiveDialog({required this.transfer});

  final Transfer transfer;

  @override
  ConsumerState<_ReceiveDialog> createState() => _ReceiveDialogState();
}

class _ReceiveDialogState extends ConsumerState<_ReceiveDialog> {
  late final _fields = [
    for (final l in widget.transfer.lines)
      TextEditingController(text: l.quantitySent.toString()),
  ];
  String? _error;

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _receive() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(restClientProvider)
          .stock
          .receiveTransfer(
            transferId: widget.transfer.id,
            body: TransferReceive(
              lines: [
                for (final (i, l) in widget.transfer.lines.indexed)
                  Lines3(
                    variantId: l.variantId,
                    producedOn: l.producedOn,
                    quantityReceived: int.tryParse(_fields[i].text) ?? 0,
                  ),
              ],
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = commonAdminError(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.stockReceive),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.stockReceiveHint),
              for (final (i, l) in widget.transfer.lines.indexed)
                TextField(
                  key: Key('receive-line-$i'),
                  controller: _fields[i],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.stockReceiveField(
                      l10n.saleLineTitle(l.productName, l.variantName),
                      l.quantitySent,
                    ),
                  ),
                ),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.alertRed),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('receive-save'),
          onPressed: _receive,
          child: Text(l10n.stockReceive),
        ),
      ],
    );
  }
}

class _WasteTab extends ConsumerWidget {
  const _WasteTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(_wasteProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AdminErrorBanner(message: commonAdminError(l10n, e)),
          data: (page) => ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              Text(
                l10n.stockWasteTotal(formatCents(page.totalCostCents)),
                key: const Key('waste-total'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (page.items.isEmpty) Center(child: Text(l10n.stockNoWaste)),
              for (final w in page.items)
                ListTile(
                  key: Key('waste-${w.id}'),
                  title: Text(l10n.saleLineTitle(w.productName, w.variantName)),
                  subtitle: Text(
                    l10n.stockWasteLine(
                      _wasteReason(w.reason.json ?? w.reason.name, l10n),
                      formatAdminDateTime(w.occurredAt),
                      w.quantity,
                    ),
                  ),
                  trailing: Text(
                    w.costCents == null
                        ? '—'
                        : formatCents(w.costCents! * w.quantity),
                  ),
                ),
            ],
          ),
        );
  }
}
