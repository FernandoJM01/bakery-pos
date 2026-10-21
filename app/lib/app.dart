import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Which surface the app runs as.
enum AppMode { till, backoffice }

/// Root widget shared by the till and back office entry points.
class BakeryPosApp extends StatefulWidget {
  const BakeryPosApp({super.key, required this.mode});

  final AppMode mode;

  @override
  State<BakeryPosApp> createState() => _BakeryPosAppState();
}

class _BakeryPosAppState extends State<BakeryPosApp> {
  // Created once so navigation state survives rebuilds of the root widget.
  late final GoRouter _router = createAppRouter(widget.mode);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
