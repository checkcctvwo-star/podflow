abstract class DownloadService {
  /// Downloads [url] to [destinationPath] and reports progress via [onProgress].
  /// Throws on failure.
  Future<void> download({
    required String url,
    required String destinationPath,
    required void Function(double progress) onProgress,
  });
}
