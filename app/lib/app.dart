import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Which surface the app runs as.
enum AppMode { till, backoffice }

/// Root widget shared by the till and back office entry points.
class BakeryPosApp extends ConsumerWidget {
  const BakeryPosApp({super.key, required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter(mode);

    return MaterialApp.router(
      title: 'Bakery POS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
