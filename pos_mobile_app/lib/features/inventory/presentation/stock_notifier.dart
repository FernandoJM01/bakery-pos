import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_repository.dart';
import '../domain/ledger_event.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});

class StockNotifier extends StateNotifier<Map<String, int>> {
  final InventoryRepository _repo;

  StockNotifier(this._repo) : super(InventoryRepositoryImpl.fallbackBalances) {
    loadStock();
  }

  Future<void> loadStock() async {
    final balances = await _repo.getAllBalances();
    state = balances;
  }

  int getStockFor(String productId) {
    return state[productId] ?? 0;
  }

  Future<void> recordEvent(LedgerEvent event) async {
    // 1. Optimistic immediate state update for 60fps UI
    final current = state[event.productId] ?? 0;
    state = {
      ...state,
      event.productId: current + event.quantityChange,
    };

    // 2. Local SQLite persistent write
    await _repo.recordEventAndUpdateStock(event);
  }
}

final stockNotifierProvider = StateNotifierProvider<StockNotifier, Map<String, int>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return StockNotifier(repo);
});
