import 'package:drift/drift.dart';

import '../database/app_database.dart' as drift;

/// Simple key/value settings store backed by the existing [Settings] table.
class DriftSettingsRepository {
  final drift.AppDatabase _db;

  DriftSettingsRepository(this._db);

  Future<String?> get(String key) async {
    final row = await (_db.select(_db.settings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          drift.SettingsCompanion(
            key: Value(key),
            value: Value(value),
          ),
        );
  }

  Future<void> delete(String key) async {
    await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
  }
}
