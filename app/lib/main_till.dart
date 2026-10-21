import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/api/api_client_provider.dart';
import 'core/storage/local_database.dart';
import 'core/storage/secure_storage.dart';

void main() => runApp(
  ProviderScope(
    overrides: [
      deviceRevocationHandlerProvider.overrideWith((ref) {
        return () async {
          await ref.read(secureStorageProvider).clearAll();
          final db = ref.read(tillDatabaseProvider);
          await db.clearAll();
          await AppDatabase.deleteDatabaseFile();
        };
      }),
    ],
    child: const BakeryPosApp(mode: AppMode.till),
  ),
);
