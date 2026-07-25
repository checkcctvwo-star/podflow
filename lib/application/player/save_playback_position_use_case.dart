import '../../domain/models/playback_progress.dart';
import '../../domain/repositories/playback_progress_repository.dart';

class SavePlaybackPositionUseCase {
  final PlaybackProgressRepository _repository;

  SavePlaybackPositionUseCase(this._repository);

  /// Persists the current playback [position] for [episodeId].
  Future<void> call({
    required String episodeId,
    required Duration position,
    Duration? total,
  }) async {
    await _repository.saveProgress(
      PlaybackProgress(
        episodeId: episodeId,
        position: position,
        total: total,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
