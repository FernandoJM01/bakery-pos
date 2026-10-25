import 'package:bakery_pos/features/devices/presentation/devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../admin_test_harness.dart';

void main() {
  testWidgets('A6: registers a till, shows its code once, then revokes it', (
    tester,
  ) async {
    final api = await pumpAdminScreen(tester, const DevicesScreen());

    expect(find.text('Caja 1'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);

    await tapKey(tester, 'create-device-button');
    await tapKey(tester, 'save-device-button');
    expect(find.text('Elige la sucursal'), findsOneWidget);

    await tapKey(tester, 'device-branch-input');
    await tester.tap(find.text('Sucursal Norte').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('device-name-input')),
      'Caja 2',
    );
    await tapKey(tester, 'save-device-button');

    expect(find.text('Código para Caja 2'), findsOneWidget);
    expect(find.text('K7M2 XQ9P'), findsOneWidget);
    await tapKey(tester, 'code-done-button');
    expect(find.text('K7M2 XQ9P'), findsNothing);
    expect(find.text('Esperando código'), findsOneWidget);

    final newId = api.devices.last['id'] as String;
    await tapKey(tester, 'new-code-$newId');
    await tapKey(tester, 'confirm-accept-button');
    expect(find.text('K7M2 XQ9P'), findsOneWidget);
    await tapKey(tester, 'code-done-button');

    await tapKey(tester, 'revoke-$newId');
    expect(find.text('¿Revocar Caja 2?'), findsOneWidget);
    await tapKey(tester, 'confirm-accept-button');
    expect(api.devices.last['status'], 'REVOKED');
    expect(find.text('Caja 2'), findsNothing);

    await tapKey(tester, 'devices-show-revoked');
    expect(find.text('Revocado'), findsOneWidget);
  });

  testWidgets('inactive branches are not offered for new devices', (
    tester,
  ) async {
    await pumpAdminScreen(
      tester,
      const DevicesScreen(),
      setup: (api) => api.branches[1]['isActive'] = false,
    );

    await tapKey(tester, 'create-device-button');
    await tapKey(tester, 'device-branch-input');
    expect(find.text('Sucursal Centro'), findsWidgets);
    expect(find.text('Sucursal Norte'), findsNothing);
  });
}
