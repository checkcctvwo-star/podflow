import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart' as ja;

import '../../application/player/save_playback_position_use_case.dart';
import '../../domain/models/episode.dart';
import '../../domain/services/playback_service.dart';

/// [PlaybackService] implementation backed by the `just_audio` plugin.
class JustAudioPlaybackService implements PlaybackService {
  final ja.AudioPlayer _player;
  final SavePlaybackPositionUseCase? _savePositionUseCase;
  final StreamController<PlaybackState> _stateController;
  Timer? _sleepTimer;
  Episode? _currentEpisode;

  JustAudioPlaybackService({
    ja.AudioPlayer? player,
    SavePlaybackPositionUseCase? savePositionUseCase,
  })  : _player = player ?? ja.AudioPlayer(),
        _savePositionUseCase = savePositionUseCase,
        _stateController = StreamController<PlaybackState>.broadcast() {
    _listenToPlayer();
    _emitState();
  }

  void _listenToPlayer() {
    _player.playerStateStream.listen((_) => _emitState());
    _player.positionStream.listen((_) => _emitState());
    _player.durationStream.listen((_) => _emitState());
    _player.bufferedPositionStream.listen((_) => _emitState());
    _player.speedStream.listen((_) => _emitState());
  }

  void _emitState() {
    final playerState = _player.playerState;
    final processingState = playerState.processingState;
    _stateController.add(
      PlaybackState(
        episode: _currentEpisode,
        isPlaying: playerState.playing,
        position: _player.position,
        duration: _player.duration,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        isLoading: processingState == ja.ProcessingState.loading ||
            processingState == ja.ProcessingState.buffering,
      ),
    );
  }

  @override
  Stream<PlaybackState> get playbackStateStream => _stateController.stream;

  @override
  Future<void> play(Episode episode, {Duration? startPosition}) async {
    _currentEpisode = episode;
    final source = await _resolveAudioSource(episode);
    await _player.setAudioSource(source);
    await _player.seek(startPosition ?? Duration.zero);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    await _persistPosition();
  }

  @override
  Future<void> resume() async => _player.play();

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    await _persistPosition();
  }

  @override
  Future<void> setSpeed(double speed) async => _player.setSpeed(speed);

  @override
  Future<void> skipToPrevious() async {
    // Queue navigation is not implemented in the first version.
  }

  @override
  Future<void> skipToNext() async {
    // Queue navigation is not implemented in the first version.
  }

  @override
  Future<void> setSleepTimer(Duration? duration) async {
    _sleepTimer?.cancel();
    if (duration == null) return;
    _sleepTimer = Timer(duration, () async {
      await pause();
    });
  }

  @override
  Future<void> stop() async {
    await _persistPosition();
    await _player.stop();
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _currentEpisode = null;
    _emitState();
  }

  @override
  Future<void> dispose() async {
    _sleepTimer?.cancel();
    await _stateController.close();
    await _player.dispose();
  }

  Future<ja.AudioSource> _resolveAudioSource(Episode episode) async {
    final localPath = episode.localPath;
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        return ja.AudioSource.file(localPath);
      }
    }
    return ja.AudioSource.uri(Uri.parse(episode.audioUrl));
  }

  Future<void> _persistPosition() async {
    final useCase = _savePositionUseCase;
    final episode = _currentEpisode;
    if (useCase == null || episode == null) return;
    await useCase.call(
      episodeId: episode.id,
      position: _player.position,
      total: _player.duration,
    );
  }
}
