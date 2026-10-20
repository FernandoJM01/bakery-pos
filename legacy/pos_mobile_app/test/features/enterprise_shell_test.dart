import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';
import 'package:pos_mobile_app/features/shell/presentation/enterprise_shell_screen.dart';

void main() {
  group('Enterprise Shell & Left Sidebar Navigation Tests', () {
    const testAdmin = User(
      id: 'b0000000-0000-0000-0000-000000000003',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'manager1',
      pinHash: 'test',
      fullName: 'Elena Rostova',
      role: UserRole.branchManager,
    );

    testWidgets('Renders Left Sidebar navigation items and switches sections', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EnterpriseShellScreen(user: testAdmin),
          ),
        ),
      );

      await tester.pump();

      // Check Branding & Left Panel Items
      expect(find.text('MIGA & HORNO'), findsOneWidget);
      expect(find.text('Panadería Artesanal'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('POS Caja'), findsOneWidget);
      expect(find.text('Catálogo & Sabores'), findsOneWidget);
      expect(find.text('Horno & Producción'), findsOneWidget);
      expect(find.text('Personal & Roles'), findsOneWidget);
      expect(find.text('Cortes Z & Turnos'), findsOneWidget);

      // Tap on Horno & Producción
      await tester.tap(find.text('Horno & Producción'));
      await tester.pumpAndSettle();

      expect(find.text('Consola de Horno & Hojas de Horneado'), findsOneWidget);

      // Tap on Personal & Roles
      await tester.tap(find.text('Personal & Roles'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Empleado'), findsOneWidget);

      // Tap on logout icon to verify safe logout dialog
      final logoutBtn = find.byIcon(Icons.logout_rounded);
      expect(logoutBtn, findsOneWidget);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Verify safe logout confirmation dialog
      expect(find.text('Cerrar Sesión'), findsWidgets);
      expect(find.textContaining('¿Estás seguro de que deseas salir del sistema?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // Cancel logout
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.textContaining('¿Estás seguro de que deseas salir del sistema?'), findsNothing);
    });
  });
}
