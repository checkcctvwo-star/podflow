import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:podflow/application/subscriptions/import_subscription_use_case.dart';
import 'package:podflow/domain/models/episode.dart';
import 'package:podflow/domain/models/subscription.dart';
import 'package:podflow/domain/repositories/episode_repository.dart';
import 'package:podflow/domain/repositories/subscription_repository.dart';
import 'package:podflow/infrastructure/rss/rss_parser.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockEpisodeRepository extends Mock implements EpisodeRepository {}

class SubscriptionFake extends Fake implements Subscription {}

const _sampleRss = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
  <channel>
    <title>日谈公园</title>
    <description>中文播客</description>
    <link>https://example.com/ritan</link>
    <itunes:author>日谈公园</itunes:author>
    <itunes:image href="https://example.com/ritan/cover.jpg"/>
    <item>
      <title>为什么要读书</title>
      <description>一期关于读书的播客</description>
      <pubDate>Mon, 01 Jul 2024 08:00:00 GMT</pubDate>
      <enclosure url="https://example.com/ritan/ep1.mp3" type="audio/mpeg" length="12345678"/>
      <itunes:duration>45:30</itunes:duration>
      <itunes:episode>142</itunes:episode>
    </item>
  </channel>
</rss>
''';

void main() {
  setUpAll(() {
    registerFallbackValue(SubscriptionFake());
  });

  group('ImportSubscriptionUseCase', () {
    late SubscriptionRepository subscriptionRepository;
    late EpisodeRepository episodeRepository;
    late ImportSubscriptionUseCase useCase;

    setUp(() {
      subscriptionRepository = MockSubscriptionRepository();
      episodeRepository = MockEpisodeRepository();
      final client = MockClient((request) async {
        if (request.url.toString() == 'https://example.com/ritan.rss') {
          return http.Response(
            _sampleRss,
            200,
            headers: {'content-type': 'application/rss+xml; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });
      useCase = ImportSubscriptionUseCase(
        rssParser: RssParser(client: client),
        subscriptionRepository: subscriptionRepository,
        episodeRepository: episodeRepository,
      );
    });

    test('imports a new subscription and its episodes', () async {
      when(() => subscriptionRepository.getSubscriptionByFeedUrl(any()))
          .thenAnswer((_) async => null);
      when(() => subscriptionRepository.saveSubscription(any()))
          .thenAnswer((_) async {});
      when(() => episodeRepository.saveEpisodes(any()))
          .thenAnswer((_) async {});

      final subscription = await useCase('https://example.com/ritan.rss');

      expect(subscription.title, '日谈公园');
      expect(subscription.feedUrl, 'https://example.com/ritan.rss');
      verify(() => subscriptionRepository.saveSubscription(subscription))
          .called(1);
      verify(() => episodeRepository.saveEpisodes(any(that: hasLength(1))))
          .called(1);
    });

    test('refreshes an existing subscription while keeping id and addedAt',
        () async {
      final existing = Subscription(
        id: 'existing-id',
        feedUrl: 'https://example.com/ritan.rss',
        title: 'Old Title',
        addedAt: DateTime(2024, 1, 1),
      );
      when(() => subscriptionRepository.getSubscriptionByFeedUrl(any()))
          .thenAnswer((_) async => existing);
      when(() => subscriptionRepository.saveSubscription(any()))
          .thenAnswer((_) async {});
      when(() => subscriptionRepository.updateLastRefreshed(any(), any()))
          .thenAnswer((_) async {});
      when(() => episodeRepository.saveEpisodes(any()))
          .thenAnswer((_) async {});

      final subscription = await useCase('https://example.com/ritan.rss');

      expect(subscription.id, 'existing-id');
      expect(subscription.title, '日谈公园');
      expect(subscription.addedAt, existing.addedAt);
      verify(() => subscriptionRepository.saveSubscription(subscription))
          .called(1);
      verify(() => episodeRepository.saveEpisodes(any())).called(1);
      verify(() => subscriptionRepository.updateLastRefreshed(any(), any()))
          .called(1);
    });
  });
}
