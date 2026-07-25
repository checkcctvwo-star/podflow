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

  Episode copyWith({
    String? id,
    String? subscriptionId,
    String? title,
    String? description,
    DateTime? publishedAt,
    Duration? duration,
    String? audioUrl,
    String? coverUrl,
    int? episodeNumber,
  }) =>
      Episode(
        id: id ?? this.id,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        title: title ?? this.title,
        description: description ?? this.description,
        publishedAt: publishedAt ?? this.publishedAt,
        duration: duration ?? this.duration,
        audioUrl: audioUrl ?? this.audioUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        episodeNumber: episodeNumber ?? this.episodeNumber,
      );

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
