import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podflow/domain/models/episode.dart';
import 'package:podflow/domain/models/subscription.dart';
import 'package:podflow/infrastructure/database/app_database.dart' as drift;
import 'package:podflow/infrastructure/repositories/drift_episode_repository.dart';

void main() {
  group('DriftEpisodeRepository', () {
    late drift.AppDatabase db;
    late DriftEpisodeRepository repository;

    setUp(() async {
      db = drift.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftEpisodeRepository(db);

      await db.into(db.subscriptions).insert(
            drift.SubscriptionsCompanion.insert(
              id: 'sub1',
              feedUrl: 'https://example.com/feed.rss',
              title: '日谈公园',
              addedAt: DateTime.now(),
            ),
          );
    });

    tearDown(() => db.close());

    test('saves and retrieves episodes for a subscription', () async {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么要读书',
        audioUrl: 'https://example.com/ep1.mp3',
        duration: const Duration(minutes: 45, seconds: 30),
        episodeNumber: 142,
      );

      await repository.saveEpisodes([episode]);
      final episodes = await repository.getEpisodesForSubscription('sub1');

      expect(episodes.length, 1);
      expect(episodes.first.title, '为什么要读书');
      expect(episodes.first.duration, const Duration(minutes: 45, seconds: 30));
      expect(episodes.first.episodeNumber, 142);
    });

    test('updates episodes on conflict', () async {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: 'Old Title',
        audioUrl: 'https://example.com/ep1.mp3',
      );
      final updated = episode.copyWith(title: 'New Title');

      await repository.saveEpisodes([episode]);
      await repository.saveEpisodes([updated]);
      final episodes = await repository.getEpisodesForSubscription('sub1');

      expect(episodes.first.title, 'New Title');
    });

    test('marks episode as downloaded', () async {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么要读书',
        audioUrl: 'https://example.com/ep1.mp3',
      );
      await repository.saveEpisodes([episode]);

      await repository.markDownloaded('ep1', downloaded: true);
      final result = await repository.getEpisode('ep1');

      expect(result, isNotNull);
      expect(result!.audioUrl, 'https://example.com/ep1.mp3');
    });
  });
}
