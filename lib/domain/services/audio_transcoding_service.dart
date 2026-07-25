abstract class AudioTranscodingService {
  /// Transcodes [inputPath] to [outputPath] in the requested [format].
  /// Supported formats: mp3, wav, m4a.
  Future<void> transcode(
    String inputPath,
    String outputPath, {
    String format = 'mp3',
  });
}

class TranscodingException implements Exception {
  final String message;
  TranscodingException(this.message);

  @override
  String toString() => 'TranscodingException: $message';
}
