import '../../domain/services/audio_transcoding_service.dart';
import 'ffmpeg_executors.dart';

class FfmpegAudioTranscodingService implements AudioTranscodingService {
  final FfmpegExecutor _executor;

  FfmpegAudioTranscodingService(this._executor);

  @override
  Future<void> transcode(
    String inputPath,
    String outputPath, {
    String format = 'mp3',
  }) async {
    final args = [
      '-y',
      '-i',
      inputPath,
      '-map_metadata',
      '-1',
      ..._codecArgs(format),
      outputPath,
    ];
    await _executor.run(args);
  }

  List<String> _codecArgs(String format) {
    switch (format.toLowerCase()) {
      case 'wav':
        return const ['-codec:a', 'pcm_s16le'];
      case 'm4a':
      case 'aac':
        return const ['-codec:a', 'aac', '-b:a', '128k'];
      case 'mp3':
      default:
        return const ['-codec:a', 'libmp3lame', '-q:a', '4'];
    }
  }
}
