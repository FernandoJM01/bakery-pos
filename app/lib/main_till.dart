import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/api/api_client_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_database.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/till_auth_service.dart';
import 'features/auth/domain/session_lock_manager.dart';
import 'features/auth/presentation/till_home_screen.dart';
import 'features/auth/presentation/till_login_screen.dart';
import 'features/auth/presentation/user_activity_detector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedServerUrl = await SecureStorageService(
    const FlutterSecureStorage(aOptions: AndroidOptions()),
  ).getServerUrl();

  runApp(
    ProviderScope(
      overrides: [
        serverBaseUrlProvider.overrideWith(
          () => ServerBaseUrlNotifier(savedServerUrl),
        ),
        deviceRevocationHandlerProvider.overrideWith((ref) {
          return () async {
            // Delete the database before the secure storage that holds its
            // key: opening it after the key is gone would create a new key
            // and fail on the old file, leaving it behind.
            await ref.read(tillDatabaseProvider).close();
            ref.invalidate(tillDatabaseProvider);
            await AppDatabase.deleteDatabaseFile();
            await ref.read(secureStorageProvider).clearAll();
          };
        }),
      ],
      child: const TillAppRoot(),
    ),
  );
}

class TillAppRoot extends ConsumerStatefulWidget {
  const TillAppRoot({super.key});

  @override
  ConsumerState<TillAppRoot> createState() => _TillAppRootState();
}

class _TillAppRootState extends ConsumerState<TillAppRoot> {
  @override
  void initState() {
    super.initState();
    ref.read(sessionLockManagerProvider).onNavigateToLogin = () {
      rootNavigatorKey.currentContext?.go(AppRoutes.tillLogin);
    };
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(tillAuthServiceProvider);
    return BakeryPosApp(
      mode: AppMode.till,
      refreshListenable: authService,
      hasSession: () => authService.currentSession != null,
      tillLoginBuilder: (context) => const TillLoginScreen(),
      tillHomeBuilder: (context) => const TillHomeScreen(),
      appWrapper: (context, child) =>
          UserActivityDetector(child: child ?? const SizedBox.shrink()),
    );
  }
}
