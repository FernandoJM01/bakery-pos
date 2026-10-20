import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/domain/ledger_event.dart';
import '../../inventory/presentation/stock_notifier.dart';
import '../domain/bake_batch.dart';

class BakeSheetState {
  final List<BakeBatch> batches;

  const BakeSheetState({required this.batches});

  BakeSheetState copyWith({List<BakeBatch>? batches}) {
    return BakeSheetState(batches: batches ?? this.batches);
  }
}

class BakeSheetNotifier extends StateNotifier<BakeSheetState> {
  final Ref _ref;

  BakeSheetNotifier(this._ref)
      : super(
          const BakeSheetState(
            batches: [
              BakeBatch(
                id: 'batch-001',
                batchNumber: 'H-201',
                productName: 'Conchas Tradicionales (Vainilla & Chocolate)',
                productSku: 'PAST-CONC',
                ovenName: 'Horno Rotativo 1',
                targetUnits: 48,
                completedUnits: 0,
                wasteUnits: 0,
                status: BakeBatchStatus.baking,
                tempCelsius: 185,
                minutesRemaining: 12,
                scheduledShift: 'Turno Matutino 06:00',
              ),
              BakeBatch(
                id: 'batch-002',
                batchNumber: 'H-202',
                productName: 'Hogaza de Masa Madre (Sourdough)',
                productSku: 'BREAD-SOUR',
                ovenName: 'Horno de Piedra 2',
                targetUnits: 24,
                completedUnits: 0,
                wasteUnits: 0,
                status: BakeBatchStatus.baking,
                tempCelsius: 235,
                minutesRemaining: 24,
                scheduledShift: 'Turno Matutino 06:00',
              ),
              BakeBatch(
                id: 'batch-003',
                batchNumber: 'H-203',
                productName: 'Baguette Tradicional Rústica',
                productSku: 'BREAD-BAGU',
                ovenName: 'Horno de Piedra 2',
                targetUnits: 30,
                completedUnits: 28,
                wasteUnits: 2,
                wasteReason: 'Quemado / Sobrehorneado',
                status: BakeBatchStatus.readyInShowcase,
                tempCelsius: 240,
                minutesRemaining: 0,
                scheduledShift: 'Turno Matutino 06:00',
              ),
              BakeBatch(
                id: 'batch-004',
                batchNumber: 'H-204',
                productName: 'Croissant de Mantequilla',
                productSku: 'PAST-CROI',
                ovenName: 'Horno Rotativo 1',
                targetUnits: 36,
                completedUnits: 0,
                wasteUnits: 0,
                status: BakeBatchStatus.fermenting,
                tempCelsius: 190,
                minutesRemaining: 45,
                scheduledShift: 'Turno Vespertino 15:00',
              ),
            ],
          ),
        );

  void addBatch({
    required String productName,
    required String productSku,
    required String ovenName,
    required int targetUnits,
    required int tempCelsius,
    required int bakeDurationMinutes,
    required String shift,
  }) {
    final nextNumber = 'H-${200 + state.batches.length + 1}';
    final newBatch = BakeBatch(
      id: 'batch-${DateTime.now().millisecondsSinceEpoch}',
      batchNumber: nextNumber,
      productName: productName,
      productSku: productSku,
      ovenName: ovenName,
      targetUnits: targetUnits,
      tempCelsius: tempCelsius,
      minutesRemaining: bakeDurationMinutes,
      scheduledShift: shift,
      status: BakeBatchStatus.fermenting,
    );

    state = state.copyWith(batches: [newBatch, ...state.batches]);
  }

  void advanceBatchStatus(String batchId) {
    final current = state.batches.firstWhere((b) => b.id == batchId);
    BakeBatchStatus nextStatus;
    int nextRemaining = current.minutesRemaining;

    switch (current.status) {
      case BakeBatchStatus.fermenting:
        nextStatus = BakeBatchStatus.baking;
        nextRemaining = 15;
        break;
      case BakeBatchStatus.baking:
        nextStatus = BakeBatchStatus.cooling;
        nextRemaining = 5;
        break;
      case BakeBatchStatus.cooling:
        nextStatus = BakeBatchStatus.readyInShowcase;
        nextRemaining = 0;
        final finalUnits = current.targetUnits - current.wasteUnits;

        // Agregar stock a la vitrina
        _ref.read(stockNotifierProvider.notifier).recordEvent(
              LedgerEvent(
                clientEventId: 'evt-${DateTime.now().millisecondsSinceEpoch}',
                branchId: 'a0000000-0000-0000-0000-000000000001',
                terminalId: 'OVEN-01',
                eventType: LedgerEventType.bakeBatchProduced,
                userId: 'baker1',
                productId: current.productSku == 'PAST-CONC'
                    ? 'c0000000-0000-0000-0000-000000000005'
                    : 'c0000000-0000-0000-0000-000000000001',
                quantityChange: finalUnits,
                clientTimestamp: DateTime.now(),
              ),
            );
        break;
      case BakeBatchStatus.readyInShowcase:
        return;
    }

    final updated = current.copyWith(
      status: nextStatus,
      minutesRemaining: nextRemaining,
      completedUnits: nextStatus == BakeBatchStatus.readyInShowcase ? current.targetUnits - current.wasteUnits : current.completedUnits,
    );

    state = state.copyWith(
      batches: state.batches.map((b) => b.id == batchId ? updated : b).toList(),
    );
  }

  void recordWaste(String batchId, int units, String reason) {
    final current = state.batches.firstWhere((b) => b.id == batchId);
    final updated = current.copyWith(
      wasteUnits: units,
      wasteReason: reason,
      completedUnits: current.targetUnits - units,
    );

    state = state.copyWith(
      batches: state.batches.map((b) => b.id == batchId ? updated : b).toList(),
    );
  }
}

final bakeSheetProvider = StateNotifierProvider<BakeSheetNotifier, BakeSheetState>((ref) {
  return BakeSheetNotifier(ref);
});
