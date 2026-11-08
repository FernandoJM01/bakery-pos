import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../../sale/domain/ticket.dart';
import '../../till_catalog/data/till_catalog_repository.dart';
import '../data/stock_repository.dart';
import '../../orders/data/orders_repository.dart';
import 'inventory_panel.dart';

/// Amounts on the quantity step: the baker's two taps (M5.1).
const unitAmounts = [6, 12, 24, 36, 48, 60];
const trayAmounts = [1, 2, 3, 4, 6, 8];

/// Producción: what comes out of the oven, and for managers Inventario.
class ProductionScreen extends ConsumerWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(tillSessionProvider);
    final inventory =
        session?.hasPermission('stock.waste') == true ||
        session?.hasPermission('stock.count_adjust') == true;
    if (!inventory) return const ProductionGrid();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(key: const Key('tab-production'), text: l10n.navProduction),
              Tab(key: const Key('tab-inventory'), text: l10n.stockInventory),
            ],
          ),
          const Expanded(
            child: TabBarView(children: [ProductionGrid(), InventoryPanel()]),
          ),
        ],
      ),
    );
  }
}

class ProductionGrid extends ConsumerWidget {
  const ProductionGrid({super.key});

  Future<void> _enter(
    BuildContext context,
    WidgetRef ref,
    GridProduct p,
    GridVariant v,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final tray = v.unitsPerTray;
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.stockHowMany(p.name)),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: [
                for (final n in tray == null ? unitAmounts : trayAmounts)
                  SizedBox(
                    width: 110,
                    height: AppDimensions.largeTouchTarget,
                    child: FilledButton(
                      key: Key('amount-$n'),
                      onPressed: () => Navigator.of(context).pop(n),
                      child: Text(tray == null ? '$n' : l10n.stockTrays(n)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    final staff = ref.read(tillSessionProvider)?.staff;
    if (amount == null || staff == null) return;
    final units = amount * (tray ?? 1);
    await ref
        .read(stockRepositoryProvider)
        .produce(
          variantId: v.id,
          quantity: units,
          staffId: staff.id,
          now: ref.read(saleClockProvider)(),
        );
    ref.invalidate(stockViewProvider);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.stockProduced(p.name, units))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = ref.watch(tillCatalogProvider);
    final stock = ref.watch(stockViewProvider).value ?? const {};
    final orders = ref.watch(orderTotalsProvider).value ?? const {};
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.gridEmpty)),
      data: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMedium,
                AppDimensions.paddingMedium,
                AppDimensions.paddingMedium,
                0,
              ),
              child: Card(
                key: const Key('orders-totals'),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ordersForToday,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final o in orders.values)
                        Text(l10n.ordersLine(o.name, o.quantity)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: GridView.extent(
              key: const Key('production-grid'),
              maxCrossAxisExtent: 200,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              crossAxisSpacing: AppDimensions.paddingSmall,
              mainAxisSpacing: AppDimensions.paddingSmall,
              childAspectRatio: 1.4,
              children: [
                for (final p in c.products)
                  for (final v in p.variants)
                    Card(
                      child: InkWell(
                        key: Key('produce-${v.id}'),
                        onTap: () => _enter(context, ref, p, v),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingSmall,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.variants.length == 1
                                    ? p.name
                                    : l10n.saleLineTitle(p.name, v.name),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(l10n.stockOnHand(stock[v.id]?.onHand ?? 0)),
                            ],
                          ),
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
