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

  String? currentStaffId;
  String? currentStaffRole;
  List<String>? currentStaffPermissions;
  bool rejectRefresh = false;
  bool expireAccessToken = false;

  late final List<Map<String, dynamic>> branches = [
    {
      'id': branchId1,
      'code': 'SUC1',
      'name': 'Sucursal Centro',
      'address': 'Av. Juárez 100',
      'timezone': 'America/Mexico_City',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    },
    {
      'id': branchId2,
      'code': 'SUC2',
      'name': 'Sucursal Norte',
      'address': 'Blvd. Diaz Ordaz 200',
      'timezone': 'America/Mexico_City',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    },
  ];

  late final List<Map<String, dynamic>> devices = [
    {
      'id': deviceId,
      'branchId': branchId1,
      'name': 'Caja 1',
      'type': 'TILL',
      'status': 'ACTIVE',
      'lastSeenAt': '2026-10-25T13:05:00.000Z',
      'createdAt': '2026-10-01T00:00:00.000Z',
    },
  ];

  late final List<Map<String, dynamic>> staff = [
    {
      'id': ownerId,
      'fullName': 'Fernando Dueño',
      'displayName': 'Fernando',
      'role': 'OWNER',
      'email': 'owner@bakery.com',
      'branchIds': [branchId1, branchId2],
      'isActive': true,
      'hasPassword': true,
      'createdAt': '2026-10-01T00:00:00.000Z',
      'updatedAt': '2026-10-01T00:00:00.000Z',
    },
    {
      'id': cashierId,
      'fullName': 'Ana Pérez',
      'displayName': 'Ana',
      'role': 'CASHIER',
      'branchIds': [branchId1],
      'isActive': true,
      'hasPassword': false,
      'createdAt': '2026-10-01T00:00:00.000Z',
      'updatedAt': '2026-10-01T00:00:00.000Z',
    },
  ];

  late final List<Map<String, dynamic>> auditLog = [
    {
      'id': '0192e2b0-0a00-7000-8000-000000000003',
      'occurredAt': '2026-10-25T15:10:00.000Z',
      'action': 'staff.pin_changed',
      'branchId': branchId1,
      'actorStaffId': ownerId,
      'entityType': 'staff',
      'entityId': cashierId,
      'data': <String, dynamic>{},
    },
    {
      'id': '0192e2b0-0a00-7000-8000-000000000002',
      'occurredAt': '2026-10-25T14:00:00.000Z',
      'action': 'auth.approval_granted',
      'branchId': branchId1,
      'deviceId': deviceId,
      'actorStaffId': cashierId,
      'approverStaffId': ownerId,
      'data': {'permission': 'sale.refund'},
    },
    {
      'id': '0192e2b0-0a00-7000-8000-000000000001',
      'occurredAt': '2026-10-25T13:00:00.000Z',
      'action': 'device.created',
      'branchId': branchId1,
      'actorStaffId': ownerId,
      'entityType': 'device',
      'entityId': deviceId,
      'data': {'name': 'Caja 1'},
    },
  ];

  Map<String, dynamic> _publicStaff(Map<String, dynamic> s) =>
      Map<String, dynamic>.from(s);

  Map<String, dynamic> _enrollment(Map<String, dynamic> device) => {
    'device': device,
    'enrollmentCode': 'K7M2XQ9P',
    'expiresAt': DateTime.now()
        .toUtc()
        .add(const Duration(minutes: 30))
        .toIso8601String(),
  };

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

    void ok(Object? data, {int status = 200}) => handler.resolve(
      Response(requestOptions: options, statusCode: status, data: data),
    );
    void fail(int status, String code, String message) => handler.reject(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: status,
          data: {'code': code, 'message': message},
        ),
      ),
    );

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

    final authHeader = options.headers['Authorization'] as String?;
    if (expireAccessToken &&
        authHeader != null &&
        !path.endsWith('/v1/auth/refresh') &&
        !path.endsWith('/v1/auth/password-login')) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {
              'code': 'AUTH_TOKEN_EXPIRED',
              'message': 'Access token expired',
            },
          ),
        ),
        true,
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
                'sale.create',
                'sale.void_line_before_payment',
                'sale.void_after_payment',
                'sale.refund',
                'sale.discount_within_limit',
                'sale.discount_over_limit',
                'cash.open_shift',
                'cash.close_shift',
                'cash.movement',
                'cash.open_drawer_no_sale',
                'stock.production_entry',
                'stock.waste',
                'stock.count_adjust',
                'stock.transfer',
                'orders.manage',
                'orders.pickup',
                'oven.intake_pickup',
                'oven.board',
                'catalog.manage',
                'staff.manage',
                'devices.manage',
                'branches.manage',
                'reports.branch',
                'reports.all',
                'audit.view',
                'settings.manage',
              ],
              'BRANCH_MANAGER': [
                'sale.create',
                'sale.void_line_before_payment',
                'sale.void_after_payment',
                'sale.refund',
                'sale.discount_within_limit',
                'sale.discount_over_limit',
                'cash.open_shift',
                'cash.close_shift',
                'cash.movement',
                'cash.open_drawer_no_sale',
                'stock.production_entry',
                'stock.waste',
                'stock.count_adjust',
                'stock.transfer',
                'orders.manage',
                'orders.pickup',
                'oven.intake_pickup',
                'oven.board',
                'reports.branch',
              ],
              'CASHIER': [
                'sale.create',
                'sale.void_line_before_payment',
                'sale.discount_within_limit',
                'cash.open_shift',
                'cash.close_shift',
                'orders.pickup',
                'oven.intake_pickup',
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
              statusCode: 401,
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
          ? [
              'sale.create',
              'sale.void_line_before_payment',
              'sale.void_after_payment',
              'sale.refund',
              'sale.discount_within_limit',
              'sale.discount_over_limit',
              'cash.open_shift',
              'cash.close_shift',
              'cash.movement',
              'cash.open_drawer_no_sale',
              'stock.production_entry',
              'stock.waste',
              'stock.count_adjust',
              'stock.transfer',
              'orders.manage',
              'orders.pickup',
              'oven.intake_pickup',
              'oven.board',
              'reports.branch',
            ]
          : role == 'BAKER'
          ? ['stock.production_entry', 'stock.waste', 'oven.board']
          : [
              'sale.create',
              'sale.void_line_before_payment',
              'sale.discount_within_limit',
              'cash.open_shift',
              'cash.close_shift',
              'orders.pickup',
              'oven.intake_pickup',
            ];

      currentStaffId = staffId;
      currentStaffRole = role;
      currentStaffPermissions = permissions;

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
      if (rejectRefresh ||
          refreshToken.isEmpty ||
          refreshToken == 'invalid-token') {
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

    // 4c. /v1/auth/logout
    if (path.endsWith('/v1/auth/logout') && method == 'POST') {
      final authHeader = options.headers['Authorization'] as String?;
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {
                'code': 'AUTH_REQUIRED',
                'message': 'Authentication required',
              },
            ),
          ),
        );
      }
      return handler.resolve(
        Response(requestOptions: options, statusCode: 204),
      );
    }

    // 5. /v1/auth/password-login
    if (path.endsWith('/v1/auth/password-login') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final email = body['email'] as String? ?? '';
      final password = body['password'] as String? ?? '';

      if (email == 'locked@panaderia.com') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 423,
              data: {
                'code': 'AUTH_LOCKED',
                'message': 'Account is locked',
                'details': {
                  'lockedUntil': DateTime.now()
                      .add(const Duration(minutes: 15))
                      .toUtc()
                      .toIso8601String(),
                },
              },
            ),
          ),
        );
      }

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

      var staffId = ownerId;
      var fullName = 'Fernando Dueño';
      var displayName = 'Fernando';
      var role = 'OWNER';
      var perms = [
        'staff.manage',
        'devices.manage',
        'branches.manage',
        'audit.view',
        'sale.create',
      ];

      if (email == 'manager@panaderia.com') {
        staffId = managerId;
        fullName = 'Gerente Carlos';
        displayName = 'Carlos';
        role = 'BRANCH_MANAGER';
        perms = ['devices.manage', 'branches.manage', 'sale.create'];
      } else if (email == 'cashier@panaderia.com') {
        staffId = cashierId;
        fullName = 'Cajero Ana';
        displayName = 'Ana';
        role = 'CASHIER';
        perms = ['sale.create'];
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
                'id': staffId,
                'fullName': fullName,
                'displayName': displayName,
                'role': role,
                'email': email,
                'branchIds': [branchId1, branchId2],
                'isActive': true,
                'hasPassword': true,
                'createdAt': DateTime.now().toUtc().toIso8601String(),
                'updatedAt': DateTime.now().toUtc().toIso8601String(),
              },
              'permissions': perms,
              'deviceId': null,
            },
          },
        ),
      );
    }

    // 5b. /v1/auth/approvals
    if (path.endsWith('/v1/auth/approvals') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final approverStaffId = body['approverStaffId'] as String? ?? '';
      final pin = body['pin'] as String? ?? '';
      final action = body['action'] as String? ?? '';

      if (pin == 'locked') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 423,
              data: {
                'code': 'AUTH_LOCKED',
                'message': 'Approver is locked',
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

      if (approverStaffId == cashierId &&
          action == 'cash.open_drawer_no_sale') {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'code': 'PERMISSION_DENIED',
                'message': 'Approver lacks permission',
              },
            ),
          ),
        );
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'approvalToken': 'fake-approval-token-xyz',
            'expiresAt': DateTime.now()
                .add(const Duration(minutes: 2))
                .toUtc()
                .toIso8601String(),
            'approverStaffId': approverStaffId,
            'action': action,
          },
        ),
      );
    }

    // 6. /v1/me
    if (path.endsWith('/v1/me') && method == 'GET') {
      final authHeader = options.headers['Authorization'] as String?;
      final isTillStaff = authHeader == 'Bearer fake-access-token-jwt';
      final role = isTillStaff ? (currentStaffRole ?? 'CASHIER') : 'OWNER';
      final staffId = isTillStaff ? (currentStaffId ?? cashierId) : ownerId;
      final permissions = isTillStaff
          ? (currentStaffPermissions ??
                [
                  'sale.create',
                  'sale.discount_within_limit',
                  'cash.open_shift',
                  'cash.close_shift',
                  'orders.pickup',
                  'oven.intake_pickup',
                ])
          : [
              'staff.manage',
              'devices.manage',
              'branches.manage',
              'audit.view',
              'sale.create',
            ];
      final isOwner = role == 'OWNER';

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'staff': {
              'id': staffId,
              'fullName': isOwner ? 'Fernando Dueño' : 'Empleado $role',
              'displayName': isOwner ? 'Fernando' : 'Empleado',
              'role': role,
              'email': isOwner ? 'owner@bakery.com' : null,
              'branchIds': isOwner ? [branchId1, branchId2] : [branchId1],
              'isActive': true,
              'hasPassword': isOwner,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            },
            'permissions': permissions,
            'deviceId': isOwner ? null : deviceId,
          },
        ),
      );
    }

    // 7. /v1/branches
    if (path.endsWith('/v1/branches') && method == 'GET') {
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: branches),
      );
    }

    if (path.endsWith('/v1/branches') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final code = body['code'] as String?;
      final name = body['name'] as String?;

      if (name == 'Trigger400' ||
          code == null ||
          name == null ||
          !RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(code)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {
                'code': 'VALIDATION_FAILED',
                'message': 'Code must be 2-10 uppercase alphanumeric chars',
              },
            ),
          ),
        );
      }

      if (branches.any((b) => b['code'] == code)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 409,
              data: {
                'code': 'CONFLICT',
                'message': 'Branch code already in use',
              },
            ),
          ),
        );
      }

      final newBranch = {
        'id':
            '0192e2b0-000${branches.length + 1}-7000-8000-00000000000${branches.length + 1}',
        'code': code,
        'name': name,
        'address': body['address'],
        'timezone': body['timezone'] ?? 'America/Mexico_City',
        'isActive': true,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
      branches.add(newBranch);
      return handler.resolve(
        Response(requestOptions: options, statusCode: 201, data: newBranch),
      );
    }

    if (path.contains('/v1/branches/') && method == 'PATCH') {
      final branchId = path.split('/v1/branches/').last.split('?').first;
      final body = options.data as Map<String, dynamic>? ?? {};

      final index = branches.indexWhere((b) => b['id'] == branchId);
      if (index == -1) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 404,
              data: {'code': 'NOT_FOUND', 'message': 'Branch not found'},
            ),
          ),
        );
      }

      final updated = Map<String, dynamic>.from(branches[index]);
      if (body.containsKey('name')) updated['name'] = body['name'];
      if (body.containsKey('address')) updated['address'] = body['address'];
      if (body.containsKey('timezone')) updated['timezone'] = body['timezone'];
      if (body.containsKey('isActive')) updated['isActive'] = body['isActive'];
      updated['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      branches[index] = updated;

      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: updated),
      );
    }

    // 8. /v1/devices (admin)
    if (path.endsWith('/v1/devices') && method == 'GET') {
      final branch = options.queryParameters['branchId'];
      return ok([
        for (final d in devices)
          if (branch == null || d['branchId'] == branch) d,
      ]);
    }

    if (path.endsWith('/v1/devices') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      final branch = branches.firstWhere(
        (b) => b['id'] == body['branchId'],
        orElse: () => <String, dynamic>{},
      );
      if (branch.isEmpty || branch['isActive'] != true) {
        return fail(400, 'VALIDATION_FAILED', 'Branch inactive');
      }
      final now = DateTime.now().toUtc();
      final device = <String, dynamic>{
        'id':
            '0192e2b0-0100-7000-8000-${(100 + devices.length).toString().padLeft(12, '0')}',
        'branchId': body['branchId'],
        'name': body['name'],
        'type': body['type'] ?? 'TILL',
        'status': 'PENDING',
        'createdAt': now.toIso8601String(),
      };
      devices.add(device);
      return ok(_enrollment(device), status: 201);
    }

    final deviceAction = RegExp(
      r'/v1/devices/([^/]+)/(enrollment-code|revoke)$',
    ).firstMatch(path);
    if (deviceAction != null && method == 'POST') {
      final index = devices.indexWhere((d) => d['id'] == deviceAction[1]);
      if (index == -1) {
        return fail(404, 'NOT_FOUND', 'Device not found');
      }
      final device = Map<String, dynamic>.from(devices[index]);
      if (deviceAction[2] == 'revoke') {
        device['status'] = 'REVOKED';
        device['revokedAt'] = DateTime.now().toUtc().toIso8601String();
        devices[index] = device;
        return ok(device);
      }
      if (device['status'] != 'PENDING') {
        return fail(409, 'CONFLICT', 'Device is not pending');
      }
      return ok(_enrollment(device));
    }

    // 9. /v1/staff (admin)
    if (path.endsWith('/v1/staff') && method == 'GET') {
      final includeInactive =
          options.queryParameters['includeInactive'] == true;
      return ok([
        for (final s in staff)
          if (includeInactive || s['isActive'] == true) _publicStaff(s),
      ]);
    }

    if (path.endsWith('/v1/staff') && method == 'POST') {
      final body = options.data as Map<String, dynamic>? ?? {};
      if (body['role'] == 'OWNER' &&
          (body['email'] == null || body['password'] == null)) {
        return fail(400, 'VALIDATION_FAILED', 'Owner needs email and password');
      }
      if (body['email'] != null &&
          staff.any((s) => s['email'] == body['email'])) {
        return fail(409, 'CONFLICT', 'Email already in use');
      }
      final now = DateTime.now().toUtc().toIso8601String();
      final created = <String, dynamic>{
        'id':
            '0192e2b0-0050-7000-8000-${(50 + staff.length).toString().padLeft(12, '0')}',
        'fullName': body['fullName'],
        'displayName': body['displayName'],
        'role': body['role'],
        if (body['email'] != null) 'email': body['email'],
        'branchIds': body['branchIds'],
        'isActive': true,
        'hasPassword': body['password'] != null,
        'createdAt': now,
        'updatedAt': now,
      };
      staff.add(created);
      return ok(_publicStaff(created), status: 201);
    }

    final staffMatch = RegExp(r'/v1/staff/([^/]+)(/pin)?$').firstMatch(path);
    if (staffMatch != null) {
      final index = staff.indexWhere((s) => s['id'] == staffMatch[1]);
      if (index == -1) {
        return fail(404, 'NOT_FOUND', 'Staff not found');
      }
      if (staffMatch[2] == '/pin' && method == 'PUT') {
        final updated = Map<String, dynamic>.from(staff[index])
          ..remove('lockedUntil');
        staff[index] = updated;
        return handler.resolve(
          Response(requestOptions: options, statusCode: 204),
        );
      }
      if (method == 'GET') return ok(_publicStaff(staff[index]));
      if (method == 'PATCH') {
        final body = options.data as Map<String, dynamic>? ?? {};
        final current = staff[index];
        final losesOwner =
            current['role'] == 'OWNER' &&
            current['isActive'] == true &&
            (body['isActive'] == false ||
                (body['role'] != null && body['role'] != 'OWNER'));
        final activeOwners = staff
            .where((s) => s['role'] == 'OWNER' && s['isActive'] == true)
            .length;
        if (losesOwner && activeOwners <= 1) {
          return fail(
            409,
            'CONFLICT',
            'Cannot deactivate or demote the last active owner',
          );
        }
        if (body['email'] != null &&
            staff.any(
              (s) => s['email'] == body['email'] && s['id'] != current['id'],
            )) {
          return fail(409, 'CONFLICT', 'Email already in use');
        }
        final updated = Map<String, dynamic>.from(current);
        for (final key in [
          'fullName',
          'displayName',
          'role',
          'email',
          'branchIds',
          'isActive',
        ]) {
          if (body.containsKey(key)) updated[key] = body[key];
        }
        if (body['password'] != null) updated['hasPassword'] = true;
        updated['updatedAt'] = DateTime.now().toUtc().toIso8601String();
        staff[index] = updated;
        return ok(_publicStaff(updated));
      }
    }

    // 10. /v1/audit-log, newest first, two entries per page
    if (path.endsWith('/v1/audit-log') && method == 'GET') {
      final q = options.queryParameters;
      final filtered = [
        for (final e in auditLog)
          if ((q['action'] == null || e['action'] == q['action'].toString()) &&
              (q['branchId'] == null || e['branchId'] == q['branchId']) &&
              (q['staffId'] == null ||
                  e['actorStaffId'] == q['staffId'] ||
                  e['approverStaffId'] == q['staffId']))
            e,
      ];
      final start = int.tryParse(q['cursor']?.toString() ?? '') ?? 0;
      const pageSize = 2;
      final end = (start + pageSize).clamp(0, filtered.length);
      return ok({
        'items': filtered.sublist(start, end),
        if (end < filtered.length) 'nextCursor': '$end',
      });
    }

    // Default passthrough
    return handler.next(options);
  }
}
