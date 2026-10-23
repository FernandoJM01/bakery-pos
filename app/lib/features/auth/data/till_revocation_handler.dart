import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/session_lock_manager.dart';
import 'till_auth_service.dart';

/// The official revocation wipe order for till devices:
/// Delete the database before the secure storage that holds its key:
/// opening it after the key is gone would create a new key and fail on the old file,
/// leaving it behind. Then clear secure storage, current session, and locked state.
Future<void> executeTillDeviceRevocationWipe({
  required AppDatabase database,
  required SecureStorageService secureStorage,
  required TillAuthService authService,
  SessionLockManager? lockManager,
  void Function()? invalidateDatabase,
}) async {
  await database.close();
  invalidateDatabase?.call();
  await AppDatabase.deleteDatabaseFile();
  await secureStorage.clearAll();
  authService.clearLocalSession();
  lockManager?.clearLockedState();
}

Future<void> executeTillDeviceRevocationWipeFromRef(Ref ref) async {
  await executeTillDeviceRevocationWipe(
    database: ref.read(tillDatabaseProvider),
    secureStorage: ref.read(secureStorageProvider),
    authService: ref.read(tillAuthServiceProvider),
    lockManager: ref.read(sessionLockManagerProvider),
    invalidateDatabase: () => ref.invalidate(tillDatabaseProvider),
  );
}
