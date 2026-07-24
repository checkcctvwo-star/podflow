import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:podflow/infrastructure/rss/rss_parser.dart';

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
    <item>
      <title>没有音频的单集</title>
      <description>这集没有 enclosure</description>
      <pubDate>Mon, 02 Jul 2024 08:00:00 GMT</pubDate>
    </item>
  </channel>
</rss>
''';

void main() {
  group('RssParser', () {
    test('parses subscription from XML string', () {
      final parser = RssParser();
      final subscription = parser.parseSubscription(
        'https://example.com/ritan.rss',
        _sampleRss,
      );

      expect(subscription.title, '日谈公园');
      expect(subscription.feedUrl, 'https://example.com/ritan.rss');
      expect(subscription.description, '中文播客');
      expect(subscription.author, '日谈公园');
      expect(subscription.coverUrl, 'https://example.com/ritan/cover.jpg');
    });

    test('parses episodes from XML string', () {
      final parser = RssParser();
      final subscriptionId = parser.parseSubscription(
        'https://example.com/ritan.rss',
        _sampleRss,
      ).id;
      final episodes = parser.parseEpisodes(subscriptionId, _sampleRss);

      expect(episodes.length, 1);
      final ep = episodes.first;
      expect(ep.title, '为什么要读书');
      expect(ep.subscriptionId, subscriptionId);
      expect(ep.audioUrl, 'https://example.com/ritan/ep1.mp3');
      expect(ep.duration, const Duration(minutes: 45, seconds: 30));
      expect(ep.episodeNumber, 142);
      expect(ep.publishedAt, DateTime.utc(2024, 7, 1, 8, 0, 0));
    });

    test('fetches feed via HTTP client', () async {
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
      final parser = RssParser(client: client);
      final result = await parser.fetchFeed('https://example.com/ritan.rss');

      expect(result.subscription.title, '日谈公园');
      expect(result.episodes.length, 1);
    });

    test('throws on non-200 status', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      final parser = RssParser(client: client);

      expect(
        () => parser.fetchFeed('https://example.com/ritan.rss'),
        throwsA(isA<RssParseException>()),
      );
    });

    test('throws on invalid XML', () {
      final parser = RssParser();
      expect(
        () => parser.parseSubscription('https://example.com/bad.rss', 'not xml'),
        throwsA(isA<RssParseException>()),
      );
    });
  });
}
