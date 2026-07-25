import 'package:equatable/equatable.dart';

import '../models/episode.dart';

/// Immutable snapshot of the audio player's current state.
class PlaybackState extends Equatable {
  final Episode? episode;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final Duration bufferedPosition;
  final double speed;
  final bool isLoading;

  const PlaybackState({
    this.episode,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration,
    this.bufferedPosition = Duration.zero,
    this.speed = 1.0,
    this.isLoading = false,
  });

  PlaybackState copyWith({
    Episode? episode,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    bool? isLoading,
    bool clearEpisode = false,
    bool clearDuration = false,
  }) =>
      PlaybackState(
        episode: clearEpisode ? null : (episode ?? this.episode),
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: clearDuration ? null : (duration ?? this.duration),
        bufferedPosition: bufferedPosition ?? this.bufferedPosition,
        speed: speed ?? this.speed,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [
        episode,
        isPlaying,
        position,
        duration,
        bufferedPosition,
        speed,
        isLoading,
      ];
}

/// Abstract audio player interface used by the presentation layer.
abstract class PlaybackService {
  /// Continuous stream of playback state changes.
  Stream<PlaybackState> get playbackStateStream;

  /// Plays [episode], optionally resuming from [startPosition].
  Future<void> play(Episode episode, {Duration? startPosition});

  /// Pauses playback.
  Future<void> pause();

  /// Resumes playback.
  Future<void> resume();

  /// Seeks to [position].
  Future<void> seek(Duration position);

  /// Sets playback [speed] (e.g. 1.0, 1.5, 2.0).
  Future<void> setSpeed(double speed);

  /// Skips to the previous item in the queue if available.
  Future<void> skipToPrevious();

  /// Skips to the next item in the queue if available.
  Future<void> skipToNext();

  /// Sets a sleep timer that pauses after [duration]. Pass null to cancel.
  Future<void> setSleepTimer(Duration? duration);

  /// Stops playback and releases the current item.
  Future<void> stop();

  /// Disposes the player and releases resources.
  Future<void> dispose();
}
