import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final String id;
  final String feedUrl;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? author;
  final String? link;
  final DateTime addedAt;
  final DateTime? lastRefreshedAt;

  const Subscription({
    required this.id,
    required this.feedUrl,
    required this.title,
    this.description,
    this.coverUrl,
    this.author,
    this.link,
    required this.addedAt,
    this.lastRefreshedAt,
  });

  Subscription copyWith({
    String? id,
    String? feedUrl,
    String? title,
    String? description,
    String? coverUrl,
    String? author,
    String? link,
    DateTime? addedAt,
    DateTime? lastRefreshedAt,
  }) =>
      Subscription(
        id: id ?? this.id,
        feedUrl: feedUrl ?? this.feedUrl,
        title: title ?? this.title,
        description: description ?? this.description,
        coverUrl: coverUrl ?? this.coverUrl,
        author: author ?? this.author,
        link: link ?? this.link,
        addedAt: addedAt ?? this.addedAt,
        lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
      );

  @override
  List<Object?> get props => [
        id,
        feedUrl,
        title,
        description,
        coverUrl,
        author,
        link,
        addedAt,
        lastRefreshedAt,
      ];
}
