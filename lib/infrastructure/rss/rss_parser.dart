import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../domain/models/episode.dart';
import '../../domain/models/subscription.dart';

class RssParser {
  final http.Client _client;

  RssParser({http.Client? client}) : _client = client ?? http.Client();

  Future<({Subscription subscription, List<Episode> episodes})> fetchFeed(
    String feedUrl,
  ) async {
    final response = await _client.get(Uri.parse(feedUrl));
    if (response.statusCode != 200) {
      throw RssParseException(
        'Failed to fetch feed: HTTP ${response.statusCode}',
      );
    }
    final subscription = parseSubscription(feedUrl, response.body);
    final episodes = parseEpisodes(subscription.id, response.body);
    return (subscription: subscription, episodes: episodes);
  }

  Subscription parseSubscription(String feedUrl, String xmlString) {
    final document = _parseDocument(xmlString);
    final channel = _channel(document);

    final title = _text(channel, 'title') ?? 'Untitled';
    final description = _text(channel, 'description');
    final link = _text(channel, 'link');
    final author = _text(channel, 'itunes:author');
    final coverUrl = _attribute(channel, 'itunes:image', 'href') ??
        _text(channel, 'image/url');

    return Subscription(
      id: _hash(feedUrl),
      feedUrl: feedUrl,
      title: title,
      description: description,
      coverUrl: coverUrl,
      author: author,
      link: link,
      addedAt: DateTime.now(),
    );
  }

  List<Episode> parseEpisodes(String subscriptionId, String xmlString) {
    final document = _parseDocument(xmlString);
    final channel = _channel(document);
    final items = channel.findElements('item');

    return items
        .map((item) => _parseEpisode(item, subscriptionId))
        .where((episode) => episode.audioUrl.isNotEmpty)
        .toList();
  }

  XmlDocument _parseDocument(String xmlString) {
    try {
      return XmlDocument.parse(xmlString);
    } on XmlParserException catch (e) {
      throw RssParseException('Invalid XML: ${e.message}');
    }
  }

  XmlElement _channel(XmlDocument document) {
    final channel = document
        .findElements('rss')
        .firstOrNull
        ?.findElements('channel')
        .firstOrNull;
    if (channel == null) {
      throw RssParseException('Invalid RSS: no channel element');
    }
    return channel;
  }

  Episode _parseEpisode(XmlElement item, String subscriptionId) {
    final title = _text(item, 'title') ?? 'Untitled';
    final description = _text(item, 'description');
    final audioUrl =
        _attribute(item, 'enclosure', 'url') ?? _audioFromMedia(item);
    final publishedAt = _parsePubDate(_text(item, 'pubDate'));
    final duration = _parseDuration(_text(item, 'itunes:duration'));
    final coverUrl = _attribute(item, 'itunes:image', 'href');
    final episodeNumber = int.tryParse(_text(item, 'itunes:episode') ?? '');

    return Episode(
      id: _hash('$subscriptionId:$audioUrl'),
      subscriptionId: subscriptionId,
      title: title,
      description: description,
      publishedAt: publishedAt,
      duration: duration,
      audioUrl: audioUrl ?? '',
      coverUrl: coverUrl,
      episodeNumber: episodeNumber,
    );
  }

  String? _audioFromMedia(XmlElement item) {
    for (final media in item.findElements('media:content')) {
      if (media.getAttribute('medium') == 'audio') {
        return media.getAttribute('url')?.trim();
      }
    }
    return null;
  }

  static String? _text(XmlElement parent, String name) {
    final element = parent.getElement(name);
    final text = element?.innerText.trim();
    return text?.isNotEmpty == true ? text : null;
  }

  static String? _attribute(
    XmlElement parent,
    String elementName,
    String attributeName,
  ) {
    final element = parent.getElement(elementName);
    final value = element?.getAttribute(attributeName)?.trim();
    return value?.isNotEmpty == true ? value : null;
  }

  static String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  static DateTime? _parsePubDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return HttpDate.parse(value);
    } on FormatException {
      // Fallback for a few non-standard formats.
      final parsed = _tryParseDateTime(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static DateTime? _tryParseDateTime(String value) {
    final patterns = [
      RegExp(r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$'),
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})$'),
      RegExp(r'^(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})$'),
    ];
    for (final pattern in patterns) {
      final m = pattern.firstMatch(value);
      if (m != null) {
        return DateTime(
          int.parse(m.group(1)!),
          int.parse(m.group(2)!),
          int.parse(m.group(3)!),
          int.parse(m.group(4)!),
          int.parse(m.group(5)!),
          int.parse(m.group(6)!),
        );
      }
    }
    return null;
  }

  static Duration? _parseDuration(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':').map(int.tryParse).toList();
    if (parts.length == 3 && parts.every((p) => p != null)) {
      return Duration(
        hours: parts[0]!,
        minutes: parts[1]!,
        seconds: parts[2]!,
      );
    } else if (parts.length == 2 && parts.every((p) => p != null)) {
      return Duration(minutes: parts[0]!, seconds: parts[1]!);
    } else {
      final seconds = int.tryParse(value);
      if (seconds != null) return Duration(seconds: seconds);
    }
    return null;
  }
}

class RssParseException implements Exception {
  final String message;
  RssParseException(this.message);

  @override
  String toString() => 'RssParseException: $message';
}
