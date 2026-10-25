import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/pin_set.dart';
import '../../../core/api/generated/models/staff.dart';
import '../../../core/api/generated/models/staff_create.dart';
import '../../../core/api/generated/models/staff_update.dart';
import '../../../core/api/generated/rest_client.dart';

/// Every staff member, active or not; the back office filters locally because
/// a bakery has a few dozen people at most.
final staffAdminProvider =
    AsyncNotifierProvider<StaffAdminNotifier, List<Staff>>(
      StaffAdminNotifier.new,
    );

class StaffAdminNotifier extends AsyncNotifier<List<Staff>> {
  RestClient get _client => ref.read(restClientProvider);

  @override
  Future<List<Staff>> build() => _fetch();

  Future<List<Staff>> _fetch() =>
      _client.staff.listStaff(includeInactive: true);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Staff> create(StaffCreate body) async {
    final created = await _client.staff.createStaff(body: body);
    state = AsyncValue.data([...state.value ?? [], created]);
    return created;
  }

  Future<Staff> updateStaff(String staffId, StaffUpdate body) async {
    final updated = await _client.staff.updateStaff(
      staffId: staffId,
      body: body,
    );
    state = AsyncValue.data([
      for (final s in state.value ?? <Staff>[])
        if (s.id == staffId) updated else s,
    ]);
    return updated;
  }

  Future<void> setPin(String staffId, String pin) async {
    await _client.staff.setStaffPin(
      staffId: staffId,
      body: PinSet(pin: pin),
    );
    // The server clears any lockout; reload that person to show it.
    final fresh = await _client.staff.getStaff(staffId: staffId);
    state = AsyncValue.data([
      for (final s in state.value ?? <Staff>[])
        if (s.id == staffId) fresh else s,
    ]);
  }
}
