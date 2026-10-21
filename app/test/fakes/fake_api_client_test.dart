import 'package:bakery_pos/core/api/generated/models/device_activate_request.dart';
import 'package:bakery_pos/core/api/generated/models/health_database.dart';
import 'package:bakery_pos/core/api/generated/models/health_status.dart';
import 'package:bakery_pos/core/api/generated/models/password_login_request.dart';
import 'package:bakery_pos/core/api/generated/models/pin_login_request.dart';
import 'package:bakery_pos/core/api/generated/models/role.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_api_client.dart';

void main() {
  group('FakeApiClient', () {
    late final client = createFakeRestClient();

    test('health check returns ok', () async {
      final response = await client.system.getHealth();
      expect(response.status, HealthStatus.ok);
      expect(response.database, HealthDatabase.ok);
      expect(response.version, '0.1.0-m1');
    });

    test('device activation succeeds with valid code', () async {
      final response = await client.devices.activateDevice(
        body: const DeviceActivateRequest(
          enrollmentCode: 'ABCD2345',
          appVersion: '0.1.0',
        ),
      );
      expect(response.device.name, 'Caja 1');
      expect(response.deviceToken.isNotEmpty, true);
      expect(response.branch.code, 'SUC1');
    });

    test('device activation throws 410 on invalid/used code', () async {
      expect(
        () => client.devices.activateDevice(
          body: const DeviceActivateRequest(
            enrollmentCode: 'EXPIRED1',
            appVersion: '0.1.0',
          ),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('staff bundle returns staff entries with offline verifiers', () async {
      final response = await client.devices.getDeviceStaffBundle();
      expect(response.staff.isNotEmpty, true);
      for (final staff in response.staff) {
        expect(staff.offlinePinVerifier.isNotEmpty, true);
      }
      expect(response.roles.containsKey('CASHIER'), true);
    });

    test('pin login succeeds with correct PIN 1234', () async {
      final staffBundle = await client.devices.getDeviceStaffBundle();
      final cashier = staffBundle.staff.firstWhere(
        (s) => s.role == Role.cashier,
      );

      final response = await client.auth.pinLogin(
        body: PinLoginRequest(staffId: cashier.id, pin: '1234'),
      );

      expect(response.accessToken.isNotEmpty, true);
      expect(response.refreshToken.isNotEmpty, true);
      expect(response.me.staff.id, cashier.id);
    });

    test('pin login rejects invalid PIN with 401', () async {
      final staffBundle = await client.devices.getDeviceStaffBundle();
      final cashier = staffBundle.staff.first;

      expect(
        () => client.auth.pinLogin(
          body: PinLoginRequest(staffId: cashier.id, pin: '0000'),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('pin login throws 423 on locked PIN', () async {
      final staffBundle = await client.devices.getDeviceStaffBundle();
      final cashier = staffBundle.staff.first;

      expect(
        () => client.auth.pinLogin(
          body: PinLoginRequest(staffId: cashier.id, pin: '999999'),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('password login succeeds with correct credentials', () async {
      final response = await client.auth.passwordLogin(
        body: const PasswordLoginRequest(
          email: 'owner@bakery.com',
          password: 'Admin123456!',
        ),
      );

      expect(response.accessToken.isNotEmpty, true);
      expect(response.me.staff.role, Role.owner);
    });

    test('password login rejects wrong password', () async {
      expect(
        () => client.auth.passwordLogin(
          body: const PasswordLoginRequest(
            email: 'owner@bakery.com',
            password: 'WrongPassword!',
          ),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('getMe returns current owner profile', () async {
      final me = await client.auth.getMe();
      expect(me.staff.role, Role.owner);
      expect(me.permissions.any((p) => p.json == 'staff.manage'), true);
    });

    test('branches list returns active branches', () async {
      final branches = await client.branches.listBranches();
      expect(branches.length, 2);
      expect(branches.first.code, 'SUC1');
    });

    test('devices list returns registered devices', () async {
      final devices = await client.devices.listDevices();
      expect(devices.isNotEmpty, true);
    });

    test('staff list returns staff members', () async {
      final staff = await client.staff.listStaff();
      expect(staff.isNotEmpty, true);
    });
  });
}
