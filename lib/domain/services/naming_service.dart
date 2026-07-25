import '../models/episode.dart';
import '../models/subscription.dart';

class NamingService {
  const NamingService();

  static const defaultTemplate = '{title} - {show}';

  /// Generates a safe filename for an episode using [template].
  /// [template] may contain placeholders:
  ///   {show}    - subscription title
  ///   {title}   - episode title
  ///   {ep}      - episode number
  ///   {date}    - episode publish date as YYYYMMDD
  String generateFilename(
    Subscription subscription,
    Episode episode, {
    String template = defaultTemplate,
  }) {
    var filename = template;

    filename = filename.replaceAll('{show}', _sanitize(subscription.title));
    filename = filename.replaceAll('{title}', _sanitize(episode.title));
    filename = filename.replaceAll(
      '{ep}',
      episode.episodeNumber?.toString() ?? '',
    );
    filename = filename.replaceAll(
      '{date}',
      episode.publishedAt != null
          ? _formatDate(episode.publishedAt!)
          : '',
    );

    // Collapse multiple spaces/trim after placeholder replacements.
    filename = filename.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Trim trailing dashes or spaces.
    filename = filename.replaceAll(RegExp(r'[-\s]+$'), '');

    return filename.isNotEmpty ? filename : 'untitled';
  }

  /// Sanitizes a string so it can be safely used in a file or folder name.
  static String _sanitize(String input) {
    // Replace Windows/Android reserved characters.
    var safe = input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    // Collapse whitespace.
    safe = safe.replaceAll(RegExp(r'\s+'), ' ').trim();
    return safe;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Sanitizes a folder name.
  String sanitizeFolderName(String name) => _sanitize(name).replaceAll('.', '_');
}
