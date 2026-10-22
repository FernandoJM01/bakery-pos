import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app.dart';
import 'core/api/api_client_provider.dart';
import 'core/storage/local_database.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/presentation/till_home_screen.dart';
import 'features/auth/presentation/till_login_screen.dart';

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
      child: BakeryPosApp(
        mode: AppMode.till,
        tillLoginBuilder: (context) => const TillLoginScreen(),
        tillHomeBuilder: (context) => const TillHomeScreen(),
      ),
    ),
  );
}
