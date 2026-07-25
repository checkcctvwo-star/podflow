import 'package:equatable/equatable.dart';

/// Represents the last known playback position for a single episode.
class PlaybackProgress extends Equatable {
  final String episodeId;
  final Duration position;
  final Duration? total;
  final DateTime updatedAt;

  const PlaybackProgress({
    required this.episodeId,
    required this.position,
    this.total,
    required this.updatedAt,
  });

  PlaybackProgress copyWith({
    String? episodeId,
    Duration? position,
    Duration? total,
    DateTime? updatedAt,
  }) =>
      PlaybackProgress(
        episodeId: episodeId ?? this.episodeId,
        position: position ?? this.position,
        total: total ?? this.total,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [episodeId, position, total, updatedAt];
}
