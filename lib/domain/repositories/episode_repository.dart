import '../models/episode.dart';

abstract class EpisodeRepository {
  Future<List<Episode>> getEpisodesForSubscription(String subscriptionId);
  Future<Episode?> getEpisode(String id);
  Future<void> saveEpisodes(List<Episode> episodes);
  Future<void> markDownloaded(String id, {required bool downloaded});
}
