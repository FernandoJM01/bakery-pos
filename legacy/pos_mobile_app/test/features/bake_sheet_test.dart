import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/features/baking/domain/bake_batch.dart';
import 'package:pos_mobile_app/features/baking/presentation/bake_sheet_notifier.dart';
import 'package:pos_mobile_app/features/baking/presentation/bake_sheet_console_view.dart';

void main() {
  group('Bake Sheet & Production Console Tests', () {
    test('BakeSheetNotifier advances status through baking lifecycle and logs waste', () {
      final container = ProviderContainer();
      final notifier = container.read(bakeSheetProvider.notifier);

      // Start a new batch
      notifier.addBatch(
        productName: 'Donas Artesanales Glaseadas',
        productSku: 'PAST-DONA',
        ovenName: 'Horno Convector 3',
        targetUnits: 36,
        tempCelsius: 175,
        bakeDurationMinutes: 12,
        shift: 'Turno Matutino 06:00',
      );

      final state1 = container.read(bakeSheetProvider);
      final newBatch = state1.batches.firstWhere((b) => b.productName == 'Donas Artesanales Glaseadas');
      expect(newBatch.status, BakeBatchStatus.fermenting);

      // Advance: Fermenting -> Baking
      notifier.advanceBatchStatus(newBatch.id);
      expect(container.read(bakeSheetProvider).batches.firstWhere((b) => b.id == newBatch.id).status, BakeBatchStatus.baking);

      // Record waste for another batch
      final batch1 = state1.batches.firstWhere((b) => b.id == 'batch-001');
      notifier.recordWaste(batch1.id, 3, 'Quemado / Sobrehorneado');
      final updatedBatch1 = container.read(bakeSheetProvider).batches.firstWhere((b) => b.id == 'batch-001');
      expect(updatedBatch1.wasteUnits, 3);
      expect(updatedBatch1.wasteReason, 'Quemado / Sobrehorneado');
    });

    testWidgets('BakeSheetConsoleView renders oven cards and scheduled batches', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BakeSheetConsoleView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Consola de Horno & Hojas de Horneado'), findsOneWidget);
      expect(find.text('Horno Rotativo 1'), findsWidgets);
      expect(find.text('Horno de Piedra 2'), findsWidgets);
      expect(find.text('Programar Hornada'), findsOneWidget);
      expect(find.text('H-201'), findsOneWidget);
    });
  });
}
