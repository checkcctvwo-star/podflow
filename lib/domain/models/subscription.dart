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

  const Subscription({
    required this.id,
    required this.feedUrl,
    required this.title,
    this.description,
    this.coverUrl,
    this.author,
    this.link,
    required this.addedAt,
  });

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
      ];
}
