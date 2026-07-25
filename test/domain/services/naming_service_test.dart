import 'package:flutter_test/flutter_test.dart';
import 'package:podflow/domain/models/episode.dart';
import 'package:podflow/domain/models/subscription.dart';
import 'package:podflow/domain/services/naming_service.dart';

void main() {
  group('NamingService', () {
    const service = NamingService();
    final subscription = Subscription(
      id: 'sub1',
      feedUrl: 'https://example.com/feed.rss',
      title: '日谈公园',
      addedAt: DateTime.now(),
    );

    test('uses default template', () {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么要读书',
        audioUrl: 'https://example.com/ep1.mp3',
      );

      final filename = service.generateFilename(subscription, episode);
      expect(filename, '为什么要读书 - 日谈公园');
    });

    test('supports custom template order', () {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么要读书',
        audioUrl: 'https://example.com/ep1.mp3',
        episodeNumber: 142,
        publishedAt: DateTime(2024, 7, 1),
      );

      final filename = service.generateFilename(
        subscription,
        episode,
        template: '{show} - #{ep} - {title} - {date}',
      );
      expect(filename, '日谈公园 - #142 - 为什么要读书 - 20240701');
    });

    test('sanitizes illegal filename characters', () {
      final dirty = subscription.copyWith(title: '日谈/公园');
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么:要读书?',
        audioUrl: 'https://example.com/ep1.mp3',
      );

      final filename = service.generateFilename(dirty, episode);
      expect(filename, '为什么_要读书_ - 日谈_公园');
    });

    test('falls back to untitled when template produces empty string', () {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '',
        audioUrl: 'https://example.com/ep1.mp3',
      );

      final filename = service.generateFilename(
        subscription.copyWith(title: ''),
        episode,
        template: '{show}',
      );
      expect(filename, 'untitled');
    });
  });
}
