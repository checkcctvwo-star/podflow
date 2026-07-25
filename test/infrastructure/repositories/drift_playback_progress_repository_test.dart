import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podflow/domain/models/playback_progress.dart';
import 'package:podflow/infrastructure/database/app_database.dart';
import 'package:podflow/infrastructure/repositories/drift_playback_progress_repository.dart';

void main() {
  group('DriftPlaybackProgressRepository', () {
    late AppDatabase db;
    late DriftPlaybackProgressRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftPlaybackProgressRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saves and retrieves progress', () async {
      final progress = PlaybackProgress(
        episodeId: 'ep1',
        position: const Duration(seconds: 42),
        total: const Duration(minutes: 5),
        updatedAt: _testDate,
      );

      await repository.saveProgress(progress);
      final retrieved = await repository.getProgress('ep1');

      expect(retrieved, isNotNull);
      expect(retrieved!.episodeId, 'ep1');
      expect(retrieved.position, const Duration(seconds: 42));
      expect(retrieved.total, const Duration(minutes: 5));
    });

    test('updates existing progress', () async {
      final progress1 = PlaybackProgress(
        episodeId: 'ep1',
        position: const Duration(seconds: 10),
        updatedAt: _testDate,
      );
      final progress2 = PlaybackProgress(
        episodeId: 'ep1',
        position: const Duration(seconds: 99),
        updatedAt: _testDate,
      );

      await repository.saveProgress(progress1);
      await repository.saveProgress(progress2);
      final retrieved = await repository.getProgress('ep1');

      expect(retrieved!.position, const Duration(seconds: 99));
    });

    test('returns null when no progress exists', () async {
      final retrieved = await repository.getProgress('missing');
      expect(retrieved, isNull);
    });

    test('deletes progress', () async {
      final progress = PlaybackProgress(
        episodeId: 'ep1',
        position: const Duration(seconds: 42),
        updatedAt: _testDate,
      );

      await repository.saveProgress(progress);
      await repository.deleteProgress('ep1');
      final retrieved = await repository.getProgress('ep1');

      expect(retrieved, isNull);
    });
  });
}

final _testDate = DateTime(2026, 7, 26);
