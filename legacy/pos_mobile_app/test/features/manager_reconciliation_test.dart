import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';
import 'package:pos_mobile_app/features/inventory/domain/ledger_event.dart';
import 'package:pos_mobile_app/features/inventory/data/inventory_repository.dart';
import 'package:pos_mobile_app/features/inventory/presentation/manager_reconciliation_screen.dart';

class MockInventoryRepository implements InventoryRepository {
  final List<LedgerEvent> recordedEvents = [];

  @override
  Future<int> getStock(String productId) async => 10;

  @override
  Future<Map<String, int>> getAllBalances() async => {};

  @override
  Future<void> recordEventAndUpdateStock(LedgerEvent event) async {
    recordedEvents.add(event);
  }

  @override
  Future<void> setBalances(Map<String, int> balances) async {}
}

void main() {
  testWidgets('ManagerReconciliationScreen calculates counts and variances accurately in Spanish', (tester) async {
    final mockRepo = MockInventoryRepository();

    const testManager = User(
      id: 'b0000000-0000-0000-0000-000000000003',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'manager1',
      pinHash: 'test',
      fullName: 'Elena Rostova',
      role: UserRole.branchManager,
    );

    // Set tablet-friendly viewport
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: ManagerReconciliationScreen(manager: testManager),
        ),
      ),
    );

    await tester.pump();

    // Verify Manager Header
    expect(find.text('Elena Rostova (Gerencia)'), findsOneWidget);

    // Verify Cash Baseline Elements
    expect(find.text('Fondo de Caja Inicial'), findsOneWidget);
    expect(find.text('\$200.00'), findsWidgets);
    expect(find.text('\$745.50'), findsOneWidget);
    expect(find.text('\$945.50'), findsWidgets);

    // Verify Balanced Drawer
    expect(find.text('Caja Cuadrada'), findsOneWidget);

    // Increment $100 bills count with '+'
    final plusIcons = find.byIcon(Icons.add_circle_outline_rounded);
    expect(plusIcons, findsWidgets);

    // Tap first '+' button ($100 bills)
    await tester.tap(plusIcons.first);
    await tester.pump();

    // Now drawer is $1045.50, variance is +$100.00
    expect(find.text('Sobrante en Caja'), findsOneWidget);
    expect(find.text('+\$100.00'), findsOneWidget);

    // Verify Print Z-Report action
    final printButton = find.text('Imprimir Reporte Z');
    expect(printButton, findsOneWidget);
    await tester.tap(printButton);
    await tester.pumpAndSettle();

    // Wait for state update
    await tester.pump(const Duration(seconds: 1));

    // Verify Close Shift button
    final closeShiftButton = find.text('CERRAR TURNO');
    expect(closeShiftButton, findsOneWidget);
    await tester.tap(closeShiftButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify dialog appears
    expect(find.text('Turno Cerrado y Caja Bloqueada'), findsOneWidget);

    // Verify audit event is recorded in repository
    expect(mockRepo.recordedEvents.length, 1);
    expect(mockRepo.recordedEvents.first.eventType, LedgerEventType.auditAdjustment);
    expect(mockRepo.recordedEvents.first.metadata?['reason'], 'SHIFT_CLOSE_RECONCILIATION');
  });
}
