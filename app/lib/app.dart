import 'package:flutter/material.dart';

/// Which surface the app runs as.
enum AppMode { till, backoffice }

/// Root widget shared by the till and back office entry points.
class BakeryPosApp extends StatelessWidget {
  const BakeryPosApp({super.key, required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bakery POS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB300),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _PlaceholderHome(mode: mode),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          mode.name,
          key: const Key('mode-label'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
