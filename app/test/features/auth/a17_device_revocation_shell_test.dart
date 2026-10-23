import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/api/till_device_interceptor.dart';
import 'package:bakery_pos/core/router/app_router.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/auth/presentation/till_home_screen.dart';
import 'package:bakery_pos/features/enrollment/presentation/enrollment_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeSecureStorageStore extends Fake implements FlutterSecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) values[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.clear();
}

class _MockStatusAdapter implements HttpClientAdapter {
  _MockStatusAdapter(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('Acceptance Test A17: Device Revocation from Logged-in Shell', () {
    late AppDatabase db;
    late FakeSecureStorageStore fakeStore;
    late SecureStorageService secureStorage;
    late Dio dio;
    late RestClient restClient;
    late GoRouter router;
    late TillAuthService authService;

    final staff1 = StaffEntry(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: 'verifier',
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      fakeStore = FakeSecureStorageStore();
      secureStorage = SecureStorageService(fakeStore);
      await secureStorage.saveDeviceToken('revoked-token');

      await db.replaceStaffBundle(
        staff: [
          StaffEntriesCompanion.insert(
            id: staff1.id,
            displayName: staff1.displayName,
            role: staff1.role,
            offlinePinVerifier: staff1.offlinePinVerifier,
            pinUpdatedAt: staff1.pinUpdatedAt,
          ),
        ],
        permissions: [
          RolePermissionsCompanion.insert(
            role: staff1.role,
            permissionKey: 'sale.create',
          ),
        ],
      );

      dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = _MockStatusAdapter(
        401,
        '{"code":"DEVICE_REVOKED","message":"Device token has been revoked"}',
      );
      dio.interceptors.add(
        TillDeviceInterceptor(
          getDeviceToken: secureStorage.getDeviceToken,
          onRevoked: () async {
            await db.close();
            await secureStorage.clearAll();
            authService.clearLocalSession();
          },
          onNavigateToEnrollment: () {
            router.go('${AppRoutes.tillEnrollment}?revoked=true');
          },
        ),
      );

      restClient = RestClient(dio);
      authService = TillAuthService(
        restClient: restClient,
        database: db,
        secureStorage: secureStorage,
      );

      router = GoRouter(
        initialLocation: AppRoutes.tillHome,
        routes: [
          GoRoute(
            path: AppRoutes.tillEnrollment,
            builder: (context, state) {
              final isRevoked = state.uri.queryParameters['revoked'] == 'true';
              return EnrollmentScreen(isRevoked: isRevoked);
            },
          ),
          GoRoute(
            path: AppRoutes.tillHome,
            builder: (context, state) => const TillHomeScreen(),
          ),
        ],
      );
    });

    testWidgets(
      '401 DEVICE_REVOKED from shell wipes data and redirects to enrollment with Spanish message',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final session = TillSession(
          staff: staff1,
          permissions: const ['sale.create'],
          isOffline: false,
          accessToken: 'fake-access-token-jwt',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tillDatabaseProvider.overrideWithValue(db),
              secureStorageProvider.overrideWithValue(secureStorage),
              dioProvider.overrideWithValue(dio),
              restClientProvider.overrideWithValue(restClient),
              tillAuthServiceProvider.overrideWithValue(authService),
              tillSessionProvider.overrideWith(
                () => _TestSessionNotifier(session),
              ),
            ],
            child: MaterialApp.router(
              locale: const Locale('es', 'MX'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Currently on TillHomeScreen
        expect(find.byType(TillHomeScreen), findsOneWidget);
        expect(find.byKey(const Key('home-sync-button')), findsOneWidget);

        // Tap sync button which invokes an API call with revoked device token
        await tester.tap(find.byKey(const Key('home-sync-button')));
        await tester.pumpAndSettle();

        // Redirected to EnrollmentScreen with revoked banner
        expect(find.byType(TillHomeScreen), findsNothing);
        expect(find.byType(EnrollmentScreen), findsOneWidget);
        expect(
          find.byKey(const Key('enrollment-revoked-banner')),
          findsOneWidget,
        );

        final l10n = await AppLocalizations.delegate.load(
          const Locale('es', 'MX'),
        );
        expect(find.text(l10n.deviceRevokedMessage), findsOneWidget);

        // Secure storage has been wiped
        final deviceToken = await secureStorage.getDeviceToken();
        expect(deviceToken, isNull);
      },
    );
  });
}

class _TestSessionNotifier extends TillSessionNotifier {
  _TestSessionNotifier(this._session);
  final TillSession _session;

  @override
  TillSession? build() => _session;
}
