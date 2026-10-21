import 'package:dio/dio.dart';

class FakeApiInterceptor extends Interceptor {
  FakeApiInterceptor({this.latency = Duration.zero});

  final Duration latency;

  // In-memory mock state
  final String branchId1 = '0192e2b0-0001-7000-8000-000000000001';
  final String branchId2 = '0192e2b0-0002-7000-8000-000000000002';
  final String ownerId = '0192e2b0-0010-7000-8000-000000000010';
  final String managerId = '0192e2b0-0020-7000-8000-000000000020';
  final String cashierId = '0192e2b0-0030-7000-8000-000000000030';
  final String bakerId = '0192e2b0-0040-7000-8000-000000000040';
  final String deviceId = '0192e2b0-0100-7000-8000-000000000100';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }

    final path = options.path;
    final method = options.method.toUpperCase();

    final token = options.headers['X-Device-Token'] as String?;
    if (token == 'revoked-token') {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {
              'code': 'DEVICE_REVOKED',
              'message': 'Device token has been revoked',
            },
          ),
        ),
      );
    }
    if (token == 'unknown-token') {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {
              'code': 'DEVICE_UNKNOWN',
              'message': 'Device token is unknown',
            },
          ),
        ),
      );
    }

    // 1. /health
    if (path.endsWith('/health') && method == 'GET') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'status': 'ok', 'database': 'ok', 'version': '0.1.0-m1'},
        ),
      );
    }

    // 2. /v1/devices/activate
    if (path.endsWith('/v1/devices/activate') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final code = body['enrollmentCode'] as String? ?? '';

      if (code == 'EXPIRED1' ||
          code == 'USEDCODE' ||
          code == 'USED2345' ||
          code == 'EXPR2345') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 410,
              data: {
                'code': 'DEVICE_CODE_INVALID',
                'message': 'Code already used or expired',
              },
            ),
          ),
        );
      }

      if (code == 'RATELMT2') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 429,
              data: {
                'code': 'RATE_LIMITED',
                'message': 'Too many attempts, please wait',
              },
            ),
          ),
        );
      }

      if (code == 'BADCD234') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {
                'code': 'VALIDATION_FAILED',
                'message': 'Enrollment code format is invalid',
              },
            ),
          ),
        );
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'device': {
              'id': deviceId,
              'branchId': branchId1,
              'name': 'Caja 1',
              'type': 'TILL',
              'status': 'ACTIVE',
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            },
            'deviceToken': 'fake-device-token-secret-32-bytes',
            'branch': {
              'id': branchId1,
              'code': 'SUC1',
              'name': 'Sucursal Centro',
              'timezone': 'America/Mexico_City',
              'isActive': true,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
          },
        ),
      );
    }

    // 3. /v1/devices/me/staff
    if (path.endsWith('/v1/devices/me/staff') && method == 'GET') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'branchId': branchId1,
            'generatedAt': DateTime.now().toUtc().toIso8601String(),
            'staff': [
              {
                'id': managerId,
                'displayName': 'Carlos (Gerente)',
                'role': 'BRANCH_MANAGER',
                'offlinePinVerifier': r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4',
                'pinUpdatedAt': DateTime.now().toUtc().toIso8601String(),
              },
              {
                'id': cashierId,
                'displayName': 'Ana (Cajera)',
                'role': 'CASHIER',
                'offlinePinVerifier': r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4',
                'pinUpdatedAt': DateTime.now().toUtc().toIso8601String(),
              },
              {
                'id': bakerId,
                'displayName': 'Beto (Panadero)',
                'role': 'BAKER',
                'offlinePinVerifier': r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4',
                'pinUpdatedAt': DateTime.now().toUtc().toIso8601String(),
              },
            ],
            'roles': {
              'OWNER': [
                'staff.manage',
                'devices.manage',
                'branches.manage',
                'audit.view',
                'sale.create',
              ],
              'BRANCH_MANAGER': [
                'sale.create',
                'sale.refund',
                'reports.branch',
              ],
              'CASHIER': [
                'sale.create',
                'sale.discount_within_limit',
                'cash.open_shift',
                'cash.close_shift',
              ],
              'BAKER': ['stock.production_entry', 'stock.waste', 'oven.board'],
            },
          },
        ),
      );
    }

    // 4. /v1/auth/pin-login
    if (path.endsWith('/v1/auth/pin-login') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final pin = body['pin'] as String? ?? '';
      final staffId = body['staffId'] as String? ?? '';

      if (pin == '999999') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 423,
              data: {
                'code': 'AUTH_LOCKED',
                'message': 'Account locked due to 5 failed attempts',
                'details': {
                  'lockedUntil': DateTime.now()
                      .add(const Duration(minutes: 5))
                      .toUtc()
                      .toIso8601String(),
                },
              },
            ),
          ),
        );
      }

      if (pin == '0000' || staffId == 'not-allowed-id') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'code': 'AUTH_NOT_ALLOWED',
                'message': 'Staff member is not allowed on this device',
              },
            ),
          ),
        );
      }

      if (pin != '1234') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'code': 'AUTH_INVALID_PIN', 'message': 'Invalid PIN'},
            ),
          ),
        );
      }

      final role = staffId == managerId
          ? 'BRANCH_MANAGER'
          : staffId == bakerId
          ? 'BAKER'
          : 'CASHIER';

      final permissions = role == 'BRANCH_MANAGER'
          ? ['sale.create', 'sale.refund', 'reports.branch']
          : role == 'BAKER'
          ? ['stock.production_entry', 'stock.waste', 'oven.board']
          : [
              'sale.create',
              'sale.discount_within_limit',
              'cash.open_shift',
              'cash.close_shift',
            ];

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'accessToken': 'fake-access-token-jwt',
            'accessTokenExpiresAt': DateTime.now()
                .add(const Duration(minutes: 15))
                .toUtc()
                .toIso8601String(),
            'refreshToken': 'fake-refresh-token',
            'refreshTokenExpiresAt': DateTime.now()
                .add(const Duration(hours: 12))
                .toUtc()
                .toIso8601String(),
            'me': {
              'staff': {
                'id': staffId,
                'fullName': 'Empleado $role',
                'displayName': 'Empleado',
                'role': role,
                'branchIds': [branchId1],
                'isActive': true,
                'hasPassword': false,
                'createdAt': DateTime.now().toUtc().toIso8601String(),
                'updatedAt': DateTime.now().toUtc().toIso8601String(),
              },
              'permissions': permissions,
              'deviceId': deviceId,
            },
          },
        ),
      );
    }

    // 4b. /v1/auth/refresh
    if (path.endsWith('/v1/auth/refresh') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final refreshToken = body['refreshToken'] as String? ?? '';
      if (refreshToken.isEmpty || refreshToken == 'invalid-token') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {
                'code': 'AUTH_REFRESH_INVALID',
                'message': 'Refresh token is invalid or expired',
              },
            ),
          ),
        );
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'accessToken': 'fake-refreshed-jwt',
            'accessTokenExpiresAt': DateTime.now()
                .add(const Duration(minutes: 15))
                .toUtc()
                .toIso8601String(),
            'refreshToken': 'fake-new-refresh-token',
            'refreshTokenExpiresAt': DateTime.now()
                .add(const Duration(hours: 12))
                .toUtc()
                .toIso8601String(),
          },
        ),
      );
    }

    // 5. /v1/auth/password-login
    if (path.endsWith('/v1/auth/password-login') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final email = body['email'] as String? ?? '';
      final password = body['password'] as String? ?? '';

      if (password != 'Admin123456!') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {
                'code': 'AUTH_INVALID_CREDENTIALS',
                'message': 'Invalid credentials',
              },
            ),
          ),
        );
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'accessToken': 'fake-backoffice-access-token-jwt',
            'accessTokenExpiresAt': DateTime.now()
                .add(const Duration(minutes: 15))
                .toUtc()
                .toIso8601String(),
            'refreshToken': 'fake-backoffice-refresh-token',
            'refreshTokenExpiresAt': DateTime.now()
                .add(const Duration(hours: 12))
                .toUtc()
                .toIso8601String(),
            'me': {
              'staff': {
                'id': ownerId,
                'fullName': 'Fernando Dueño',
                'displayName': 'Fernando',
                'role': 'OWNER',
                'email': email,
                'branchIds': [branchId1, branchId2],
                'isActive': true,
                'hasPassword': true,
                'createdAt': DateTime.now().toUtc().toIso8601String(),
                'updatedAt': DateTime.now().toUtc().toIso8601String(),
              },
              'permissions': [
                'staff.manage',
                'devices.manage',
                'branches.manage',
                'audit.view',
                'sale.create',
              ],
              'deviceId': null,
            },
          },
        ),
      );
    }

    // 6. /v1/me
    if (path.endsWith('/v1/me') && method == 'GET') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'staff': {
              'id': ownerId,
              'fullName': 'Fernando Dueño',
              'displayName': 'Fernando',
              'role': 'OWNER',
              'email': 'owner@bakery.com',
              'branchIds': [branchId1, branchId2],
              'isActive': true,
              'hasPassword': true,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
            'permissions': [
              'staff.manage',
              'devices.manage',
              'branches.manage',
              'audit.view',
              'sale.create',
            ],
            'deviceId': null,
          },
        ),
      );
    }

    // 7. /v1/branches
    if (path.endsWith('/v1/branches') && method == 'GET') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': branchId1,
              'code': 'SUC1',
              'name': 'Sucursal Centro',
              'timezone': 'America/Mexico_City',
              'isActive': true,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
            {
              'id': branchId2,
              'code': 'SUC2',
              'name': 'Sucursal Norte',
              'timezone': 'America/Mexico_City',
              'isActive': true,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
          ],
        ),
      );
    }

    // 8. /v1/devices
    if (path.endsWith('/v1/devices') && method == 'GET') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': deviceId,
              'branchId': branchId1,
              'name': 'Caja 1',
              'type': 'TILL',
              'status': 'ACTIVE',
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            },
          ],
        ),
      );
    }

    // 9. /v1/staff
    if (path.endsWith('/v1/staff') && method == 'GET') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': ownerId,
              'fullName': 'Fernando Dueño',
              'displayName': 'Fernando',
              'role': 'OWNER',
              'email': 'owner@bakery.com',
              'branchIds': [branchId1, branchId2],
              'isActive': true,
              'hasPassword': true,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
            {
              'id': cashierId,
              'fullName': 'Ana Pérez',
              'displayName': 'Ana',
              'role': 'CASHIER',
              'branchIds': [branchId1],
              'isActive': true,
              'hasPassword': false,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
          ],
        ),
      );
    }

    // Default passthrough
    return handler.next(options);
  }
}
