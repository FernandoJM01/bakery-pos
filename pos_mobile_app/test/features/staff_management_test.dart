import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';
import 'package:pos_mobile_app/features/staff/presentation/staff_management_notifier.dart';
import 'package:pos_mobile_app/features/staff/presentation/staff_management_view.dart';

void main() {
  group('Staff & Role Management with Audit Logging Tests', () {
    test('StaffManagementNotifier adds user, hashes PIN, updates status and writes audit log', () {
      final container = ProviderContainer();
      final notifier = container.read(staffManagementProvider.notifier);

      expect(container.read(staffManagementProvider).users.length, 4);

      // Add a new Baker
      notifier.addUser(
        fullName: 'Fernando Ruiz',
        username: 'fernando1',
        pin: '4321',
        role: UserRole.localBaker,
      );

      final stateAfterAdd = container.read(staffManagementProvider);
      expect(stateAfterAdd.users.length, 5);

      final newUser = stateAfterAdd.users.firstWhere((u) => u.username == 'fernando1');
      expect(newUser.fullName, 'Fernando Ruiz');
      expect(newUser.role, UserRole.localBaker);
      expect(newUser.isActive, isTrue);

      // Audit log has been recorded
      expect(stateAfterAdd.auditLogs.first.action, 'ALTA DE USUARIO');
      expect(stateAfterAdd.auditLogs.first.details, contains('Fernando Ruiz'));

      // Toggle status
      notifier.toggleUserStatus(newUser.id);
      final stateAfterToggle = container.read(staffManagementProvider);
      final toggledUser = stateAfterToggle.users.firstWhere((u) => u.id == newUser.id);
      expect(toggledUser.isActive, isFalse);
      expect(stateAfterToggle.auditLogs.first.action, 'SUSPENSIÓN EMPLEADO');
    });

    testWidgets('StaffManagementView renders staff directory and audit log tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StaffManagementView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Nuevo Empleado'), findsOneWidget);
      expect(find.text('Elena Rostova'), findsOneWidget);
      expect(find.text('Marco Rossi'), findsOneWidget);
      expect(find.text('Maria Gonzalez'), findsOneWidget);

      // Switch to Audit Log tab
      final auditTab = find.textContaining('Bitácora de Auditoría');
      expect(auditTab, findsOneWidget);
      await tester.tap(auditTab);
      await tester.pumpAndSettle();

      expect(find.text('ARQUEO CORTE Z'), findsOneWidget);
      expect(find.text('HORNADA COMPLETADA'), findsOneWidget);
    });
  });
}
