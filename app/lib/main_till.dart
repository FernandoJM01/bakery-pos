import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/api/api_client_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/appearance_settings.dart';
import 'features/auth/data/till_auth_service.dart';
import 'features/auth/data/till_revocation_handler.dart';
import 'features/auth/domain/session_lock_manager.dart';
import 'features/auth/presentation/till_home_screen.dart';
import 'features/auth/presentation/till_login_screen.dart';
import 'features/auth/presentation/user_activity_detector.dart';
import 'features/settings/data/till_appearance_repository.dart';

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
        deviceRevocationHandlerProvider.overrideWith(
          (ref) =>
              () => executeTillDeviceRevocationWipeFromRef(ref),
        ),
        appearanceSettingsSaveCallbackProvider.overrideWith((ref) {
          final repo = ref.read(tillAppearanceRepositoryProvider);
          return (settings) => repo.saveSettings(settings);
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
    final lockManager = ref.read(sessionLockManagerProvider);
    lockManager.readCurrentRoute = () {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return null;
      return GoRouter.of(context).routerDelegate.currentConfiguration.uri
          .toString();
    };
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    try {
      final repo = ref.read(tillAppearanceRepositoryProvider);
      final loaded = await repo.loadSettings();
      if (loaded != null) {
        ref.read(appearanceSettingsProvider.notifier).updateSettings(loaded);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(tillAuthServiceProvider);
    final lockManager = ref.watch(sessionLockManagerProvider);
    return BakeryPosApp(
      mode: AppMode.till,
      refreshListenable: Listenable.merge([authService, lockManager]),
      hasSession: () => lockManager.hasActiveSession,
      getPermissions: () => authService.currentSession?.permissions ?? const [],
      tillLoginBuilder: (context) => const TillLoginScreen(),
      tillShellBuilder: (context, state, child) => TillHomeScreen(child: child),
      tillSectionBuilder: (context, route) =>
          TillSectionPlaceholder.forRoute(route),
      appWrapper: (context, child) =>
          UserActivityDetector(child: child ?? const SizedBox.shrink()),
    );
  }
}
