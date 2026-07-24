import 'package:equatable/equatable.dart';

class Episode extends Equatable {
  final String id;
  final String subscriptionId;
  final String title;
  final String? description;
  final DateTime? publishedAt;
  final Duration? duration;
  final String audioUrl;
  final String? coverUrl;
  final int? episodeNumber;

  const Episode({
    required this.id,
    required this.subscriptionId,
    required this.title,
    this.description,
    this.publishedAt,
    this.duration,
    required this.audioUrl,
    this.coverUrl,
    this.episodeNumber,
  });

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        title,
        description,
        publishedAt,
        duration,
        audioUrl,
        coverUrl,
        episodeNumber,
      ];
}
