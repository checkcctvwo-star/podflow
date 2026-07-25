import 'package:drift/drift.dart';

import 'converters/download_status.dart';

class Subscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get feedUrl => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get link => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastRefreshedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Episodes extends Table {
  TextColumn get id => text()();
  TextColumn get subscriptionId => text().references(Subscriptions, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get audioUrl => text()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DownloadTasks extends Table {
  TextColumn get id => text()();
  TextColumn get episodeId => text().references(Episodes, #id)();
  TextColumn get status => text().map(const DownloadStatusConverter())();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  TextColumn get localPath => text().nullable()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaybackProgress extends Table {
  TextColumn get episodeId => text().references(Episodes, #id)();
  IntColumn get positionMillis => integer().withDefault(const Constant(0))();
  IntColumn get totalMillis => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {episodeId};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class DownloadStatusConverter extends TypeConverter<DownloadStatus, String> {
  const DownloadStatusConverter();

  @override
  DownloadStatus fromSql(String fromDb) => DownloadStatus.values.byName(fromDb);

  @override
  String toSql(DownloadStatus value) => value.name;
}
