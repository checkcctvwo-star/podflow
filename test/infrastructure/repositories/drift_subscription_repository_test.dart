import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podflow/domain/models/subscription.dart';
import 'package:podflow/infrastructure/database/app_database.dart' as drift;
import 'package:podflow/infrastructure/repositories/drift_subscription_repository.dart';

void main() {
  group('DriftSubscriptionRepository', () {
    late drift.AppDatabase db;
    late DriftSubscriptionRepository repository;

    setUp(() {
      db = drift.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftSubscriptionRepository(db);
    });

    tearDown(() => db.close());

    test('saves and retrieves a subscription', () async {
      final subscription = Subscription(
        id: 'sub1',
        feedUrl: 'https://example.com/feed.rss',
        title: '日谈公园',
        addedAt: DateTime(2024, 1, 1),
      );

      await repository.saveSubscription(subscription);
      final result = await repository.getSubscription('sub1');

      expect(result, isNotNull);
      expect(result!.title, '日谈公园');
      expect(result.feedUrl, 'https://example.com/feed.rss');
      expect(result.addedAt, DateTime(2024, 1, 1));
    });

    test('finds subscription by feed URL', () async {
      final subscription = Subscription(
        id: 'sub1',
        feedUrl: 'https://example.com/feed.rss',
        title: '日谈公园',
        addedAt: DateTime.now(),
      );

      await repository.saveSubscription(subscription);
      final result = await repository.getSubscriptionByFeedUrl(
        'https://example.com/feed.rss',
      );

      expect(result, isNotNull);
      expect(result!.id, 'sub1');
    });

    test('updates existing subscription on conflict', () async {
      final original = Subscription(
        id: 'sub1',
        feedUrl: 'https://example.com/feed.rss',
        title: 'Old Title',
        addedAt: DateTime(2024, 1, 1),
      );
      final updated = original.copyWith(title: 'New Title');

      await repository.saveSubscription(original);
      await repository.saveSubscription(updated);
      final result = await repository.getSubscription('sub1');

      expect(result!.title, 'New Title');
      expect(result.addedAt, original.addedAt);
    });

    test('updates last refreshed time', () async {
      final subscription = Subscription(
        id: 'sub1',
        feedUrl: 'https://example.com/feed.rss',
        title: '日谈公园',
        addedAt: DateTime.now(),
      );
      await repository.saveSubscription(subscription);

      final refreshedAt = DateTime(2024, 7, 25);
      await repository.updateLastRefreshed('sub1', refreshedAt);

      final result = await repository.getSubscription('sub1');
      expect(result!.lastRefreshedAt, refreshedAt);
    });
  });
}
