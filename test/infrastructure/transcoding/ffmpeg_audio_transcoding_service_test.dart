import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:podflow/domain/services/audio_transcoding_service.dart';
import 'package:podflow/infrastructure/transcoding/ffmpeg_audio_transcoding_service.dart';
import 'package:podflow/infrastructure/transcoding/ffmpeg_executors.dart';

class MockFfmpegExecutor extends Mock implements FfmpegExecutor {}

void main() {
  group('FfmpegAudioTranscodingService', () {
    late MockFfmpegExecutor executor;
    late FfmpegAudioTranscodingService service;

    setUp(() {
      executor = MockFfmpegExecutor();
      service = FfmpegAudioTranscodingService(executor);
    });

    test('transcodes to mp3 by default', () async {
      when(() => executor.run(any())).thenAnswer((_) async {});

      await service.transcode('/tmp/input.m4a', '/tmp/output.mp3');

      final captured = verify(() => executor.run(captureAny())).captured.single
          as List<String>;
      expect(captured, containsAllInOrder([
        '-y', '-i', '/tmp/input.m4a', '-map_metadata', '-1',
        '-codec:a', 'libmp3lame', '-q:a', '4', '/tmp/output.mp3'
      ]));
    });

    test('transcodes to wav', () async {
      when(() => executor.run(any())).thenAnswer((_) async {});

      await service.transcode('/tmp/input.mp3', '/tmp/output.wav', format: 'wav');

      final captured = verify(() => executor.run(captureAny())).captured.single
          as List<String>;
      expect(captured, containsAllInOrder([
        '-y', '-i', '/tmp/input.mp3', '-map_metadata', '-1',
        '-codec:a', 'pcm_s16le', '/tmp/output.wav'
      ]));
    });

    test('transcodes to m4a', () async {
      when(() => executor.run(any())).thenAnswer((_) async {});

      await service.transcode('/tmp/input.mp3', '/tmp/output.m4a', format: 'm4a');

      final captured = verify(() => executor.run(captureAny())).captured.single
          as List<String>;
      expect(captured, containsAllInOrder([
        '-y', '-i', '/tmp/input.mp3', '-map_metadata', '-1',
        '-codec:a', 'aac', '-b:a', '128k', '/tmp/output.m4a'
      ]));
    });

    test('throws TranscodingException on executor failure', () async {
      when(() => executor.run(any()))
          .thenThrow(TranscodingException('encoder error'));

      expect(
        () => service.transcode('/tmp/input.mp3', '/tmp/output.mp3'),
        throwsA(isA<TranscodingException>()),
      );
    });
  });
}
