import '../models/subscription.dart';

abstract class SubscriptionRepository {
  Future<Subscription?> getSubscription(String id);
  Future<Subscription?> getSubscriptionByFeedUrl(String feedUrl);
  Future<List<Subscription>> getAllSubscriptions();
  Future<void> saveSubscription(Subscription subscription);
  Future<void> deleteSubscription(String id);
  Future<void> updateLastRefreshed(String id, DateTime time);
}
