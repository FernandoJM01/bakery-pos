import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/device.dart';
import '../../../core/api/generated/models/device_create.dart';
import '../../../core/api/generated/models/device_enrollment.dart';
import '../../../core/api/generated/rest_client.dart';

final devicesAdminProvider =
    AsyncNotifierProvider<DevicesAdminNotifier, List<Device>>(
      DevicesAdminNotifier.new,
    );

class DevicesAdminNotifier extends AsyncNotifier<List<Device>> {
  RestClient get _client => ref.read(restClientProvider);

  @override
  Future<List<Device>> build() => _client.devices.listDevices();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _client.devices.listDevices());
  }

  void _replace(Device device) {
    final current = state.value ?? <Device>[];
    final exists = current.any((d) => d.id == device.id);
    state = AsyncValue.data([
      for (final d in current)
        if (d.id == device.id) device else d,
      if (!exists) device,
    ]);
  }

  /// Registers a till; the code in the result is shown once and never stored.
  Future<DeviceEnrollment> create(DeviceCreate body) async {
    final enrollment = await _client.devices.createDevice(body: body);
    _replace(enrollment.device);
    return enrollment;
  }

  Future<DeviceEnrollment> newCode(String deviceId) async {
    final enrollment = await _client.devices.regenerateEnrollmentCode(
      deviceId: deviceId,
    );
    _replace(enrollment.device);
    return enrollment;
  }

  Future<Device> revoke(String deviceId) async {
    final device = await _client.devices.revokeDevice(deviceId: deviceId);
    _replace(device);
    return device;
  }
}
