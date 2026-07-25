import 'package:drift/drift.dart';

import '../../domain/models/playback_progress.dart';
import '../../domain/repositories/playback_progress_repository.dart';
import '../database/app_database.dart' as drift;

class DriftPlaybackProgressRepository implements PlaybackProgressRepository {
  final drift.AppDatabase _db;

  DriftPlaybackProgressRepository(this._db);

  @override
  Future<PlaybackProgress?> getProgress(String episodeId) async {
    final row = await (_db.select(_db.playbackProgress)
          ..where((p) => p.episodeId.equals(episodeId)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> saveProgress(PlaybackProgress progress) async {
    await _db.into(_db.playbackProgress).insertOnConflictUpdate(
          drift.PlaybackProgressCompanion(
            episodeId: Value(progress.episodeId),
            positionMillis: Value(progress.position.inMilliseconds),
            totalMillis: Value(progress.total?.inMilliseconds),
            updatedAt: Value(progress.updatedAt),
          ),
        );
  }

  @override
  Future<void> deleteProgress(String episodeId) async {
    await (_db.delete(_db.playbackProgress)
          ..where((p) => p.episodeId.equals(episodeId)))
        .go();
  }

  PlaybackProgress _toDomain(drift.PlaybackProgressData row) =>
      PlaybackProgress(
        episodeId: row.episodeId,
        position: Duration(milliseconds: row.positionMillis),
        total: row.totalMillis == null
            ? null
            : Duration(milliseconds: row.totalMillis!),
        updatedAt: row.updatedAt,
      );
}
