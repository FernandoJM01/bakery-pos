import 'package:bakery_pos/features/audit/presentation/audit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../admin_test_harness.dart';

void main() {
  testWidgets('shows entries in Spanish with names and pages with the cursor', (
    tester,
  ) async {
    await pumpAdminScreen(tester, const AuditScreen());

    expect(find.text('PIN cambiado'), findsOneWidget);
    expect(find.text('Autorización de gerente concedida'), findsOneWidget);
    expect(
      find.text('Ana · autorizó Fernando · Sucursal Centro'),
      findsOneWidget,
    );
    expect(find.text('Dispositivo registrado'), findsNothing);

    await tapKey(tester, 'audit-load-more');
    expect(find.text('Dispositivo registrado'), findsOneWidget);
    expect(find.byKey(const Key('audit-load-more')), findsNothing);
  });

  testWidgets('filters by action', (tester) async {
    await pumpAdminScreen(tester, const AuditScreen());

    await tapKey(tester, 'audit-action-filter');
    await tester.tap(find.text('Dispositivo registrado').last);
    await tester.pumpAndSettle();
    expect(find.text('Dispositivo registrado'), findsWidgets);
    expect(find.text('PIN cambiado'), findsNothing);
  });

  testWidgets('filters by person, as actor or approver', (tester) async {
    await pumpAdminScreen(tester, const AuditScreen());

    await tapKey(tester, 'audit-staff-filter');
    await tester.tap(find.text('Ana').last);
    await tester.pumpAndSettle();
    expect(find.text('Autorización de gerente concedida'), findsOneWidget);
    expect(find.text('PIN cambiado'), findsNothing);
  });

  testWidgets('shows the details of an entry', (tester) async {
    await pumpAdminScreen(tester, const AuditScreen());
    await tester.tap(find.text('Autorización de gerente concedida'));
    await tester.pumpAndSettle();
    expect(find.textContaining('sale.refund'), findsOneWidget);
  });
}
