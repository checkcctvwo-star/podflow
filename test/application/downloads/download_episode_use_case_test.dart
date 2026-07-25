import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:podflow/application/downloads/download_episode_use_case.dart';
import 'package:podflow/domain/models/episode.dart';
import 'package:podflow/domain/repositories/episode_repository.dart';
import 'package:podflow/domain/services/download_service.dart';

class MockDownloadService extends Mock implements DownloadService {}

class MockEpisodeRepository extends Mock implements EpisodeRepository {}

void main() {
  group('DownloadEpisodeUseCase', () {
    late DownloadService downloadService;
    late EpisodeRepository episodeRepository;
    late DownloadEpisodeUseCase useCase;

    setUp(() {
      downloadService = MockDownloadService();
      episodeRepository = MockEpisodeRepository();
      useCase = DownloadEpisodeUseCase(
        downloadService: downloadService,
        episodeRepository: episodeRepository,
      );
    });

    test('downloads audio and marks episode as downloaded', () async {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么要读书',
        audioUrl: 'https://example.com/ep1.mp3',
      );

      when(
        () => downloadService.download(
          url: any(named: 'url'),
          destinationPath: any(named: 'destinationPath'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {});
      when(() => episodeRepository.markDownloaded(any(), downloaded: any(named: 'downloaded')))
          .thenAnswer((_) async {});

      await useCase(episode, '/tmp/ep1.mp3');

      verify(
        () => downloadService.download(
          url: 'https://example.com/ep1.mp3',
          destinationPath: '/tmp/ep1.mp3',
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
      verify(() => episodeRepository.markDownloaded('ep1', downloaded: true))
          .called(1);
    });

    test('does not mark downloaded when download fails', () async {
      final episode = Episode(
        id: 'ep1',
        subscriptionId: 'sub1',
        title: '为什么要读书',
        audioUrl: 'https://example.com/ep1.mp3',
      );

      when(
        () => downloadService.download(
          url: any(named: 'url'),
          destinationPath: any(named: 'destinationPath'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(Exception('network error'));

      expect(() => useCase(episode, '/tmp/ep1.mp3'), throwsException);
      verifyNever(
        () => episodeRepository.markDownloaded(any(), downloaded: any(named: 'downloaded')),
      );
    });
  });
}
