import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';
import 'package:pos_mobile_app/features/inventory/data/inventory_repository.dart';
import 'package:pos_mobile_app/features/inventory/domain/ledger_event.dart';
import 'package:pos_mobile_app/features/inventory/presentation/manager_reconciliation_screen.dart';

class MockInventoryRepo implements InventoryRepository {
  final List<LedgerEvent> recordedEvents = [];

  @override
  Future<Map<String, int>> getAllBalances() async => {};

  @override
  Future<int> getStock(String productId) async => 50;

  @override
  Future<void> recordEventAndUpdateStock(LedgerEvent event) async {
    recordedEvents.add(event);
  }

  @override
  Future<void> setBalances(Map<String, int> balances) async {}
}

void main() {
  testWidgets('ManagerReconciliationScreen calculates counts and variances accurately', (WidgetTester tester) async {
    final mockRepo = MockInventoryRepo();
    final testManager = const User(
      id: 'b0000000-0000-0000-0000-000000000003',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'manager1',
      pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
      fullName: 'Elena Rostova',
      role: UserRole.branchManager,
    );

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: ManagerReconciliationScreen(manager: testManager),
        ),
      ),
    );

    await tester.pump();

    // Verify Header Elements
    expect(find.text('MANAGER RECONCILIATION'), findsOneWidget);
    expect(find.text('Elena Rostova'), findsOneWidget);
    expect(find.text('• Store Manager'), findsOneWidget);

    // Verify Cash Drawer Baseline ($200 float + $745.50 cash sales = $945.50)
    expect(find.text('OPENING FLOAT'), findsOneWidget);
    expect(find.text('\$200.00'), findsWidgets);
    expect(find.text('\$745.50'), findsOneWidget);
    expect(find.text('\$945.50'), findsWidgets);

    // Verify Default Drawer count calculation:
    // (5x$100 = 500) + (4x$50 = 200) + (8x$20 = 160) + (6x$10 = 60) + (4x$5 = 20) + (5x$1 = 5) + (5x$0.10 = 0.50) = $945.50
    expect(find.text('BALANCED (\$0.00)'), findsOneWidget);

    // Increment $100 bills count with '+'
    final plusIcons = find.byIcon(Icons.add);
    expect(plusIcons, findsWidgets);

    // Tap first '+' button ($100 bills)
    await tester.tap(plusIcons.first);
    await tester.pump();

    // Now drawer is $1045.50, variance is +$100.00
    expect(find.text('+ OVER \$100.00'), findsOneWidget);

    // Verify Print Z-Report action
    final printButton = find.text('PRINT Z-REPORT');
    expect(printButton, findsOneWidget);
    await tester.tap(printButton);
    await tester.pumpAndSettle();

    expect(find.text('Z-REPORT PRINTED'), findsOneWidget);

    // Wait for snackbar to finish/hide if any
    await tester.pump(const Duration(seconds: 3));

    // Verify Close Shift button
    final closeShiftButton = find.text('LOCK DRAWER & CLOSE SHIFT');
    expect(closeShiftButton, findsOneWidget);
    await tester.tap(closeShiftButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify dialog appears
    expect(find.text('Shift Closed & Drawer Locked'), findsOneWidget);

    // Verify audit event is recorded in repository
    expect(mockRepo.recordedEvents.length, 1);
    expect(mockRepo.recordedEvents.first.eventType, LedgerEventType.auditAdjustment);
    expect(mockRepo.recordedEvents.first.metadata?['reason'], 'SHIFT_CLOSE_RECONCILIATION');
  });
}
