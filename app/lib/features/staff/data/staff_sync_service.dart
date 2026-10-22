import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/rest_client.dart';
import '../../../core/storage/local_database.dart';

final staffSyncServiceProvider = Provider<StaffSyncService>((ref) {
  final restClient = ref.watch(restClientProvider);
  final db = ref.watch(tillDatabaseProvider);
  return StaffSyncService(restClient: restClient, database: db);
});

class StaffSyncService {
  StaffSyncService({required this.restClient, required this.database});

  final RestClient restClient;
  final AppDatabase database;

  Future<int> syncStaffBundle() async {
    final bundle = await restClient.devices.getDeviceStaffBundle();

    final staffCompanions = bundle.staff.map((s) {
      return StaffEntriesCompanion(
        id: Value(s.id),
        displayName: Value(s.displayName),
        role: Value(s.role.json ?? s.role.name),
        offlinePinVerifier: Value(s.offlinePinVerifier),
        pinUpdatedAt: Value(s.pinUpdatedAt),
      );
    }).toList();

    final permissionCompanions = <RolePermissionsCompanion>[];
    bundle.roles.forEach((roleKey, keys) {
      for (final key in keys) {
        final permStr = key.json ?? key.name;
        permissionCompanions.add(
          RolePermissionsCompanion(
            role: Value(roleKey),
            permissionKey: Value(permStr),
          ),
        );
      }
    });

    await database.replaceStaffBundle(
      staff: staffCompanions,
      permissions: permissionCompanions,
    );

    return staffCompanions.length;
  }
}
