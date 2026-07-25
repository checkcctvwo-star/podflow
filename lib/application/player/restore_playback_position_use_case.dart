import '../../domain/models/episode.dart';
import '../../domain/repositories/playback_progress_repository.dart';

class RestorePlaybackPositionUseCase {
  final PlaybackProgressRepository _repository;

  RestorePlaybackPositionUseCase(this._repository);

  /// Returns the last saved playback position for [episodeId], or
  /// [Duration.zero] if no progress has been recorded.
  Future<Duration> call(String episodeId) async {
    final progress = await _repository.getProgress(episodeId);
    return progress?.position ?? Duration.zero;
  }
}
