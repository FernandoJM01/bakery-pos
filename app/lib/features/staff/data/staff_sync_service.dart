import '../../cash/data/shift_repository.dart' show cashVarianceFlagKey;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/rest_client.dart';
import '../../../core/storage/local_database.dart';
import '../../auth/data/till_auth_service.dart';
import '../../auth/domain/till_auth_state.dart';
import '../../sale/data/sale_repository.dart';

final staffSyncServiceProvider = Provider<StaffSyncService>((ref) {
  final restClient = ref.watch(restClientProvider);
  final db = ref.watch(tillDatabaseProvider);
  final authService = ref.watch(tillAuthServiceProvider);
  return StaffSyncService(
    restClient: restClient,
    database: db,
    authService: authService,
  );
});

class StaffSyncService {
  StaffSyncService({
    required this.restClient,
    required this.database,
    required this.authService,
  });

  final RestClient restClient;
  final AppDatabase database;
  final TillAuthService authService;

  Future<int> syncStaffBundle() async {
    if (authService.currentSession?.isOffline == true) {
      throw const TillAuthGenericException('Online re-authentication required');
    }
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
    // M3: this till's folio prefix and the cashier discount limit.
    final prefix = bundle.folioPrefix;
    if (prefix != null && prefix.isNotEmpty) {
      await database.setSessionValue(folioPrefixKey, prefix);
    }
    final limit = bundle.saleSettings?.discountLimitBp;
    if (limit != null) {
      await database.setSessionValue(discountLimitKey, '$limit');
    }
    final flag = bundle.saleSettings?.cashVarianceFlagCents;
    if (flag != null) {
      await database.setSessionValue(cashVarianceFlagKey, '$flag');
    }

    return staffCompanions.length;
  }
}
