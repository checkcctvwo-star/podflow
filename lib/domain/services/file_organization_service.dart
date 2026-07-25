import 'package:path/path.dart' as p;

import '../models/episode.dart';
import '../models/subscription.dart';
import 'naming_service.dart';

class FileOrganizationService {
  final NamingService _namingService;

  const FileOrganizationService({NamingService? namingService})
      : _namingService = namingService ?? const NamingService();

  /// Generates the final file path for an episode.
  ///
  /// Structure: [rootDirectory]/[sanitized show name]/[filename].[extension]
  String generateEpisodePath({
    required Subscription subscription,
    required Episode episode,
    required String rootDirectory,
    required String extension,
    String? template,
  }) {
    final showFolder = _namingService.sanitizeFolderName(subscription.title);
    final filename = _namingService.generateFilename(
      subscription,
      episode,
      template: template ?? NamingService.defaultTemplate,
    );
    final cleanExtension = extension.replaceAll('.', '');
    return p.join(rootDirectory, showFolder, '$filename.$cleanExtension');
  }
}
