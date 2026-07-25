import 'package:drift/drift.dart';

import '../../domain/models/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../database/app_database.dart' as drift;

class DriftSubscriptionRepository implements SubscriptionRepository {
  final drift.AppDatabase _db;

  DriftSubscriptionRepository(this._db);

  @override
  Future<Subscription?> getSubscription(String id) async {
    final row = await (_db.select(_db.subscriptions)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Subscription?> getSubscriptionByFeedUrl(String feedUrl) async {
    final row = await (_db.select(_db.subscriptions)
          ..where((s) => s.feedUrl.equals(feedUrl)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    final rows = await _db.select(_db.subscriptions).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    await _db.into(_db.subscriptions).insertOnConflictUpdate(
          drift.SubscriptionsCompanion(
            id: Value(subscription.id),
            feedUrl: Value(subscription.feedUrl),
            title: Value(subscription.title),
            description: Value(subscription.description),
            coverUrl: Value(subscription.coverUrl),
            author: Value(subscription.author),
            link: Value(subscription.link),
            addedAt: Value(subscription.addedAt),
          ),
        );
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await (_db.delete(_db.subscriptions)..where((s) => s.id.equals(id))).go();
  }

  @override
  Future<void> updateLastRefreshed(String id, DateTime time) async {
    await (_db.update(_db.subscriptions)..where((s) => s.id.equals(id))).write(
      drift.SubscriptionsCompanion(lastRefreshedAt: Value(time)),
    );
  }

  Subscription _toDomain(drift.Subscription row) => Subscription(
        id: row.id,
        feedUrl: row.feedUrl,
        title: row.title,
        description: row.description,
        coverUrl: row.coverUrl,
        author: row.author,
        link: row.link,
        addedAt: row.addedAt,
        lastRefreshedAt: row.lastRefreshedAt,
      );
}
