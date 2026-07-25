import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../../domain/services/audio_transcoding_service.dart';

abstract class FfmpegExecutor {
  Future<void> run(List<String> arguments);
}

class MobileFfmpegExecutor implements FfmpegExecutor {
  @override
  Future<void> run(List<String> arguments) async {
    final session = await FFmpegKit.execute(arguments.join(' '));
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      final output = await session.getOutput() ?? '';
      final logs = await session.getLogs();
      final logText = logs.map((l) => l.getMessage()).join('\n');
      throw TranscodingException('$output\n$logText');
    }
  }
}

class DesktopFfmpegExecutor implements FfmpegExecutor {
  final String ffmpegPath;

  DesktopFfmpegExecutor({this.ffmpegPath = 'ffmpeg.exe'});

  @override
  Future<void> run(List<String> arguments) async {
    final result = await Process.run(ffmpegPath, arguments);
    if (result.exitCode != 0) {
      throw TranscodingException(
        result.stderr?.toString() ?? 'ffmpeg failed with exit ${result.exitCode}',
      );
    }
  }
}
