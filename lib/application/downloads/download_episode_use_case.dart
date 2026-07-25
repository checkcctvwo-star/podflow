import '../../domain/models/episode.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../domain/services/download_service.dart';

class DownloadEpisodeUseCase {
  final DownloadService _downloadService;
  final EpisodeRepository _episodeRepository;

  DownloadEpisodeUseCase({
    required DownloadService downloadService,
    required EpisodeRepository episodeRepository,
  })  : _downloadService = downloadService,
        _episodeRepository = episodeRepository;

  /// Downloads an episode's audio file to [destinationPath] and marks it
  /// downloaded in the repository.
  Future<void> call(Episode episode, String destinationPath) async {
    await _downloadService.download(
      url: episode.audioUrl,
      destinationPath: destinationPath,
      onProgress: (_) {
        // Progress streaming will be added when the download manager is built.
      },
    );
    await _episodeRepository.markDownloaded(
      episode.id,
      downloaded: true,
    );
  }
}
