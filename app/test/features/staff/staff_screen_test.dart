import 'package:bakery_pos/features/staff/presentation/staff_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../admin_test_harness.dart';

void main() {
  const ownerId = '0192e2b0-0010-7000-8000-000000000010';
  const cashierId = '0192e2b0-0030-7000-8000-000000000030';

  testWidgets('lists staff with role and branch names, filters by role', (
    tester,
  ) async {
    await pumpAdminScreen(tester, const StaffScreen());

    expect(find.byKey(const Key('staff-table')), findsOneWidget);
    expect(find.text('Fernando Dueño'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Dueño'), findsOneWidget);
    expect(find.text('Sucursal Centro, Sucursal Norte'), findsOneWidget);

    await tapKey(tester, 'staff-role-filter');
    await tester.tap(find.text('Cajero').last);
    await tester.pumpAndSettle();
    expect(find.text('Fernando Dueño'), findsNothing);
    expect(find.text('Ana Pérez'), findsOneWidget);
  });

  testWidgets('A5: creates a cashier with the PIN typed twice', (tester) async {
    final api = await pumpAdminScreen(tester, const StaffScreen());

    await tapKey(tester, 'create-staff-button');
    await tapKey(tester, 'save-staff-button');
    expect(find.text('Elige al menos una sucursal'), findsOneWidget);
    expect(find.text('El PIN debe tener de 4 a 6 dígitos'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('staff-fullname-input')),
      'Luis Martínez',
    );
    await tester.enterText(
      find.byKey(const Key('staff-displayname-input')),
      'Luis',
    );
    await tapKey(tester, 'staff-branch-SUC2');
    await tester.enterText(find.byKey(const Key('staff-pin-input')), '2468');
    await tester.enterText(
      find.byKey(const Key('staff-pin-confirm-input')),
      '2469',
    );
    await tapKey(tester, 'save-staff-button');
    expect(find.text('Los PIN no coinciden'), findsOneWidget);
    // Cashiers never get back-office credentials.
    expect(find.byKey(const Key('staff-email-input')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('staff-pin-confirm-input')),
      '2468',
    );
    await tapKey(tester, 'save-staff-button');

    expect(find.text('Persona agregada'), findsOneWidget);
    expect(find.text('Luis Martínez'), findsOneWidget);
    final created = api.staff.last;
    expect(created['role'], 'CASHIER');
    expect(created['branchIds'], ['0192e2b0-0002-7000-8000-000000000002']);
    expect(created.containsKey('email'), isFalse);
  });

  testWidgets('owner needs email and a 10+ character password; duplicate '
      'email shows the Spanish 409 message', (tester) async {
    await pumpAdminScreen(tester, const StaffScreen());

    await tapKey(tester, 'create-staff-button');
    await tester.enterText(
      find.byKey(const Key('staff-fullname-input')),
      'Socia Dueña',
    );
    await tester.enterText(
      find.byKey(const Key('staff-displayname-input')),
      'Socia',
    );
    await tapKey(tester, 'staff-role-input');
    await tester.tap(find.text('Dueño').last);
    await tester.pumpAndSettle();
    await tapKey(tester, 'staff-branch-SUC1');
    await tester.enterText(find.byKey(const Key('staff-pin-input')), '1357');
    await tester.enterText(
      find.byKey(const Key('staff-pin-confirm-input')),
      '1357',
    );
    await tapKey(tester, 'save-staff-button');
    expect(
      find.text('El correo es obligatorio para entrar a la administración'),
      findsOneWidget,
    );
    expect(find.text('El dueño necesita contraseña'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('staff-email-input')),
      'owner@bakery.com',
    );
    await tester.enterText(
      find.byKey(const Key('staff-password-input')),
      'corta',
    );
    await tapKey(tester, 'save-staff-button');
    expect(
      find.text('La contraseña debe tener al menos 10 caracteres'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('staff-password-input')),
      'SociaPass123!',
    );
    await tapKey(tester, 'save-staff-button');
    expect(find.text('Ese correo ya lo usa otra persona'), findsOneWidget);
  });

  testWidgets('the last owner cannot be deactivated; a cashier can, after '
      'confirming', (tester) async {
    final api = await pumpAdminScreen(tester, const StaffScreen());

    await tapKey(tester, 'toggle-staff-$ownerId');
    expect(find.text('¿Dar de baja a Fernando?'), findsOneWidget);
    await tapKey(tester, 'confirm-accept-button');
    expect(
      find.text('No se puede: debe quedar al menos un dueño activo'),
      findsOneWidget,
    );

    await tapKey(tester, 'toggle-staff-$cashierId');
    await tapKey(tester, 'confirm-cancel-button');
    expect(api.staff[1]['isActive'], isTrue);

    await tapKey(tester, 'toggle-staff-$cashierId');
    await tapKey(tester, 'confirm-accept-button');
    expect(api.staff[1]['isActive'], isFalse);
    expect(find.text('Ana Pérez'), findsNothing);

    await tapKey(tester, 'staff-show-inactive');
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Dado de baja'), findsOneWidget);
  });

  testWidgets('resets a PIN after typing it twice', (tester) async {
    await pumpAdminScreen(tester, const StaffScreen());

    await tapKey(tester, 'pin-staff-$cashierId');
    expect(find.text('Cambiar el PIN de Ana'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('staff-pin-input')), '9876');
    await tester.enterText(
      find.byKey(const Key('staff-pin-confirm-input')),
      '9876',
    );
    await tapKey(tester, 'save-pin-button');
    expect(find.text('PIN cambiado'), findsOneWidget);
  });

  testWidgets('edits only the changed fields', (tester) async {
    final api = await pumpAdminScreen(tester, const StaffScreen());

    await tapKey(tester, 'edit-staff-$cashierId');
    await tester.enterText(
      find.byKey(const Key('staff-displayname-input')),
      'Anita',
    );
    await tapKey(tester, 'save-staff-button');

    expect(find.text('Cambios guardados'), findsOneWidget);
    expect(find.text('Anita'), findsOneWidget);
    expect(api.staff[1]['fullName'], 'Ana Pérez');
  });
}
