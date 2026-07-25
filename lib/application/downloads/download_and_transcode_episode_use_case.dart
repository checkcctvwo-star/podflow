import 'dart:io';

import '../../domain/models/episode.dart';
import '../../domain/models/subscription.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../domain/services/audio_transcoding_service.dart';
import '../../domain/services/download_service.dart';
import '../../domain/services/file_organization_service.dart';

class DownloadAndTranscodeEpisodeUseCase {
  final DownloadService _downloadService;
  final AudioTranscodingService _transcodingService;
  final FileOrganizationService _fileOrganizationService;
  final EpisodeRepository _episodeRepository;

  DownloadAndTranscodeEpisodeUseCase({
    required DownloadService downloadService,
    required AudioTranscodingService transcodingService,
    required FileOrganizationService fileOrganizationService,
    required EpisodeRepository episodeRepository,
  })  : _downloadService = downloadService,
        _transcodingService = transcodingService,
        _fileOrganizationService = fileOrganizationService,
        _episodeRepository = episodeRepository;

  /// Downloads an episode, transcodes it to [format], moves it to the
  /// organized destination under [rootDirectory], and persists the local path.
  Future<void> call({
    required Episode episode,
    required Subscription subscription,
    required String rootDirectory,
    String format = 'mp3',
    String? namingTemplate,
  }) async {
    final targetPath = _fileOrganizationService.generateEpisodePath(
      subscription: subscription,
      episode: episode,
      rootDirectory: rootDirectory,
      extension: format,
      template: namingTemplate,
    );

    final tempPath = '$targetPath.tmp';

    try {
      await _downloadService.download(
        url: episode.audioUrl,
        destinationPath: tempPath,
        onProgress: (_) {
          // Progress streaming will be added later.
        },
      );

      await _transcodingService.transcode(
        tempPath,
        targetPath,
        format: format,
      );

      await _episodeRepository.updateLocalPath(episode.id, targetPath);
      await _episodeRepository.markDownloaded(
        episode.id,
        downloaded: true,
      );
    } finally {
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
