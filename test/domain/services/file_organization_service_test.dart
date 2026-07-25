import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:podflow/domain/models/episode.dart';
import 'package:podflow/domain/models/subscription.dart';
import 'package:podflow/domain/services/file_organization_service.dart';

void main() {
  group('FileOrganizationService', () {
    const service = FileOrganizationService();
    final subscription = Subscription(
      id: 'sub1',
      feedUrl: 'https://example.com/feed.rss',
      title: '日谈公园',
      addedAt: DateTime.now(),
    );
    final episode = Episode(
      id: 'ep1',
      subscriptionId: 'sub1',
      title: '为什么要读书',
      audioUrl: 'https://example.com/ep1.mp3',
    );

    test('generates path with default template', () {
      final path = service.generateEpisodePath(
        subscription: subscription,
        episode: episode,
        rootDirectory: 'podcasts',
        extension: 'mp3',
      );
      expect(
        path,
        p.join('podcasts', '日谈公园', '为什么要读书 - 日谈公园.mp3'),
      );
    });

    test('strips leading dot from extension', () {
      final path = service.generateEpisodePath(
        subscription: subscription,
        episode: episode,
        rootDirectory: 'podcasts',
        extension: '.mp3',
      );
      expect(
        path,
        p.join('podcasts', '日谈公园', '为什么要读书 - 日谈公园.mp3'),
      );
    });

    test('sanitizes show folder name', () {
      final dirtySubscription = subscription.copyWith(title: '日谈/公园');
      final path = service.generateEpisodePath(
        subscription: dirtySubscription,
        episode: episode,
        rootDirectory: 'podcasts',
        extension: 'mp3',
      );
      expect(
        path,
        p.join('podcasts', '日谈_公园', '为什么要读书 - 日谈_公园.mp3'),
      );
    });
  });
}
