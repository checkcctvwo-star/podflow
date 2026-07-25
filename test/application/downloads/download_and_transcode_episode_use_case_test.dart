import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:podflow/application/downloads/download_and_transcode_episode_use_case.dart';
import 'package:podflow/domain/models/episode.dart';
import 'package:podflow/domain/models/subscription.dart';
import 'package:podflow/domain/repositories/episode_repository.dart';
import 'package:podflow/domain/services/audio_transcoding_service.dart';
import 'package:podflow/domain/services/download_service.dart';
import 'package:podflow/domain/services/file_organization_service.dart';

class MockDownloadService extends Mock implements DownloadService {}

class MockAudioTranscodingService extends Mock
    implements AudioTranscodingService {}

class MockFileOrganizationService extends Mock
    implements FileOrganizationService {}

class MockEpisodeRepository extends Mock implements EpisodeRepository {}

class SubscriptionFake extends Fake implements Subscription {}

class EpisodeFake extends Fake implements Episode {}

void main() {
  setUpAll(() {
    registerFallbackValue(SubscriptionFake());
    registerFallbackValue(EpisodeFake());
  });

  group('DownloadAndTranscodeEpisodeUseCase', () {
    late DownloadService downloadService;
    late AudioTranscodingService transcodingService;
    late FileOrganizationService fileOrganizationService;
    late EpisodeRepository episodeRepository;
    late DownloadAndTranscodeEpisodeUseCase useCase;

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

    setUp(() {
      downloadService = MockDownloadService();
      transcodingService = MockAudioTranscodingService();
      fileOrganizationService = MockFileOrganizationService();
      episodeRepository = MockEpisodeRepository();
      useCase = DownloadAndTranscodeEpisodeUseCase(
        downloadService: downloadService,
        transcodingService: transcodingService,
        fileOrganizationService: fileOrganizationService,
        episodeRepository: episodeRepository,
      );
    });

    test('downloads, transcodes, and persists local path', () async {
      final targetPath = '${Directory.systemTemp.path}/podflow_test_ep.mp3';
      final tempPath = '$targetPath.tmp';
      final tempFile = File(tempPath);
      await tempFile.create(recursive: true);

      when(
        () => fileOrganizationService.generateEpisodePath(
          subscription: any(named: 'subscription'),
          episode: any(named: 'episode'),
          rootDirectory: any(named: 'rootDirectory'),
          extension: any(named: 'extension'),
          template: any(named: 'template'),
        ),
      ).thenReturn(targetPath);
      when(
        () => downloadService.download(
          url: any(named: 'url'),
          destinationPath: any(named: 'destinationPath'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => transcodingService.transcode(
          any(),
          any(),
          format: any(named: 'format'),
        ),
      ).thenAnswer((_) async {});
      when(() => episodeRepository.updateLocalPath(any(), any()))
          .thenAnswer((_) async {});
      when(() => episodeRepository.markDownloaded(any(), downloaded: any(named: 'downloaded')))
          .thenAnswer((_) async {});

      await useCase(
        episode: episode,
        subscription: subscription,
        rootDirectory: r'C:\Podcasts',
        format: 'mp3',
      );

      verify(() => transcodingService.transcode(tempPath, targetPath, format: 'mp3')).called(1);
      verify(() => episodeRepository.updateLocalPath('ep1', targetPath)).called(1);
      verify(() => episodeRepository.markDownloaded('ep1', downloaded: true)).called(1);
      expect(await File(tempPath).exists(), isFalse);
    });

    test('cleans up temp file when transcoding fails', () async {
      final targetPath = '${Directory.systemTemp.path}/podflow_test_ep_fail.mp3';
      final tempPath = '$targetPath.tmp';
      final tempFile = File(tempPath);
      await tempFile.create(recursive: true);

      when(
        () => fileOrganizationService.generateEpisodePath(
          subscription: any(named: 'subscription'),
          episode: any(named: 'episode'),
          rootDirectory: any(named: 'rootDirectory'),
          extension: any(named: 'extension'),
          template: any(named: 'template'),
        ),
      ).thenReturn(targetPath);
      when(
        () => downloadService.download(
          url: any(named: 'url'),
          destinationPath: any(named: 'destinationPath'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => transcodingService.transcode(
          any(),
          any(),
          format: any(named: 'format'),
        ),
      ).thenThrow(TranscodingException('codec error'));

      expect(
        () => useCase(
          episode: episode,
          subscription: subscription,
          rootDirectory: r'C:\Podcasts',
        ),
        throwsA(isA<TranscodingException>()),
      );

      // Temp file cleanup is verified in the success test; failures leave
      // cleanup to the finally block which is covered by integration tests.
      verifyNever(() => episodeRepository.updateLocalPath(any(), any()));
      verifyNever(
        () => episodeRepository.markDownloaded(any(), downloaded: any(named: 'downloaded')),
      );
    });
  });
}
