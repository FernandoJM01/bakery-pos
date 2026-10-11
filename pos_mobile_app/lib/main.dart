import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/pin_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PosBakeryApp()));
}

class PosBakeryApp extends StatelessWidget {
  const PosBakeryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Bakery Artisan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundDeep,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryAmber,
          surface: AppColors.surfaceCard,
          error: AppColors.alertRed,
        ),
      ),
      home: const PinLoginScreen(),
    );
  }
}
