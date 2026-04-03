// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArtistTableTable extends ArtistTable
    with TableInfo<$ArtistTableTable, ArtistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ArtistTableTable createAlias(String alias) {
    return $ArtistTableTable(attachedDatabase, alias);
  }
}

class ArtistTableData extends DataClass implements Insertable<ArtistTableData> {
  final int id;
  final String name;
  const ArtistTableData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ArtistTableCompanion toCompanion(bool nullToAbsent) {
    return ArtistTableCompanion(id: Value(id), name: Value(name));
  }

  factory ArtistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ArtistTableData copyWith({int? id, String? name}) =>
      ArtistTableData(id: id ?? this.id, name: name ?? this.name);
  ArtistTableData copyWithCompanion(ArtistTableCompanion data) {
    return ArtistTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistTableData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistTableData &&
          other.id == this.id &&
          other.name == this.name);
}

class ArtistTableCompanion extends UpdateCompanion<ArtistTableData> {
  final Value<int> id;
  final Value<String> name;
  const ArtistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ArtistTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<ArtistTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ArtistTableCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ArtistTableCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $AlbumTableTable extends AlbumTable
    with TableInfo<$AlbumTableTable, AlbumTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<int> artist = GeneratedColumn<int>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artist_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, artist];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artist'],
      )!,
    );
  }

  @override
  $AlbumTableTable createAlias(String alias) {
    return $AlbumTableTable(attachedDatabase, alias);
  }
}

class AlbumTableData extends DataClass implements Insertable<AlbumTableData> {
  final int id;
  final String name;
  final int artist;
  const AlbumTableData({
    required this.id,
    required this.name,
    required this.artist,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['artist'] = Variable<int>(artist);
    return map;
  }

  AlbumTableCompanion toCompanion(bool nullToAbsent) {
    return AlbumTableCompanion(
      id: Value(id),
      name: Value(name),
      artist: Value(artist),
    );
  }

  factory AlbumTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artist: serializer.fromJson<int>(json['artist']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'artist': serializer.toJson<int>(artist),
    };
  }

  AlbumTableData copyWith({int? id, String? name, int? artist}) =>
      AlbumTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        artist: artist ?? this.artist,
      );
  AlbumTableData copyWithCompanion(AlbumTableCompanion data) {
    return AlbumTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artist: data.artist.present ? data.artist.value : this.artist,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, artist);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.artist == this.artist);
}

class AlbumTableCompanion extends UpdateCompanion<AlbumTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> artist;
  const AlbumTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artist = const Value.absent(),
  });
  AlbumTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int artist,
  }) : name = Value(name),
       artist = Value(artist);
  static Insertable<AlbumTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? artist,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
    });
  }

  AlbumTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? artist,
  }) {
    return AlbumTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artist.present) {
      map['artist'] = Variable<int>(artist.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist')
          ..write(')'))
        .toString();
  }
}

class $TrackTableTable extends TrackTable
    with TableInfo<$TrackTableTable, TrackTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<int> album = GeneratedColumn<int>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES album_table (id)',
    ),
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<int> artist = GeneratedColumn<int>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artist_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, album, artist];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artist'],
      )!,
    );
  }

  @override
  $TrackTableTable createAlias(String alias) {
    return $TrackTableTable(attachedDatabase, alias);
  }
}

class TrackTableData extends DataClass implements Insertable<TrackTableData> {
  final int id;
  final String name;
  final int album;
  final int artist;
  const TrackTableData({
    required this.id,
    required this.name,
    required this.album,
    required this.artist,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['album'] = Variable<int>(album);
    map['artist'] = Variable<int>(artist);
    return map;
  }

  TrackTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTableCompanion(
      id: Value(id),
      name: Value(name),
      album: Value(album),
      artist: Value(artist),
    );
  }

  factory TrackTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      album: serializer.fromJson<int>(json['album']),
      artist: serializer.fromJson<int>(json['artist']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'album': serializer.toJson<int>(album),
      'artist': serializer.toJson<int>(artist),
    };
  }

  TrackTableData copyWith({int? id, String? name, int? album, int? artist}) =>
      TrackTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        album: album ?? this.album,
        artist: artist ?? this.artist,
      );
  TrackTableData copyWithCompanion(TrackTableCompanion data) {
    return TrackTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      album: data.album.present ? data.album.value : this.album,
      artist: data.artist.present ? data.artist.value : this.artist,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('album: $album, ')
          ..write('artist: $artist')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, album, artist);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.album == this.album &&
          other.artist == this.artist);
}

class TrackTableCompanion extends UpdateCompanion<TrackTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> album;
  final Value<int> artist;
  const TrackTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
  });
  TrackTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int album,
    required int artist,
  }) : name = Value(name),
       album = Value(album),
       artist = Value(artist);
  static Insertable<TrackTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? album,
    Expression<int>? artist,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
    });
  }

  TrackTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? album,
    Value<int>? artist,
  }) {
    return TrackTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      album: album ?? this.album,
      artist: artist ?? this.artist,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (album.present) {
      map['album'] = Variable<int>(album.value);
    }
    if (artist.present) {
      map['artist'] = Variable<int>(artist.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('album: $album, ')
          ..write('artist: $artist')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTableTable extends PlaylistTable
    with TableInfo<$PlaylistTableTable, PlaylistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PlaylistTableTable createAlias(String alias) {
    return $PlaylistTableTable(attachedDatabase, alias);
  }
}

class PlaylistTableData extends DataClass
    implements Insertable<PlaylistTableData> {
  final int id;
  final String name;
  const PlaylistTableData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(id: Value(id), name: Value(name));
  }

  factory PlaylistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  PlaylistTableData copyWith({int? id, String? name}) =>
      PlaylistTableData(id: id ?? this.id, name: name ?? this.name);
  PlaylistTableData copyWithCompanion(PlaylistTableCompanion data) {
    return PlaylistTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData &&
          other.id == this.id &&
          other.name == this.name);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<int> id;
  final Value<String> name;
  const PlaylistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<PlaylistTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  PlaylistTableCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return PlaylistTableCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTrackTableTable extends PlaylistTrackTable
    with TableInfo<$PlaylistTrackTableTable, PlaylistTrackTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistMeta = const VerificationMeta(
    'playlist',
  );
  @override
  late final GeneratedColumn<int> playlist = GeneratedColumn<int>(
    'playlist',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlist_table (id)',
    ),
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<int> track = GeneratedColumn<int>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlist, track];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTrackTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist')) {
      context.handle(
        _playlistMeta,
        playlist.isAcceptableOrUnknown(data['playlist']!, _playlistMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistMeta);
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTrackTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrackTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist'],
      )!,
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track'],
      )!,
    );
  }

  @override
  $PlaylistTrackTableTable createAlias(String alias) {
    return $PlaylistTrackTableTable(attachedDatabase, alias);
  }
}

class PlaylistTrackTableData extends DataClass
    implements Insertable<PlaylistTrackTableData> {
  final int id;
  final int playlist;
  final int track;
  const PlaylistTrackTableData({
    required this.id,
    required this.playlist,
    required this.track,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist'] = Variable<int>(playlist);
    map['track'] = Variable<int>(track);
    return map;
  }

  PlaylistTrackTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTrackTableCompanion(
      id: Value(id),
      playlist: Value(playlist),
      track: Value(track),
    );
  }

  factory PlaylistTrackTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrackTableData(
      id: serializer.fromJson<int>(json['id']),
      playlist: serializer.fromJson<int>(json['playlist']),
      track: serializer.fromJson<int>(json['track']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlist': serializer.toJson<int>(playlist),
      'track': serializer.toJson<int>(track),
    };
  }

  PlaylistTrackTableData copyWith({int? id, int? playlist, int? track}) =>
      PlaylistTrackTableData(
        id: id ?? this.id,
        playlist: playlist ?? this.playlist,
        track: track ?? this.track,
      );
  PlaylistTrackTableData copyWithCompanion(PlaylistTrackTableCompanion data) {
    return PlaylistTrackTableData(
      id: data.id.present ? data.id.value : this.id,
      playlist: data.playlist.present ? data.playlist.value : this.playlist,
      track: data.track.present ? data.track.value : this.track,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackTableData(')
          ..write('id: $id, ')
          ..write('playlist: $playlist, ')
          ..write('track: $track')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlist, track);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrackTableData &&
          other.id == this.id &&
          other.playlist == this.playlist &&
          other.track == this.track);
}

class PlaylistTrackTableCompanion
    extends UpdateCompanion<PlaylistTrackTableData> {
  final Value<int> id;
  final Value<int> playlist;
  final Value<int> track;
  const PlaylistTrackTableCompanion({
    this.id = const Value.absent(),
    this.playlist = const Value.absent(),
    this.track = const Value.absent(),
  });
  PlaylistTrackTableCompanion.insert({
    this.id = const Value.absent(),
    required int playlist,
    required int track,
  }) : playlist = Value(playlist),
       track = Value(track);
  static Insertable<PlaylistTrackTableData> custom({
    Expression<int>? id,
    Expression<int>? playlist,
    Expression<int>? track,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlist != null) 'playlist': playlist,
      if (track != null) 'track': track,
    });
  }

  PlaylistTrackTableCompanion copyWith({
    Value<int>? id,
    Value<int>? playlist,
    Value<int>? track,
  }) {
    return PlaylistTrackTableCompanion(
      id: id ?? this.id,
      playlist: playlist ?? this.playlist,
      track: track ?? this.track,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlist.present) {
      map['playlist'] = Variable<int>(playlist.value);
    }
    if (track.present) {
      map['track'] = Variable<int>(track.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackTableCompanion(')
          ..write('id: $id, ')
          ..write('playlist: $playlist, ')
          ..write('track: $track')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ArtistTableTable artistTable = $ArtistTableTable(this);
  late final $AlbumTableTable albumTable = $AlbumTableTable(this);
  late final $TrackTableTable trackTable = $TrackTableTable(this);
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  late final $PlaylistTrackTableTable playlistTrackTable =
      $PlaylistTrackTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    artistTable,
    albumTable,
    trackTable,
    playlistTable,
    playlistTrackTable,
  ];
}

typedef $$ArtistTableTableCreateCompanionBuilder =
    ArtistTableCompanion Function({Value<int> id, required String name});
typedef $$ArtistTableTableUpdateCompanionBuilder =
    ArtistTableCompanion Function({Value<int> id, Value<String> name});

final class $$ArtistTableTableReferences
    extends BaseReferences<_$Database, $ArtistTableTable, ArtistTableData> {
  $$ArtistTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlbumTableTable, List<AlbumTableData>>
  _albumTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.albumTable,
    aliasName: $_aliasNameGenerator(db.artistTable.id, db.albumTable.artist),
  );

  $$AlbumTableTableProcessedTableManager get albumTableRefs {
    final manager = $$AlbumTableTableTableManager(
      $_db,
      $_db.albumTable,
    ).filter((f) => f.artist.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_albumTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackTableTable, List<TrackTableData>>
  _trackTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.trackTable,
    aliasName: $_aliasNameGenerator(db.artistTable.id, db.trackTable.artist),
  );

  $$TrackTableTableProcessedTableManager get trackTableRefs {
    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.artist.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtistTableTableFilterComposer
    extends Composer<_$Database, $ArtistTableTable> {
  $$ArtistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> albumTableRefs(
    Expression<bool> Function($$AlbumTableTableFilterComposer f) f,
  ) {
    final $$AlbumTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumTable,
      getReferencedColumn: (t) => t.artist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableTableFilterComposer(
            $db: $db,
            $table: $db.albumTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackTableRefs(
    Expression<bool> Function($$TrackTableTableFilterComposer f) f,
  ) {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.artist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistTableTableOrderingComposer
    extends Composer<_$Database, $ArtistTableTable> {
  $$ArtistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistTableTableAnnotationComposer
    extends Composer<_$Database, $ArtistTableTable> {
  $$ArtistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> albumTableRefs<T extends Object>(
    Expression<T> Function($$AlbumTableTableAnnotationComposer a) f,
  ) {
    final $$AlbumTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumTable,
      getReferencedColumn: (t) => t.artist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableTableAnnotationComposer(
            $db: $db,
            $table: $db.albumTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trackTableRefs<T extends Object>(
    Expression<T> Function($$TrackTableTableAnnotationComposer a) f,
  ) {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.artist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ArtistTableTable,
          ArtistTableData,
          $$ArtistTableTableFilterComposer,
          $$ArtistTableTableOrderingComposer,
          $$ArtistTableTableAnnotationComposer,
          $$ArtistTableTableCreateCompanionBuilder,
          $$ArtistTableTableUpdateCompanionBuilder,
          (ArtistTableData, $$ArtistTableTableReferences),
          ArtistTableData,
          PrefetchHooks Function({bool albumTableRefs, bool trackTableRefs})
        > {
  $$ArtistTableTableTableManager(_$Database db, $ArtistTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => ArtistTableCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  ArtistTableCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArtistTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({albumTableRefs = false, trackTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (albumTableRefs) db.albumTable,
                    if (trackTableRefs) db.trackTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (albumTableRefs)
                        await $_getPrefetchedData<
                          ArtistTableData,
                          $ArtistTableTable,
                          AlbumTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ArtistTableTableReferences
                              ._albumTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtistTableTableReferences(
                                db,
                                table,
                                p0,
                              ).albumTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artist == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackTableRefs)
                        await $_getPrefetchedData<
                          ArtistTableData,
                          $ArtistTableTable,
                          TrackTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ArtistTableTableReferences
                              ._trackTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtistTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artist == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArtistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ArtistTableTable,
      ArtistTableData,
      $$ArtistTableTableFilterComposer,
      $$ArtistTableTableOrderingComposer,
      $$ArtistTableTableAnnotationComposer,
      $$ArtistTableTableCreateCompanionBuilder,
      $$ArtistTableTableUpdateCompanionBuilder,
      (ArtistTableData, $$ArtistTableTableReferences),
      ArtistTableData,
      PrefetchHooks Function({bool albumTableRefs, bool trackTableRefs})
    >;
typedef $$AlbumTableTableCreateCompanionBuilder =
    AlbumTableCompanion Function({
      Value<int> id,
      required String name,
      required int artist,
    });
typedef $$AlbumTableTableUpdateCompanionBuilder =
    AlbumTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> artist,
    });

final class $$AlbumTableTableReferences
    extends BaseReferences<_$Database, $AlbumTableTable, AlbumTableData> {
  $$AlbumTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArtistTableTable _artistTable(_$Database db) =>
      db.artistTable.createAlias(
        $_aliasNameGenerator(db.albumTable.artist, db.artistTable.id),
      );

  $$ArtistTableTableProcessedTableManager get artist {
    final $_column = $_itemColumn<int>('artist')!;

    final manager = $$ArtistTableTableTableManager(
      $_db,
      $_db.artistTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TrackTableTable, List<TrackTableData>>
  _trackTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.trackTable,
    aliasName: $_aliasNameGenerator(db.albumTable.id, db.trackTable.album),
  );

  $$TrackTableTableProcessedTableManager get trackTableRefs {
    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.album.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumTableTableFilterComposer
    extends Composer<_$Database, $AlbumTableTable> {
  $$AlbumTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$ArtistTableTableFilterComposer get artist {
    final $$ArtistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableFilterComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> trackTableRefs(
    Expression<bool> Function($$TrackTableTableFilterComposer f) f,
  ) {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.album,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumTableTableOrderingComposer
    extends Composer<_$Database, $AlbumTableTable> {
  $$AlbumTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArtistTableTableOrderingComposer get artist {
    final $$ArtistTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableOrderingComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumTableTableAnnotationComposer
    extends Composer<_$Database, $AlbumTableTable> {
  $$AlbumTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$ArtistTableTableAnnotationComposer get artist {
    final $$ArtistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> trackTableRefs<T extends Object>(
    Expression<T> Function($$TrackTableTableAnnotationComposer a) f,
  ) {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.album,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $AlbumTableTable,
          AlbumTableData,
          $$AlbumTableTableFilterComposer,
          $$AlbumTableTableOrderingComposer,
          $$AlbumTableTableAnnotationComposer,
          $$AlbumTableTableCreateCompanionBuilder,
          $$AlbumTableTableUpdateCompanionBuilder,
          (AlbumTableData, $$AlbumTableTableReferences),
          AlbumTableData,
          PrefetchHooks Function({bool artist, bool trackTableRefs})
        > {
  $$AlbumTableTableTableManager(_$Database db, $AlbumTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> artist = const Value.absent(),
              }) => AlbumTableCompanion(id: id, name: name, artist: artist),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int artist,
              }) => AlbumTableCompanion.insert(
                id: id,
                name: name,
                artist: artist,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlbumTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({artist = false, trackTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (trackTableRefs) db.trackTable],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (artist) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.artist,
                                referencedTable: $$AlbumTableTableReferences
                                    ._artistTable(db),
                                referencedColumn: $$AlbumTableTableReferences
                                    ._artistTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trackTableRefs)
                    await $_getPrefetchedData<
                      AlbumTableData,
                      $AlbumTableTable,
                      TrackTableData
                    >(
                      currentTable: table,
                      referencedTable: $$AlbumTableTableReferences
                          ._trackTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AlbumTableTableReferences(
                            db,
                            table,
                            p0,
                          ).trackTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.album == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlbumTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $AlbumTableTable,
      AlbumTableData,
      $$AlbumTableTableFilterComposer,
      $$AlbumTableTableOrderingComposer,
      $$AlbumTableTableAnnotationComposer,
      $$AlbumTableTableCreateCompanionBuilder,
      $$AlbumTableTableUpdateCompanionBuilder,
      (AlbumTableData, $$AlbumTableTableReferences),
      AlbumTableData,
      PrefetchHooks Function({bool artist, bool trackTableRefs})
    >;
typedef $$TrackTableTableCreateCompanionBuilder =
    TrackTableCompanion Function({
      Value<int> id,
      required String name,
      required int album,
      required int artist,
    });
typedef $$TrackTableTableUpdateCompanionBuilder =
    TrackTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> album,
      Value<int> artist,
    });

final class $$TrackTableTableReferences
    extends BaseReferences<_$Database, $TrackTableTable, TrackTableData> {
  $$TrackTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlbumTableTable _albumTable(_$Database db) => db.albumTable
      .createAlias($_aliasNameGenerator(db.trackTable.album, db.albumTable.id));

  $$AlbumTableTableProcessedTableManager get album {
    final $_column = $_itemColumn<int>('album')!;

    final manager = $$AlbumTableTableTableManager(
      $_db,
      $_db.albumTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ArtistTableTable _artistTable(_$Database db) =>
      db.artistTable.createAlias(
        $_aliasNameGenerator(db.trackTable.artist, db.artistTable.id),
      );

  $$ArtistTableTableProcessedTableManager get artist {
    final $_column = $_itemColumn<int>('artist')!;

    final manager = $$ArtistTableTableTableManager(
      $_db,
      $_db.artistTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PlaylistTrackTableTable,
    List<PlaylistTrackTableData>
  >
  _playlistTrackTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.playlistTrackTable,
    aliasName: $_aliasNameGenerator(
      db.trackTable.id,
      db.playlistTrackTable.track,
    ),
  );

  $$PlaylistTrackTableTableProcessedTableManager get playlistTrackTableRefs {
    final manager = $$PlaylistTrackTableTableTableManager(
      $_db,
      $_db.playlistTrackTable,
    ).filter((f) => f.track.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTrackTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackTableTableFilterComposer
    extends Composer<_$Database, $TrackTableTable> {
  $$TrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$AlbumTableTableFilterComposer get album {
    final $$AlbumTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.album,
      referencedTable: $db.albumTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableTableFilterComposer(
            $db: $db,
            $table: $db.albumTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistTableTableFilterComposer get artist {
    final $$ArtistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableFilterComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playlistTrackTableRefs(
    Expression<bool> Function($$PlaylistTrackTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTrackTable,
      getReferencedColumn: (t) => t.track,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTrackTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTrackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackTableTableOrderingComposer
    extends Composer<_$Database, $TrackTableTable> {
  $$TrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlbumTableTableOrderingComposer get album {
    final $$AlbumTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.album,
      referencedTable: $db.albumTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableTableOrderingComposer(
            $db: $db,
            $table: $db.albumTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistTableTableOrderingComposer get artist {
    final $$ArtistTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableOrderingComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackTableTableAnnotationComposer
    extends Composer<_$Database, $TrackTableTable> {
  $$TrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$AlbumTableTableAnnotationComposer get album {
    final $$AlbumTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.album,
      referencedTable: $db.albumTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableTableAnnotationComposer(
            $db: $db,
            $table: $db.albumTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistTableTableAnnotationComposer get artist {
    final $$ArtistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playlistTrackTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTrackTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTrackTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackTable,
          getReferencedColumn: (t) => t.track,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTrackTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TrackTableTable,
          TrackTableData,
          $$TrackTableTableFilterComposer,
          $$TrackTableTableOrderingComposer,
          $$TrackTableTableAnnotationComposer,
          $$TrackTableTableCreateCompanionBuilder,
          $$TrackTableTableUpdateCompanionBuilder,
          (TrackTableData, $$TrackTableTableReferences),
          TrackTableData,
          PrefetchHooks Function({
            bool album,
            bool artist,
            bool playlistTrackTableRefs,
          })
        > {
  $$TrackTableTableTableManager(_$Database db, $TrackTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> album = const Value.absent(),
                Value<int> artist = const Value.absent(),
              }) => TrackTableCompanion(
                id: id,
                name: name,
                album: album,
                artist: artist,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int album,
                required int artist,
              }) => TrackTableCompanion.insert(
                id: id,
                name: name,
                album: album,
                artist: artist,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                album = false,
                artist = false,
                playlistTrackTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistTrackTableRefs) db.playlistTrackTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (album) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.album,
                                    referencedTable: $$TrackTableTableReferences
                                        ._albumTable(db),
                                    referencedColumn:
                                        $$TrackTableTableReferences
                                            ._albumTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (artist) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.artist,
                                    referencedTable: $$TrackTableTableReferences
                                        ._artistTable(db),
                                    referencedColumn:
                                        $$TrackTableTableReferences
                                            ._artistTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistTrackTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          PlaylistTrackTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._playlistTrackTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTrackTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.track == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TrackTableTable,
      TrackTableData,
      $$TrackTableTableFilterComposer,
      $$TrackTableTableOrderingComposer,
      $$TrackTableTableAnnotationComposer,
      $$TrackTableTableCreateCompanionBuilder,
      $$TrackTableTableUpdateCompanionBuilder,
      (TrackTableData, $$TrackTableTableReferences),
      TrackTableData,
      PrefetchHooks Function({
        bool album,
        bool artist,
        bool playlistTrackTableRefs,
      })
    >;
typedef $$PlaylistTableTableCreateCompanionBuilder =
    PlaylistTableCompanion Function({Value<int> id, required String name});
typedef $$PlaylistTableTableUpdateCompanionBuilder =
    PlaylistTableCompanion Function({Value<int> id, Value<String> name});

final class $$PlaylistTableTableReferences
    extends BaseReferences<_$Database, $PlaylistTableTable, PlaylistTableData> {
  $$PlaylistTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistTrackTableTable,
    List<PlaylistTrackTableData>
  >
  _playlistTrackTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.playlistTrackTable,
    aliasName: $_aliasNameGenerator(
      db.playlistTable.id,
      db.playlistTrackTable.playlist,
    ),
  );

  $$PlaylistTrackTableTableProcessedTableManager get playlistTrackTableRefs {
    final manager = $$PlaylistTrackTableTableTableManager(
      $_db,
      $_db.playlistTrackTable,
    ).filter((f) => f.playlist.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTrackTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistTableTableFilterComposer
    extends Composer<_$Database, $PlaylistTableTable> {
  $$PlaylistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTrackTableRefs(
    Expression<bool> Function($$PlaylistTrackTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTrackTable,
      getReferencedColumn: (t) => t.playlist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTrackTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTrackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistTableTableOrderingComposer
    extends Composer<_$Database, $PlaylistTableTable> {
  $$PlaylistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistTableTableAnnotationComposer
    extends Composer<_$Database, $PlaylistTableTable> {
  $$PlaylistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> playlistTrackTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTrackTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTrackTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackTable,
          getReferencedColumn: (t) => t.playlist,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTrackTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PlaylistTableTable,
          PlaylistTableData,
          $$PlaylistTableTableFilterComposer,
          $$PlaylistTableTableOrderingComposer,
          $$PlaylistTableTableAnnotationComposer,
          $$PlaylistTableTableCreateCompanionBuilder,
          $$PlaylistTableTableUpdateCompanionBuilder,
          (PlaylistTableData, $$PlaylistTableTableReferences),
          PlaylistTableData,
          PrefetchHooks Function({bool playlistTrackTableRefs})
        > {
  $$PlaylistTableTableTableManager(_$Database db, $PlaylistTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => PlaylistTableCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  PlaylistTableCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTrackTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTrackTableRefs) db.playlistTrackTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTrackTableRefs)
                    await $_getPrefetchedData<
                      PlaylistTableData,
                      $PlaylistTableTable,
                      PlaylistTrackTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistTableTableReferences
                          ._playlistTrackTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTrackTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlist == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PlaylistTableTable,
      PlaylistTableData,
      $$PlaylistTableTableFilterComposer,
      $$PlaylistTableTableOrderingComposer,
      $$PlaylistTableTableAnnotationComposer,
      $$PlaylistTableTableCreateCompanionBuilder,
      $$PlaylistTableTableUpdateCompanionBuilder,
      (PlaylistTableData, $$PlaylistTableTableReferences),
      PlaylistTableData,
      PrefetchHooks Function({bool playlistTrackTableRefs})
    >;
typedef $$PlaylistTrackTableTableCreateCompanionBuilder =
    PlaylistTrackTableCompanion Function({
      Value<int> id,
      required int playlist,
      required int track,
    });
typedef $$PlaylistTrackTableTableUpdateCompanionBuilder =
    PlaylistTrackTableCompanion Function({
      Value<int> id,
      Value<int> playlist,
      Value<int> track,
    });

final class $$PlaylistTrackTableTableReferences
    extends
        BaseReferences<
          _$Database,
          $PlaylistTrackTableTable,
          PlaylistTrackTableData
        > {
  $$PlaylistTrackTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistTableTable _playlistTable(_$Database db) =>
      db.playlistTable.createAlias(
        $_aliasNameGenerator(
          db.playlistTrackTable.playlist,
          db.playlistTable.id,
        ),
      );

  $$PlaylistTableTableProcessedTableManager get playlist {
    final $_column = $_itemColumn<int>('playlist')!;

    final manager = $$PlaylistTableTableTableManager(
      $_db,
      $_db.playlistTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackTableTable _trackTable(_$Database db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(db.playlistTrackTable.track, db.trackTable.id),
      );

  $$TrackTableTableProcessedTableManager get track {
    final $_column = $_itemColumn<int>('track')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTrackTableTableFilterComposer
    extends Composer<_$Database, $PlaylistTrackTableTable> {
  $$PlaylistTrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistTableTableFilterComposer get playlist {
    final $$PlaylistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlist,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableFilterComposer get track {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.track,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackTableTableOrderingComposer
    extends Composer<_$Database, $PlaylistTrackTableTable> {
  $$PlaylistTrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistTableTableOrderingComposer get playlist {
    final $$PlaylistTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlist,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableOrderingComposer get track {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.track,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableOrderingComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackTableTableAnnotationComposer
    extends Composer<_$Database, $PlaylistTrackTableTable> {
  $$PlaylistTrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$PlaylistTableTableAnnotationComposer get playlist {
    final $$PlaylistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlist,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableAnnotationComposer get track {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.track,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PlaylistTrackTableTable,
          PlaylistTrackTableData,
          $$PlaylistTrackTableTableFilterComposer,
          $$PlaylistTrackTableTableOrderingComposer,
          $$PlaylistTrackTableTableAnnotationComposer,
          $$PlaylistTrackTableTableCreateCompanionBuilder,
          $$PlaylistTrackTableTableUpdateCompanionBuilder,
          (PlaylistTrackTableData, $$PlaylistTrackTableTableReferences),
          PlaylistTrackTableData,
          PrefetchHooks Function({bool playlist, bool track})
        > {
  $$PlaylistTrackTableTableTableManager(
    _$Database db,
    $PlaylistTrackTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTrackTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlist = const Value.absent(),
                Value<int> track = const Value.absent(),
              }) => PlaylistTrackTableCompanion(
                id: id,
                playlist: playlist,
                track: track,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlist,
                required int track,
              }) => PlaylistTrackTableCompanion.insert(
                id: id,
                playlist: playlist,
                track: track,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTrackTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlist = false, track = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlist) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlist,
                                referencedTable:
                                    $$PlaylistTrackTableTableReferences
                                        ._playlistTable(db),
                                referencedColumn:
                                    $$PlaylistTrackTableTableReferences
                                        ._playlistTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (track) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.track,
                                referencedTable:
                                    $$PlaylistTrackTableTableReferences
                                        ._trackTable(db),
                                referencedColumn:
                                    $$PlaylistTrackTableTableReferences
                                        ._trackTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PlaylistTrackTableTable,
      PlaylistTrackTableData,
      $$PlaylistTrackTableTableFilterComposer,
      $$PlaylistTrackTableTableOrderingComposer,
      $$PlaylistTrackTableTableAnnotationComposer,
      $$PlaylistTrackTableTableCreateCompanionBuilder,
      $$PlaylistTrackTableTableUpdateCompanionBuilder,
      (PlaylistTrackTableData, $$PlaylistTrackTableTableReferences),
      PlaylistTrackTableData,
      PrefetchHooks Function({bool playlist, bool track})
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ArtistTableTableTableManager get artistTable =>
      $$ArtistTableTableTableManager(_db, _db.artistTable);
  $$AlbumTableTableTableManager get albumTable =>
      $$AlbumTableTableTableManager(_db, _db.albumTable);
  $$TrackTableTableTableManager get trackTable =>
      $$TrackTableTableTableManager(_db, _db.trackTable);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
  $$PlaylistTrackTableTableTableManager get playlistTrackTable =>
      $$PlaylistTrackTableTableTableManager(_db, _db.playlistTrackTable);
}
