import '../../domain/models/episode.dart';
import '../../domain/models/subscription.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../infrastructure/rss/rss_parser.dart';

class ImportSubscriptionUseCase {
  final RssParser _rssParser;
  final SubscriptionRepository _subscriptionRepository;
  final EpisodeRepository _episodeRepository;

  ImportSubscriptionUseCase({
    required RssParser rssParser,
    required SubscriptionRepository subscriptionRepository,
    required EpisodeRepository episodeRepository,
  })  : _rssParser = rssParser,
        _subscriptionRepository = subscriptionRepository,
        _episodeRepository = episodeRepository;

  /// Imports or refreshes a subscription from an RSS feed URL.
  Future<Subscription> call(String feedUrl) async {
    final existing =
        await _subscriptionRepository.getSubscriptionByFeedUrl(feedUrl);

    final result = await _rssParser.fetchFeed(feedUrl);

    if (existing != null) {
      // Refresh: keep original id and addedAt, update metadata and episodes.
      final subscription = existing.copyWith(
        title: result.subscription.title,
        description: result.subscription.description,
        coverUrl: result.subscription.coverUrl,
        author: result.subscription.author,
        link: result.subscription.link,
      );
      await _subscriptionRepository.saveSubscription(subscription);
      await _episodeRepository.saveEpisodes(result.episodes);
      await _subscriptionRepository.updateLastRefreshed(
        existing.id,
        DateTime.now(),
      );
      return subscription;
    } else {
      await _subscriptionRepository.saveSubscription(result.subscription);
      await _episodeRepository.saveEpisodes(result.episodes);
      return result.subscription;
    }
  }
}
