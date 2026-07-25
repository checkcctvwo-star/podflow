import '../models/playback_progress.dart';

abstract class PlaybackProgressRepository {
  Future<PlaybackProgress?> getProgress(String episodeId);
  Future<void> saveProgress(PlaybackProgress progress);
  Future<void> deleteProgress(String episodeId);
}
