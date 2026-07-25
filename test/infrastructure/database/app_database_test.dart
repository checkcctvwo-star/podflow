import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podflow/infrastructure/database/app_database.dart';
import 'package:podflow/infrastructure/database/converters/download_status.dart';
import 'package:podflow/infrastructure/database/tables.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
    });

    tearDown(() => db.close());

    test('inserts and retrieves subscriptions', () async {
      await db.into(db.subscriptions).insert(
            SubscriptionsCompanion.insert(
              id: 'sub1',
              feedUrl: 'https://example.com/feed.rss',
              title: '日谈公园',
            ),
          );

      final result = await db.select(db.subscriptions).getSingle();
      expect(result.id, 'sub1');
      expect(result.title, '日谈公园');
      expect(result.feedUrl, 'https://example.com/feed.rss');
    });

    test('inserts episodes linked to a subscription', () async {
      await db.into(db.subscriptions).insert(
            SubscriptionsCompanion.insert(
              id: 'sub1',
              feedUrl: 'https://example.com/feed.rss',
              title: '日谈公园',
            ),
          );

      await db.into(db.episodes).insert(
            EpisodesCompanion.insert(
              id: 'ep1',
              subscriptionId: 'sub1',
              title: '为什么要读书',
              audioUrl: 'https://example.com/ep1.mp3',
              durationSeconds: const Value(2730),
              episodeNumber: const Value(142),
            ),
          );

      final episodes = await db.select(db.episodes).get();
      expect(episodes.length, 1);
      expect(episodes.first.title, '为什么要读书');
      expect(episodes.first.subscriptionId, 'sub1');
      expect(episodes.first.durationSeconds, 2730);
    });

    test('stores download task with status enum', () async {
      await db.into(db.subscriptions).insert(
            SubscriptionsCompanion.insert(
              id: 'sub1',
              feedUrl: 'https://example.com/feed.rss',
              title: '日谈公园',
            ),
          );
      await db.into(db.episodes).insert(
            EpisodesCompanion.insert(
              id: 'ep1',
              subscriptionId: 'sub1',
              title: '为什么要读书',
              audioUrl: 'https://example.com/ep1.mp3',
            ),
          );

      await db.into(db.downloadTasks).insert(
            DownloadTasksCompanion.insert(
              id: 'task1',
              episodeId: 'ep1',
              status: DownloadStatus.pending,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

      final task = await db.select(db.downloadTasks).getSingle();
      expect(task.status, DownloadStatus.pending);
      expect(task.episodeId, 'ep1');
    });
  });
}
