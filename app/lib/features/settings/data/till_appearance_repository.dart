import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/theme/appearance_settings.dart';

class TillAppearanceRepository {
  const TillAppearanceRepository(this._database);

  final AppDatabase _database;
  static const String _settingsKey = 'settings.appearance';

  Future<AppearanceSettings?> loadSettings() async {
    try {
      final raw = await _database.getSessionValue(_settingsKey);
      if (raw != null && raw.isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return AppearanceSettings.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveSettings(AppearanceSettings settings) async {
    final raw = jsonEncode(settings.toJson());
    await _database.setSessionValue(_settingsKey, raw);
  }
}

final tillAppearanceRepositoryProvider = Provider<TillAppearanceRepository>((
  ref,
) {
  final db = ref.watch(tillDatabaseProvider);
  return TillAppearanceRepository(db);
});
