import 'package:drift/drift.dart';

import '../../domain/models/episode.dart';
import '../../domain/repositories/episode_repository.dart';
import '../database/app_database.dart' as drift;

class DriftEpisodeRepository implements EpisodeRepository {
  final drift.AppDatabase _db;

  DriftEpisodeRepository(this._db);

  @override
  Future<List<Episode>> getEpisodesForSubscription(
    String subscriptionId,
  ) async {
    final rows = await (_db.select(_db.episodes)
          ..where((e) => e.subscriptionId.equals(subscriptionId)))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Episode?> getEpisode(String id) async {
    final row = await (_db.select(_db.episodes)
          ..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> saveEpisodes(List<Episode> episodes) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.episodes,
        episodes.map(
          (e) => drift.EpisodesCompanion(
            id: Value(e.id),
            subscriptionId: Value(e.subscriptionId),
            title: Value(e.title),
            description: Value(e.description),
            publishedAt: Value(e.publishedAt),
            durationSeconds: Value(e.duration?.inSeconds),
            audioUrl: Value(e.audioUrl),
            coverUrl: Value(e.coverUrl),
            episodeNumber: Value(e.episodeNumber),
          ),
        ),
      );
    });
  }

  @override
  Future<void> markDownloaded(String id, {required bool downloaded}) async {
    await (_db.update(_db.episodes)..where((e) => e.id.equals(id))).write(
      drift.EpisodesCompanion(isDownloaded: Value(downloaded)),
    );
  }

  Episode _toDomain(drift.Episode row) => Episode(
        id: row.id,
        subscriptionId: row.subscriptionId,
        title: row.title,
        description: row.description,
        publishedAt: row.publishedAt,
        duration: row.durationSeconds == null
            ? null
            : Duration(seconds: row.durationSeconds!),
        audioUrl: row.audioUrl,
        coverUrl: row.coverUrl,
        episodeNumber: row.episodeNumber,
      );
}
