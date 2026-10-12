import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';
import 'package:pos_mobile_app/features/admin_dashboard/presentation/admin_dashboard_screen.dart';

void main() {
  testWidgets('AdminDashboardScreen renders KPIs, catalog management and promotions correctly', (tester) async {
    const testAdmin = User(
      id: 'b0000000-0000-0000-0000-000000000003',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: 'manager1',
      pinHash: 'test',
      fullName: 'Elena Rostova',
      role: UserRole.branchManager,
    );

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminDashboardScreen(admin: testAdmin),
        ),
      ),
    );

    await tester.pump();

    // Verify Executive Title & KPIs
    expect(find.text('PANADERÍA ARTESANAL • BACKOFFICE EJECUTIVO'), findsOneWidget);
    expect(find.text('VENTAS DEL DÍA'), findsOneWidget);
    expect(find.text('\$1,450.00'), findsOneWidget);
    expect(find.text('TICKET PROMEDIO'), findsOneWidget);
    expect(find.text('\$8.40'), findsOneWidget);

    // Verify Tab Switching to Catalog & Prices
    final catalogTab = find.text('Catálogo y Precios');
    expect(catalogTab, findsOneWidget);
    await tester.tap(catalogTab);
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Producto'), findsOneWidget);
    expect(find.text('Sourdough Country Loaf'), findsOneWidget);

    // Tap Nuevo Producto to open modal
    await tester.tap(find.text('Nuevo Producto'));
    await tester.pumpAndSettle();

    expect(find.text('Crear Nuevo Producto'), findsOneWidget);
    expect(find.text('Nombre del Producto'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Open Promotions Modal
    final promoButton = find.text('Combos y Promociones');
    expect(promoButton, findsOneWidget);
    await tester.tap(promoButton);
    await tester.pumpAndSettle();

    expect(find.text('Combos y Descuentos'), findsOneWidget);
    expect(find.text('Combo Desayuno Artesanal'), findsOneWidget);
  });
}
