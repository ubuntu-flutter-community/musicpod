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

class $AlbumArtTableTable extends AlbumArtTable
    with TableInfo<$AlbumArtTableTable, AlbumArtTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumArtTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<int> album = GeneratedColumn<int>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES album_table (id)',
    ),
  );
  static const VerificationMeta _pictureDataMeta = const VerificationMeta(
    'pictureData',
  );
  @override
  late final GeneratedColumn<Uint8List> pictureData =
      GeneratedColumn<Uint8List>(
        'picture_data',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _pictureMimeTypeMeta = const VerificationMeta(
    'pictureMimeType',
  );
  @override
  late final GeneratedColumn<String> pictureMimeType = GeneratedColumn<String>(
    'picture_mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    album,
    pictureData,
    pictureMimeType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_art_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumArtTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('picture_data')) {
      context.handle(
        _pictureDataMeta,
        pictureData.isAcceptableOrUnknown(
          data['picture_data']!,
          _pictureDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pictureDataMeta);
    }
    if (data.containsKey('picture_mime_type')) {
      context.handle(
        _pictureMimeTypeMeta,
        pictureMimeType.isAcceptableOrUnknown(
          data['picture_mime_type']!,
          _pictureMimeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pictureMimeTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumArtTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumArtTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album'],
      )!,
      pictureData: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}picture_data'],
      )!,
      pictureMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}picture_mime_type'],
      )!,
    );
  }

  @override
  $AlbumArtTableTable createAlias(String alias) {
    return $AlbumArtTableTable(attachedDatabase, alias);
  }
}

class AlbumArtTableData extends DataClass
    implements Insertable<AlbumArtTableData> {
  final int id;
  final int album;
  final Uint8List pictureData;
  final String pictureMimeType;
  const AlbumArtTableData({
    required this.id,
    required this.album,
    required this.pictureData,
    required this.pictureMimeType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album'] = Variable<int>(album);
    map['picture_data'] = Variable<Uint8List>(pictureData);
    map['picture_mime_type'] = Variable<String>(pictureMimeType);
    return map;
  }

  AlbumArtTableCompanion toCompanion(bool nullToAbsent) {
    return AlbumArtTableCompanion(
      id: Value(id),
      album: Value(album),
      pictureData: Value(pictureData),
      pictureMimeType: Value(pictureMimeType),
    );
  }

  factory AlbumArtTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumArtTableData(
      id: serializer.fromJson<int>(json['id']),
      album: serializer.fromJson<int>(json['album']),
      pictureData: serializer.fromJson<Uint8List>(json['pictureData']),
      pictureMimeType: serializer.fromJson<String>(json['pictureMimeType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'album': serializer.toJson<int>(album),
      'pictureData': serializer.toJson<Uint8List>(pictureData),
      'pictureMimeType': serializer.toJson<String>(pictureMimeType),
    };
  }

  AlbumArtTableData copyWith({
    int? id,
    int? album,
    Uint8List? pictureData,
    String? pictureMimeType,
  }) => AlbumArtTableData(
    id: id ?? this.id,
    album: album ?? this.album,
    pictureData: pictureData ?? this.pictureData,
    pictureMimeType: pictureMimeType ?? this.pictureMimeType,
  );
  AlbumArtTableData copyWithCompanion(AlbumArtTableCompanion data) {
    return AlbumArtTableData(
      id: data.id.present ? data.id.value : this.id,
      album: data.album.present ? data.album.value : this.album,
      pictureData: data.pictureData.present
          ? data.pictureData.value
          : this.pictureData,
      pictureMimeType: data.pictureMimeType.present
          ? data.pictureMimeType.value
          : this.pictureMimeType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumArtTableData(')
          ..write('id: $id, ')
          ..write('album: $album, ')
          ..write('pictureData: $pictureData, ')
          ..write('pictureMimeType: $pictureMimeType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    album,
    $driftBlobEquality.hash(pictureData),
    pictureMimeType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumArtTableData &&
          other.id == this.id &&
          other.album == this.album &&
          $driftBlobEquality.equals(other.pictureData, this.pictureData) &&
          other.pictureMimeType == this.pictureMimeType);
}

class AlbumArtTableCompanion extends UpdateCompanion<AlbumArtTableData> {
  final Value<int> id;
  final Value<int> album;
  final Value<Uint8List> pictureData;
  final Value<String> pictureMimeType;
  const AlbumArtTableCompanion({
    this.id = const Value.absent(),
    this.album = const Value.absent(),
    this.pictureData = const Value.absent(),
    this.pictureMimeType = const Value.absent(),
  });
  AlbumArtTableCompanion.insert({
    this.id = const Value.absent(),
    required int album,
    required Uint8List pictureData,
    required String pictureMimeType,
  }) : album = Value(album),
       pictureData = Value(pictureData),
       pictureMimeType = Value(pictureMimeType);
  static Insertable<AlbumArtTableData> custom({
    Expression<int>? id,
    Expression<int>? album,
    Expression<Uint8List>? pictureData,
    Expression<String>? pictureMimeType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (album != null) 'album': album,
      if (pictureData != null) 'picture_data': pictureData,
      if (pictureMimeType != null) 'picture_mime_type': pictureMimeType,
    });
  }

  AlbumArtTableCompanion copyWith({
    Value<int>? id,
    Value<int>? album,
    Value<Uint8List>? pictureData,
    Value<String>? pictureMimeType,
  }) {
    return AlbumArtTableCompanion(
      id: id ?? this.id,
      album: album ?? this.album,
      pictureData: pictureData ?? this.pictureData,
      pictureMimeType: pictureMimeType ?? this.pictureMimeType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (album.present) {
      map['album'] = Variable<int>(album.value);
    }
    if (pictureData.present) {
      map['picture_data'] = Variable<Uint8List>(pictureData.value);
    }
    if (pictureMimeType.present) {
      map['picture_mime_type'] = Variable<String>(pictureMimeType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumArtTableCompanion(')
          ..write('id: $id, ')
          ..write('album: $album, ')
          ..write('pictureData: $pictureData, ')
          ..write('pictureMimeType: $pictureMimeType')
          ..write(')'))
        .toString();
  }
}

class $GenreTableTable extends GenreTable
    with TableInfo<$GenreTableTable, GenreTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenreTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'genre_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GenreTableData> instance, {
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
  GenreTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GenreTableData(
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
  $GenreTableTable createAlias(String alias) {
    return $GenreTableTable(attachedDatabase, alias);
  }
}

class GenreTableData extends DataClass implements Insertable<GenreTableData> {
  final int id;
  final String name;
  const GenreTableData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  GenreTableCompanion toCompanion(bool nullToAbsent) {
    return GenreTableCompanion(id: Value(id), name: Value(name));
  }

  factory GenreTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GenreTableData(
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

  GenreTableData copyWith({int? id, String? name}) =>
      GenreTableData(id: id ?? this.id, name: name ?? this.name);
  GenreTableData copyWithCompanion(GenreTableCompanion data) {
    return GenreTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GenreTableData(')
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
      (other is GenreTableData &&
          other.id == this.id &&
          other.name == this.name);
}

class GenreTableCompanion extends UpdateCompanion<GenreTableData> {
  final Value<int> id;
  final Value<String> name;
  const GenreTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  GenreTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<GenreTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  GenreTableCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return GenreTableCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return (StringBuffer('GenreTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES album_table (id)',
    ),
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<int> artist = GeneratedColumn<int>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artist_table (id)',
    ),
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<int> albumArtist = GeneratedColumn<int>(
    'album_artist',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artist_table (id)',
    ),
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discTotalMeta = const VerificationMeta(
    'discTotal',
  );
  @override
  late final GeneratedColumn<int> discTotal = GeneratedColumn<int>(
    'disc_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<double> durationMs = GeneratedColumn<double>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<int> genre = GeneratedColumn<int>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES genre_table (id)',
    ),
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lyricsMeta = const VerificationMeta('lyrics');
  @override
  late final GeneratedColumn<String> lyrics = GeneratedColumn<String>(
    'lyrics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    path,
    album,
    artist,
    albumArtist,
    discNumber,
    discTotal,
    durationMs,
    genre,
    trackNumber,
    year,
    lyrics,
  ];
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
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('disc_total')) {
      context.handle(
        _discTotalMeta,
        discTotal.isAcceptableOrUnknown(data['disc_total']!, _discTotalMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('lyrics')) {
      context.handle(
        _lyricsMeta,
        lyrics.isAcceptableOrUnknown(data['lyrics']!, _lyricsMeta),
      );
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
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artist'],
      ),
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_artist'],
      ),
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      ),
      discTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_total'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_ms'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}genre'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      lyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyrics'],
      ),
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
  final String path;
  final int? album;
  final int? artist;
  final int? albumArtist;
  final int? discNumber;
  final int? discTotal;
  final double? durationMs;
  final int? genre;
  final int? trackNumber;
  final int? year;
  final String? lyrics;
  const TrackTableData({
    required this.id,
    required this.name,
    required this.path,
    this.album,
    this.artist,
    this.albumArtist,
    this.discNumber,
    this.discTotal,
    this.durationMs,
    this.genre,
    this.trackNumber,
    this.year,
    this.lyrics,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<int>(album);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<int>(artist);
    }
    if (!nullToAbsent || albumArtist != null) {
      map['album_artist'] = Variable<int>(albumArtist);
    }
    if (!nullToAbsent || discNumber != null) {
      map['disc_number'] = Variable<int>(discNumber);
    }
    if (!nullToAbsent || discTotal != null) {
      map['disc_total'] = Variable<int>(discTotal);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<double>(durationMs);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<int>(genre);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || lyrics != null) {
      map['lyrics'] = Variable<String>(lyrics);
    }
    return map;
  }

  TrackTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTableCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      albumArtist: albumArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtist),
      discNumber: discNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(discNumber),
      discTotal: discTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(discTotal),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      lyrics: lyrics == null && nullToAbsent
          ? const Value.absent()
          : Value(lyrics),
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
      path: serializer.fromJson<String>(json['path']),
      album: serializer.fromJson<int?>(json['album']),
      artist: serializer.fromJson<int?>(json['artist']),
      albumArtist: serializer.fromJson<int?>(json['albumArtist']),
      discNumber: serializer.fromJson<int?>(json['discNumber']),
      discTotal: serializer.fromJson<int?>(json['discTotal']),
      durationMs: serializer.fromJson<double?>(json['durationMs']),
      genre: serializer.fromJson<int?>(json['genre']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      year: serializer.fromJson<int?>(json['year']),
      lyrics: serializer.fromJson<String?>(json['lyrics']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'album': serializer.toJson<int?>(album),
      'artist': serializer.toJson<int?>(artist),
      'albumArtist': serializer.toJson<int?>(albumArtist),
      'discNumber': serializer.toJson<int?>(discNumber),
      'discTotal': serializer.toJson<int?>(discTotal),
      'durationMs': serializer.toJson<double?>(durationMs),
      'genre': serializer.toJson<int?>(genre),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'year': serializer.toJson<int?>(year),
      'lyrics': serializer.toJson<String?>(lyrics),
    };
  }

  TrackTableData copyWith({
    int? id,
    String? name,
    String? path,
    Value<int?> album = const Value.absent(),
    Value<int?> artist = const Value.absent(),
    Value<int?> albumArtist = const Value.absent(),
    Value<int?> discNumber = const Value.absent(),
    Value<int?> discTotal = const Value.absent(),
    Value<double?> durationMs = const Value.absent(),
    Value<int?> genre = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> lyrics = const Value.absent(),
  }) => TrackTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    album: album.present ? album.value : this.album,
    artist: artist.present ? artist.value : this.artist,
    albumArtist: albumArtist.present ? albumArtist.value : this.albumArtist,
    discNumber: discNumber.present ? discNumber.value : this.discNumber,
    discTotal: discTotal.present ? discTotal.value : this.discTotal,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    genre: genre.present ? genre.value : this.genre,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    year: year.present ? year.value : this.year,
    lyrics: lyrics.present ? lyrics.value : this.lyrics,
  );
  TrackTableData copyWithCompanion(TrackTableCompanion data) {
    return TrackTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      album: data.album.present ? data.album.value : this.album,
      artist: data.artist.present ? data.artist.value : this.artist,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      discTotal: data.discTotal.present ? data.discTotal.value : this.discTotal,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      genre: data.genre.present ? data.genre.value : this.genre,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      year: data.year.present ? data.year.value : this.year,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('discNumber: $discNumber, ')
          ..write('discTotal: $discTotal, ')
          ..write('durationMs: $durationMs, ')
          ..write('genre: $genre, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('year: $year, ')
          ..write('lyrics: $lyrics')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    path,
    album,
    artist,
    albumArtist,
    discNumber,
    discTotal,
    durationMs,
    genre,
    trackNumber,
    year,
    lyrics,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.album == this.album &&
          other.artist == this.artist &&
          other.albumArtist == this.albumArtist &&
          other.discNumber == this.discNumber &&
          other.discTotal == this.discTotal &&
          other.durationMs == this.durationMs &&
          other.genre == this.genre &&
          other.trackNumber == this.trackNumber &&
          other.year == this.year &&
          other.lyrics == this.lyrics);
}

class TrackTableCompanion extends UpdateCompanion<TrackTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> path;
  final Value<int?> album;
  final Value<int?> artist;
  final Value<int?> albumArtist;
  final Value<int?> discNumber;
  final Value<int?> discTotal;
  final Value<double?> durationMs;
  final Value<int?> genre;
  final Value<int?> trackNumber;
  final Value<int?> year;
  final Value<String?> lyrics;
  const TrackTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.discTotal = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.genre = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.year = const Value.absent(),
    this.lyrics = const Value.absent(),
  });
  TrackTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String path,
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.discTotal = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.genre = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.year = const Value.absent(),
    this.lyrics = const Value.absent(),
  }) : name = Value(name),
       path = Value(path);
  static Insertable<TrackTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<int>? album,
    Expression<int>? artist,
    Expression<int>? albumArtist,
    Expression<int>? discNumber,
    Expression<int>? discTotal,
    Expression<double>? durationMs,
    Expression<int>? genre,
    Expression<int>? trackNumber,
    Expression<int>? year,
    Expression<String>? lyrics,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (discNumber != null) 'disc_number': discNumber,
      if (discTotal != null) 'disc_total': discTotal,
      if (durationMs != null) 'duration_ms': durationMs,
      if (genre != null) 'genre': genre,
      if (trackNumber != null) 'track_number': trackNumber,
      if (year != null) 'year': year,
      if (lyrics != null) 'lyrics': lyrics,
    });
  }

  TrackTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? path,
    Value<int?>? album,
    Value<int?>? artist,
    Value<int?>? albumArtist,
    Value<int?>? discNumber,
    Value<int?>? discTotal,
    Value<double?>? durationMs,
    Value<int?>? genre,
    Value<int?>? trackNumber,
    Value<int?>? year,
    Value<String?>? lyrics,
  }) {
    return TrackTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      albumArtist: albumArtist ?? this.albumArtist,
      discNumber: discNumber ?? this.discNumber,
      discTotal: discTotal ?? this.discTotal,
      durationMs: durationMs ?? this.durationMs,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      lyrics: lyrics ?? this.lyrics,
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
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (album.present) {
      map['album'] = Variable<int>(album.value);
    }
    if (artist.present) {
      map['artist'] = Variable<int>(artist.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<int>(albumArtist.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (discTotal.present) {
      map['disc_total'] = Variable<int>(discTotal.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<double>(durationMs.value);
    }
    if (genre.present) {
      map['genre'] = Variable<int>(genre.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(lyrics.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('discNumber: $discNumber, ')
          ..write('discTotal: $discTotal, ')
          ..write('durationMs: $durationMs, ')
          ..write('genre: $genre, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('year: $year, ')
          ..write('lyrics: $lyrics')
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
  static const VerificationMeta _fromExternalSourceMeta =
      const VerificationMeta('fromExternalSource');
  @override
  late final GeneratedColumn<bool> fromExternalSource = GeneratedColumn<bool>(
    'from_external_source',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("from_external_source" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, fromExternalSource];
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
    if (data.containsKey('from_external_source')) {
      context.handle(
        _fromExternalSourceMeta,
        fromExternalSource.isAcceptableOrUnknown(
          data['from_external_source']!,
          _fromExternalSourceMeta,
        ),
      );
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
      fromExternalSource: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}from_external_source'],
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
  final bool fromExternalSource;
  const PlaylistTableData({
    required this.id,
    required this.name,
    required this.fromExternalSource,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['from_external_source'] = Variable<bool>(fromExternalSource);
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(
      id: Value(id),
      name: Value(name),
      fromExternalSource: Value(fromExternalSource),
    );
  }

  factory PlaylistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fromExternalSource: serializer.fromJson<bool>(json['fromExternalSource']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fromExternalSource': serializer.toJson<bool>(fromExternalSource),
    };
  }

  PlaylistTableData copyWith({
    int? id,
    String? name,
    bool? fromExternalSource,
  }) => PlaylistTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    fromExternalSource: fromExternalSource ?? this.fromExternalSource,
  );
  PlaylistTableData copyWithCompanion(PlaylistTableCompanion data) {
    return PlaylistTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fromExternalSource: data.fromExternalSource.present
          ? data.fromExternalSource.value
          : this.fromExternalSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fromExternalSource: $fromExternalSource')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, fromExternalSource);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.fromExternalSource == this.fromExternalSource);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> fromExternalSource;
  const PlaylistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fromExternalSource = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.fromExternalSource = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PlaylistTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? fromExternalSource,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fromExternalSource != null)
        'from_external_source': fromExternalSource,
    });
  }

  PlaylistTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? fromExternalSource,
  }) {
    return PlaylistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fromExternalSource: fromExternalSource ?? this.fromExternalSource,
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
    if (fromExternalSource.present) {
      map['from_external_source'] = Variable<bool>(fromExternalSource.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fromExternalSource: $fromExternalSource')
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

class $LikedTrackTableTable extends LikedTrackTable
    with TableInfo<$LikedTrackTableTable, LikedTrackTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LikedTrackTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, trackId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liked_track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LikedTrackTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LikedTrackTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LikedTrackTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
    );
  }

  @override
  $LikedTrackTableTable createAlias(String alias) {
    return $LikedTrackTableTable(attachedDatabase, alias);
  }
}

class LikedTrackTableData extends DataClass
    implements Insertable<LikedTrackTableData> {
  final int id;
  final int trackId;
  const LikedTrackTableData({required this.id, required this.trackId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<int>(trackId);
    return map;
  }

  LikedTrackTableCompanion toCompanion(bool nullToAbsent) {
    return LikedTrackTableCompanion(id: Value(id), trackId: Value(trackId));
  }

  factory LikedTrackTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LikedTrackTableData(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<int>(json['trackId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<int>(trackId),
    };
  }

  LikedTrackTableData copyWith({int? id, int? trackId}) =>
      LikedTrackTableData(id: id ?? this.id, trackId: trackId ?? this.trackId);
  LikedTrackTableData copyWithCompanion(LikedTrackTableCompanion data) {
    return LikedTrackTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LikedTrackTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LikedTrackTableData &&
          other.id == this.id &&
          other.trackId == this.trackId);
}

class LikedTrackTableCompanion extends UpdateCompanion<LikedTrackTableData> {
  final Value<int> id;
  final Value<int> trackId;
  const LikedTrackTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
  });
  LikedTrackTableCompanion.insert({
    this.id = const Value.absent(),
    required int trackId,
  }) : trackId = Value(trackId);
  static Insertable<LikedTrackTableData> custom({
    Expression<int>? id,
    Expression<int>? trackId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
    });
  }

  LikedTrackTableCompanion copyWith({Value<int>? id, Value<int>? trackId}) {
    return LikedTrackTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LikedTrackTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId')
          ..write(')'))
        .toString();
  }
}

class $PinnedAlbumTableTable extends PinnedAlbumTable
    with TableInfo<$PinnedAlbumTableTable, PinnedAlbumTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinnedAlbumTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<int> albumId = GeneratedColumn<int>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES album_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, albumId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_album_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinnedAlbumTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PinnedAlbumTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedAlbumTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_id'],
      )!,
    );
  }

  @override
  $PinnedAlbumTableTable createAlias(String alias) {
    return $PinnedAlbumTableTable(attachedDatabase, alias);
  }
}

class PinnedAlbumTableData extends DataClass
    implements Insertable<PinnedAlbumTableData> {
  final int id;
  final int albumId;
  const PinnedAlbumTableData({required this.id, required this.albumId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album_id'] = Variable<int>(albumId);
    return map;
  }

  PinnedAlbumTableCompanion toCompanion(bool nullToAbsent) {
    return PinnedAlbumTableCompanion(id: Value(id), albumId: Value(albumId));
  }

  factory PinnedAlbumTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedAlbumTableData(
      id: serializer.fromJson<int>(json['id']),
      albumId: serializer.fromJson<int>(json['albumId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'albumId': serializer.toJson<int>(albumId),
    };
  }

  PinnedAlbumTableData copyWith({int? id, int? albumId}) =>
      PinnedAlbumTableData(id: id ?? this.id, albumId: albumId ?? this.albumId);
  PinnedAlbumTableData copyWithCompanion(PinnedAlbumTableCompanion data) {
    return PinnedAlbumTableData(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedAlbumTableData(')
          ..write('id: $id, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, albumId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedAlbumTableData &&
          other.id == this.id &&
          other.albumId == this.albumId);
}

class PinnedAlbumTableCompanion extends UpdateCompanion<PinnedAlbumTableData> {
  final Value<int> id;
  final Value<int> albumId;
  const PinnedAlbumTableCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
  });
  PinnedAlbumTableCompanion.insert({
    this.id = const Value.absent(),
    required int albumId,
  }) : albumId = Value(albumId);
  static Insertable<PinnedAlbumTableData> custom({
    Expression<int>? id,
    Expression<int>? albumId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
    });
  }

  PinnedAlbumTableCompanion copyWith({Value<int>? id, Value<int>? albumId}) {
    return PinnedAlbumTableCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedAlbumTableCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }
}

class $StarredStationTableTable extends StarredStationTable
    with TableInfo<$StarredStationTableTable, StarredStationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StarredStationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'starred_station_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StarredStationTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  StarredStationTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StarredStationTableData(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
    );
  }

  @override
  $StarredStationTableTable createAlias(String alias) {
    return $StarredStationTableTable(attachedDatabase, alias);
  }
}

class StarredStationTableData extends DataClass
    implements Insertable<StarredStationTableData> {
  final String uuid;
  const StarredStationTableData({required this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    return map;
  }

  StarredStationTableCompanion toCompanion(bool nullToAbsent) {
    return StarredStationTableCompanion(uuid: Value(uuid));
  }

  factory StarredStationTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StarredStationTableData(
      uuid: serializer.fromJson<String>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'uuid': serializer.toJson<String>(uuid)};
  }

  StarredStationTableData copyWith({String? uuid}) =>
      StarredStationTableData(uuid: uuid ?? this.uuid);
  StarredStationTableData copyWithCompanion(StarredStationTableCompanion data) {
    return StarredStationTableData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StarredStationTableData(')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => uuid.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StarredStationTableData && other.uuid == this.uuid);
}

class StarredStationTableCompanion
    extends UpdateCompanion<StarredStationTableData> {
  final Value<String> uuid;
  final Value<int> rowid;
  const StarredStationTableCompanion({
    this.uuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StarredStationTableCompanion.insert({
    required String uuid,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<StarredStationTableData> custom({
    Expression<String>? uuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StarredStationTableCompanion copyWith({
    Value<String>? uuid,
    Value<int>? rowid,
  }) {
    return StarredStationTableCompanion(
      uuid: uuid ?? this.uuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StarredStationTableCompanion(')
          ..write('uuid: $uuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteRadioTagTableTable extends FavoriteRadioTagTable
    with TableInfo<$FavoriteRadioTagTableTable, FavoriteRadioTagTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteRadioTagTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'favorite_radio_tag_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRadioTagTableData> instance, {
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
  FavoriteRadioTagTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRadioTagTableData(
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
  $FavoriteRadioTagTableTable createAlias(String alias) {
    return $FavoriteRadioTagTableTable(attachedDatabase, alias);
  }
}

class FavoriteRadioTagTableData extends DataClass
    implements Insertable<FavoriteRadioTagTableData> {
  final int id;
  final String name;
  const FavoriteRadioTagTableData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  FavoriteRadioTagTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteRadioTagTableCompanion(id: Value(id), name: Value(name));
  }

  factory FavoriteRadioTagTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRadioTagTableData(
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

  FavoriteRadioTagTableData copyWith({int? id, String? name}) =>
      FavoriteRadioTagTableData(id: id ?? this.id, name: name ?? this.name);
  FavoriteRadioTagTableData copyWithCompanion(
    FavoriteRadioTagTableCompanion data,
  ) {
    return FavoriteRadioTagTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRadioTagTableData(')
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
      (other is FavoriteRadioTagTableData &&
          other.id == this.id &&
          other.name == this.name);
}

class FavoriteRadioTagTableCompanion
    extends UpdateCompanion<FavoriteRadioTagTableData> {
  final Value<int> id;
  final Value<String> name;
  const FavoriteRadioTagTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  FavoriteRadioTagTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<FavoriteRadioTagTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  FavoriteRadioTagTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
  }) {
    return FavoriteRadioTagTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRadioTagTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $FavoriteCountryTableTable extends FavoriteCountryTable
    with TableInfo<$FavoriteCountryTableTable, FavoriteCountryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteCountryTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_country_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteCountryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteCountryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteCountryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
    );
  }

  @override
  $FavoriteCountryTableTable createAlias(String alias) {
    return $FavoriteCountryTableTable(attachedDatabase, alias);
  }
}

class FavoriteCountryTableData extends DataClass
    implements Insertable<FavoriteCountryTableData> {
  final int id;
  final String code;
  const FavoriteCountryTableData({required this.id, required this.code});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    return map;
  }

  FavoriteCountryTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteCountryTableCompanion(id: Value(id), code: Value(code));
  }

  factory FavoriteCountryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteCountryTableData(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
    };
  }

  FavoriteCountryTableData copyWith({int? id, String? code}) =>
      FavoriteCountryTableData(id: id ?? this.id, code: code ?? this.code);
  FavoriteCountryTableData copyWithCompanion(
    FavoriteCountryTableCompanion data,
  ) {
    return FavoriteCountryTableData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteCountryTableData(')
          ..write('id: $id, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteCountryTableData &&
          other.id == this.id &&
          other.code == this.code);
}

class FavoriteCountryTableCompanion
    extends UpdateCompanion<FavoriteCountryTableData> {
  final Value<int> id;
  final Value<String> code;
  const FavoriteCountryTableCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
  });
  FavoriteCountryTableCompanion.insert({
    this.id = const Value.absent(),
    required String code,
  }) : code = Value(code);
  static Insertable<FavoriteCountryTableData> custom({
    Expression<int>? id,
    Expression<String>? code,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
    });
  }

  FavoriteCountryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
  }) {
    return FavoriteCountryTableCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteCountryTableCompanion(')
          ..write('id: $id, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }
}

class $FavoriteLanguageTableTable extends FavoriteLanguageTable
    with TableInfo<$FavoriteLanguageTableTable, FavoriteLanguageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteLanguageTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isoCodeMeta = const VerificationMeta(
    'isoCode',
  );
  @override
  late final GeneratedColumn<String> isoCode = GeneratedColumn<String>(
    'iso_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, isoCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_language_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteLanguageTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('iso_code')) {
      context.handle(
        _isoCodeMeta,
        isoCode.isAcceptableOrUnknown(data['iso_code']!, _isoCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_isoCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteLanguageTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteLanguageTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isoCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iso_code'],
      )!,
    );
  }

  @override
  $FavoriteLanguageTableTable createAlias(String alias) {
    return $FavoriteLanguageTableTable(attachedDatabase, alias);
  }
}

class FavoriteLanguageTableData extends DataClass
    implements Insertable<FavoriteLanguageTableData> {
  final int id;
  final String isoCode;
  const FavoriteLanguageTableData({required this.id, required this.isoCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['iso_code'] = Variable<String>(isoCode);
    return map;
  }

  FavoriteLanguageTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteLanguageTableCompanion(
      id: Value(id),
      isoCode: Value(isoCode),
    );
  }

  factory FavoriteLanguageTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteLanguageTableData(
      id: serializer.fromJson<int>(json['id']),
      isoCode: serializer.fromJson<String>(json['isoCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isoCode': serializer.toJson<String>(isoCode),
    };
  }

  FavoriteLanguageTableData copyWith({int? id, String? isoCode}) =>
      FavoriteLanguageTableData(
        id: id ?? this.id,
        isoCode: isoCode ?? this.isoCode,
      );
  FavoriteLanguageTableData copyWithCompanion(
    FavoriteLanguageTableCompanion data,
  ) {
    return FavoriteLanguageTableData(
      id: data.id.present ? data.id.value : this.id,
      isoCode: data.isoCode.present ? data.isoCode.value : this.isoCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteLanguageTableData(')
          ..write('id: $id, ')
          ..write('isoCode: $isoCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, isoCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteLanguageTableData &&
          other.id == this.id &&
          other.isoCode == this.isoCode);
}

class FavoriteLanguageTableCompanion
    extends UpdateCompanion<FavoriteLanguageTableData> {
  final Value<int> id;
  final Value<String> isoCode;
  const FavoriteLanguageTableCompanion({
    this.id = const Value.absent(),
    this.isoCode = const Value.absent(),
  });
  FavoriteLanguageTableCompanion.insert({
    this.id = const Value.absent(),
    required String isoCode,
  }) : isoCode = Value(isoCode);
  static Insertable<FavoriteLanguageTableData> custom({
    Expression<int>? id,
    Expression<String>? isoCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isoCode != null) 'iso_code': isoCode,
    });
  }

  FavoriteLanguageTableCompanion copyWith({
    Value<int>? id,
    Value<String>? isoCode,
  }) {
    return FavoriteLanguageTableCompanion(
      id: id ?? this.id,
      isoCode: isoCode ?? this.isoCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isoCode.present) {
      map['iso_code'] = Variable<String>(isoCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteLanguageTableCompanion(')
          ..write('id: $id, ')
          ..write('isoCode: $isoCode')
          ..write(')'))
        .toString();
  }
}

class $AppSettingTableTable extends AppSettingTable
    with TableInfo<$AppSettingTableTable, AppSettingTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_setting_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingTableTable createAlias(String alias) {
    return $AppSettingTableTable(attachedDatabase, alias);
  }
}

class AppSettingTableData extends DataClass
    implements Insertable<AppSettingTableData> {
  final String key;
  final String value;
  const AppSettingTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingTableCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingTableData copyWith({String? key, String? value}) =>
      AppSettingTableData(key: key ?? this.key, value: value ?? this.value);
  AppSettingTableData copyWithCompanion(AppSettingTableCompanion data) {
    return AppSettingTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingTableCompanion extends UpdateCompanion<AppSettingTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PodcastTableTable extends PodcastTable
    with TableInfo<$PodcastTableTable, PodcastTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ascendingMeta = const VerificationMeta(
    'ascending',
  );
  @override
  late final GeneratedColumn<bool> ascending = GeneratedColumn<bool>(
    'ascending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ascending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    feedUrl,
    name,
    artist,
    description,
    imageUrl,
    lastUpdated,
    ascending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('ascending')) {
      context.handle(
        _ascendingMeta,
        ascending.isAcceptableOrUnknown(data['ascending']!, _ascendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedUrl};
  @override
  PodcastTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastTableData(
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      ascending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ascending'],
      )!,
    );
  }

  @override
  $PodcastTableTable createAlias(String alias) {
    return $PodcastTableTable(attachedDatabase, alias);
  }
}

class PodcastTableData extends DataClass
    implements Insertable<PodcastTableData> {
  final String feedUrl;
  final String name;
  final String artist;
  final String description;
  final String? imageUrl;
  final DateTime lastUpdated;
  final bool ascending;
  const PodcastTableData({
    required this.feedUrl,
    required this.name,
    required this.artist,
    required this.description,
    this.imageUrl,
    required this.lastUpdated,
    required this.ascending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_url'] = Variable<String>(feedUrl);
    map['name'] = Variable<String>(name);
    map['artist'] = Variable<String>(artist);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['ascending'] = Variable<bool>(ascending);
    return map;
  }

  PodcastTableCompanion toCompanion(bool nullToAbsent) {
    return PodcastTableCompanion(
      feedUrl: Value(feedUrl),
      name: Value(name),
      artist: Value(artist),
      description: Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      lastUpdated: Value(lastUpdated),
      ascending: Value(ascending),
    );
  }

  factory PodcastTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastTableData(
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      name: serializer.fromJson<String>(json['name']),
      artist: serializer.fromJson<String>(json['artist']),
      description: serializer.fromJson<String>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      ascending: serializer.fromJson<bool>(json['ascending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedUrl': serializer.toJson<String>(feedUrl),
      'name': serializer.toJson<String>(name),
      'artist': serializer.toJson<String>(artist),
      'description': serializer.toJson<String>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'ascending': serializer.toJson<bool>(ascending),
    };
  }

  PodcastTableData copyWith({
    String? feedUrl,
    String? name,
    String? artist,
    String? description,
    Value<String?> imageUrl = const Value.absent(),
    DateTime? lastUpdated,
    bool? ascending,
  }) => PodcastTableData(
    feedUrl: feedUrl ?? this.feedUrl,
    name: name ?? this.name,
    artist: artist ?? this.artist,
    description: description ?? this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    ascending: ascending ?? this.ascending,
  );
  PodcastTableData copyWithCompanion(PodcastTableCompanion data) {
    return PodcastTableData(
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      name: data.name.present ? data.name.value : this.name,
      artist: data.artist.present ? data.artist.value : this.artist,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      ascending: data.ascending.present ? data.ascending.value : this.ascending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastTableData(')
          ..write('feedUrl: $feedUrl, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('ascending: $ascending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    feedUrl,
    name,
    artist,
    description,
    imageUrl,
    lastUpdated,
    ascending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastTableData &&
          other.feedUrl == this.feedUrl &&
          other.name == this.name &&
          other.artist == this.artist &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.lastUpdated == this.lastUpdated &&
          other.ascending == this.ascending);
}

class PodcastTableCompanion extends UpdateCompanion<PodcastTableData> {
  final Value<String> feedUrl;
  final Value<String> name;
  final Value<String> artist;
  final Value<String> description;
  final Value<String?> imageUrl;
  final Value<DateTime> lastUpdated;
  final Value<bool> ascending;
  final Value<int> rowid;
  const PodcastTableCompanion({
    this.feedUrl = const Value.absent(),
    this.name = const Value.absent(),
    this.artist = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.ascending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PodcastTableCompanion.insert({
    required String feedUrl,
    required String name,
    required String artist,
    required String description,
    this.imageUrl = const Value.absent(),
    required DateTime lastUpdated,
    this.ascending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedUrl = Value(feedUrl),
       name = Value(name),
       artist = Value(artist),
       description = Value(description),
       lastUpdated = Value(lastUpdated);
  static Insertable<PodcastTableData> custom({
    Expression<String>? feedUrl,
    Expression<String>? name,
    Expression<String>? artist,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? ascending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedUrl != null) 'feed_url': feedUrl,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (ascending != null) 'ascending': ascending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PodcastTableCompanion copyWith({
    Value<String>? feedUrl,
    Value<String>? name,
    Value<String>? artist,
    Value<String>? description,
    Value<String?>? imageUrl,
    Value<DateTime>? lastUpdated,
    Value<bool>? ascending,
    Value<int>? rowid,
  }) {
    return PodcastTableCompanion(
      feedUrl: feedUrl ?? this.feedUrl,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      ascending: ascending ?? this.ascending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (ascending.present) {
      map['ascending'] = Variable<bool>(ascending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastTableCompanion(')
          ..write('feedUrl: $feedUrl, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('ascending: $ascending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PodcastUpdateTableTable extends PodcastUpdateTable
    with TableInfo<$PodcastUpdateTableTable, PodcastUpdateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastUpdateTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _podcastFeedUrlMeta = const VerificationMeta(
    'podcastFeedUrl',
  );
  @override
  late final GeneratedColumn<String> podcastFeedUrl = GeneratedColumn<String>(
    'podcast_feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_table (feed_url)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, podcastFeedUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_update_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastUpdateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('podcast_feed_url')) {
      context.handle(
        _podcastFeedUrlMeta,
        podcastFeedUrl.isAcceptableOrUnknown(
          data['podcast_feed_url']!,
          _podcastFeedUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastFeedUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PodcastUpdateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastUpdateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      podcastFeedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_feed_url'],
      )!,
    );
  }

  @override
  $PodcastUpdateTableTable createAlias(String alias) {
    return $PodcastUpdateTableTable(attachedDatabase, alias);
  }
}

class PodcastUpdateTableData extends DataClass
    implements Insertable<PodcastUpdateTableData> {
  final int id;
  final String podcastFeedUrl;
  const PodcastUpdateTableData({
    required this.id,
    required this.podcastFeedUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['podcast_feed_url'] = Variable<String>(podcastFeedUrl);
    return map;
  }

  PodcastUpdateTableCompanion toCompanion(bool nullToAbsent) {
    return PodcastUpdateTableCompanion(
      id: Value(id),
      podcastFeedUrl: Value(podcastFeedUrl),
    );
  }

  factory PodcastUpdateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastUpdateTableData(
      id: serializer.fromJson<int>(json['id']),
      podcastFeedUrl: serializer.fromJson<String>(json['podcastFeedUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'podcastFeedUrl': serializer.toJson<String>(podcastFeedUrl),
    };
  }

  PodcastUpdateTableData copyWith({int? id, String? podcastFeedUrl}) =>
      PodcastUpdateTableData(
        id: id ?? this.id,
        podcastFeedUrl: podcastFeedUrl ?? this.podcastFeedUrl,
      );
  PodcastUpdateTableData copyWithCompanion(PodcastUpdateTableCompanion data) {
    return PodcastUpdateTableData(
      id: data.id.present ? data.id.value : this.id,
      podcastFeedUrl: data.podcastFeedUrl.present
          ? data.podcastFeedUrl.value
          : this.podcastFeedUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastUpdateTableData(')
          ..write('id: $id, ')
          ..write('podcastFeedUrl: $podcastFeedUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, podcastFeedUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastUpdateTableData &&
          other.id == this.id &&
          other.podcastFeedUrl == this.podcastFeedUrl);
}

class PodcastUpdateTableCompanion
    extends UpdateCompanion<PodcastUpdateTableData> {
  final Value<int> id;
  final Value<String> podcastFeedUrl;
  const PodcastUpdateTableCompanion({
    this.id = const Value.absent(),
    this.podcastFeedUrl = const Value.absent(),
  });
  PodcastUpdateTableCompanion.insert({
    this.id = const Value.absent(),
    required String podcastFeedUrl,
  }) : podcastFeedUrl = Value(podcastFeedUrl);
  static Insertable<PodcastUpdateTableData> custom({
    Expression<int>? id,
    Expression<String>? podcastFeedUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastFeedUrl != null) 'podcast_feed_url': podcastFeedUrl,
    });
  }

  PodcastUpdateTableCompanion copyWith({
    Value<int>? id,
    Value<String>? podcastFeedUrl,
  }) {
    return PodcastUpdateTableCompanion(
      id: id ?? this.id,
      podcastFeedUrl: podcastFeedUrl ?? this.podcastFeedUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (podcastFeedUrl.present) {
      map['podcast_feed_url'] = Variable<String>(podcastFeedUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastUpdateTableCompanion(')
          ..write('id: $id, ')
          ..write('podcastFeedUrl: $podcastFeedUrl')
          ..write(')'))
        .toString();
  }
}

class $PodcastEpisodeTableTable extends PodcastEpisodeTable
    with TableInfo<$PodcastEpisodeTableTable, PodcastEpisodeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastEpisodeTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _podcastFeedUrlMeta = const VerificationMeta(
    'podcastFeedUrl',
  );
  @override
  late final GeneratedColumn<String> podcastFeedUrl = GeneratedColumn<String>(
    'podcast_feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_table (feed_url)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeDescriptionMeta =
      const VerificationMeta('episodeDescription');
  @override
  late final GeneratedColumn<String> episodeDescription =
      GeneratedColumn<String>(
        'episode_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _podcastDescriptionMeta =
      const VerificationMeta('podcastDescription');
  @override
  late final GeneratedColumn<String> podcastDescription =
      GeneratedColumn<String>(
        'podcast_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES podcast_table (description)',
        ),
      );
  static const VerificationMeta _contentUrlMeta = const VerificationMeta(
    'contentUrl',
  );
  @override
  late final GeneratedColumn<String> contentUrl = GeneratedColumn<String>(
    'content_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicationDateMeta = const VerificationMeta(
    'publicationDate',
  );
  @override
  late final GeneratedColumn<DateTime> publicationDate =
      GeneratedColumn<DateTime>(
        'publication_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPlayedPercentMeta = const VerificationMeta(
    'isPlayedPercent',
  );
  @override
  late final GeneratedColumn<int> isPlayedPercent = GeneratedColumn<int>(
    'is_played_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    podcastFeedUrl,
    title,
    episodeDescription,
    podcastDescription,
    contentUrl,
    publicationDate,
    durationMs,
    positionMs,
    imageUrl,
    isPlayedPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_episode_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastEpisodeTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('podcast_feed_url')) {
      context.handle(
        _podcastFeedUrlMeta,
        podcastFeedUrl.isAcceptableOrUnknown(
          data['podcast_feed_url']!,
          _podcastFeedUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastFeedUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('episode_description')) {
      context.handle(
        _episodeDescriptionMeta,
        episodeDescription.isAcceptableOrUnknown(
          data['episode_description']!,
          _episodeDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeDescriptionMeta);
    }
    if (data.containsKey('podcast_description')) {
      context.handle(
        _podcastDescriptionMeta,
        podcastDescription.isAcceptableOrUnknown(
          data['podcast_description']!,
          _podcastDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastDescriptionMeta);
    }
    if (data.containsKey('content_url')) {
      context.handle(
        _contentUrlMeta,
        contentUrl.isAcceptableOrUnknown(data['content_url']!, _contentUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_contentUrlMeta);
    }
    if (data.containsKey('publication_date')) {
      context.handle(
        _publicationDateMeta,
        publicationDate.isAcceptableOrUnknown(
          data['publication_date']!,
          _publicationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publicationDateMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('is_played_percent')) {
      context.handle(
        _isPlayedPercentMeta,
        isPlayedPercent.isAcceptableOrUnknown(
          data['is_played_percent']!,
          _isPlayedPercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PodcastEpisodeTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastEpisodeTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      podcastFeedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_feed_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      episodeDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_description'],
      )!,
      podcastDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_description'],
      )!,
      contentUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_url'],
      )!,
      publicationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}publication_date'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      isPlayedPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_played_percent'],
      )!,
    );
  }

  @override
  $PodcastEpisodeTableTable createAlias(String alias) {
    return $PodcastEpisodeTableTable(attachedDatabase, alias);
  }
}

class PodcastEpisodeTableData extends DataClass
    implements Insertable<PodcastEpisodeTableData> {
  final int id;
  final String podcastFeedUrl;
  final String title;
  final String episodeDescription;
  final String podcastDescription;
  final String contentUrl;
  final DateTime publicationDate;
  final int? durationMs;
  final int positionMs;
  final String? imageUrl;
  final int isPlayedPercent;
  const PodcastEpisodeTableData({
    required this.id,
    required this.podcastFeedUrl,
    required this.title,
    required this.episodeDescription,
    required this.podcastDescription,
    required this.contentUrl,
    required this.publicationDate,
    this.durationMs,
    required this.positionMs,
    this.imageUrl,
    required this.isPlayedPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['podcast_feed_url'] = Variable<String>(podcastFeedUrl);
    map['title'] = Variable<String>(title);
    map['episode_description'] = Variable<String>(episodeDescription);
    map['podcast_description'] = Variable<String>(podcastDescription);
    map['content_url'] = Variable<String>(contentUrl);
    map['publication_date'] = Variable<DateTime>(publicationDate);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['position_ms'] = Variable<int>(positionMs);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_played_percent'] = Variable<int>(isPlayedPercent);
    return map;
  }

  PodcastEpisodeTableCompanion toCompanion(bool nullToAbsent) {
    return PodcastEpisodeTableCompanion(
      id: Value(id),
      podcastFeedUrl: Value(podcastFeedUrl),
      title: Value(title),
      episodeDescription: Value(episodeDescription),
      podcastDescription: Value(podcastDescription),
      contentUrl: Value(contentUrl),
      publicationDate: Value(publicationDate),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      positionMs: Value(positionMs),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isPlayedPercent: Value(isPlayedPercent),
    );
  }

  factory PodcastEpisodeTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastEpisodeTableData(
      id: serializer.fromJson<int>(json['id']),
      podcastFeedUrl: serializer.fromJson<String>(json['podcastFeedUrl']),
      title: serializer.fromJson<String>(json['title']),
      episodeDescription: serializer.fromJson<String>(
        json['episodeDescription'],
      ),
      podcastDescription: serializer.fromJson<String>(
        json['podcastDescription'],
      ),
      contentUrl: serializer.fromJson<String>(json['contentUrl']),
      publicationDate: serializer.fromJson<DateTime>(json['publicationDate']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isPlayedPercent: serializer.fromJson<int>(json['isPlayedPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'podcastFeedUrl': serializer.toJson<String>(podcastFeedUrl),
      'title': serializer.toJson<String>(title),
      'episodeDescription': serializer.toJson<String>(episodeDescription),
      'podcastDescription': serializer.toJson<String>(podcastDescription),
      'contentUrl': serializer.toJson<String>(contentUrl),
      'publicationDate': serializer.toJson<DateTime>(publicationDate),
      'durationMs': serializer.toJson<int?>(durationMs),
      'positionMs': serializer.toJson<int>(positionMs),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isPlayedPercent': serializer.toJson<int>(isPlayedPercent),
    };
  }

  PodcastEpisodeTableData copyWith({
    int? id,
    String? podcastFeedUrl,
    String? title,
    String? episodeDescription,
    String? podcastDescription,
    String? contentUrl,
    DateTime? publicationDate,
    Value<int?> durationMs = const Value.absent(),
    int? positionMs,
    Value<String?> imageUrl = const Value.absent(),
    int? isPlayedPercent,
  }) => PodcastEpisodeTableData(
    id: id ?? this.id,
    podcastFeedUrl: podcastFeedUrl ?? this.podcastFeedUrl,
    title: title ?? this.title,
    episodeDescription: episodeDescription ?? this.episodeDescription,
    podcastDescription: podcastDescription ?? this.podcastDescription,
    contentUrl: contentUrl ?? this.contentUrl,
    publicationDate: publicationDate ?? this.publicationDate,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    positionMs: positionMs ?? this.positionMs,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    isPlayedPercent: isPlayedPercent ?? this.isPlayedPercent,
  );
  PodcastEpisodeTableData copyWithCompanion(PodcastEpisodeTableCompanion data) {
    return PodcastEpisodeTableData(
      id: data.id.present ? data.id.value : this.id,
      podcastFeedUrl: data.podcastFeedUrl.present
          ? data.podcastFeedUrl.value
          : this.podcastFeedUrl,
      title: data.title.present ? data.title.value : this.title,
      episodeDescription: data.episodeDescription.present
          ? data.episodeDescription.value
          : this.episodeDescription,
      podcastDescription: data.podcastDescription.present
          ? data.podcastDescription.value
          : this.podcastDescription,
      contentUrl: data.contentUrl.present
          ? data.contentUrl.value
          : this.contentUrl,
      publicationDate: data.publicationDate.present
          ? data.publicationDate.value
          : this.publicationDate,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isPlayedPercent: data.isPlayedPercent.present
          ? data.isPlayedPercent.value
          : this.isPlayedPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastEpisodeTableData(')
          ..write('id: $id, ')
          ..write('podcastFeedUrl: $podcastFeedUrl, ')
          ..write('title: $title, ')
          ..write('episodeDescription: $episodeDescription, ')
          ..write('podcastDescription: $podcastDescription, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('durationMs: $durationMs, ')
          ..write('positionMs: $positionMs, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isPlayedPercent: $isPlayedPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    podcastFeedUrl,
    title,
    episodeDescription,
    podcastDescription,
    contentUrl,
    publicationDate,
    durationMs,
    positionMs,
    imageUrl,
    isPlayedPercent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastEpisodeTableData &&
          other.id == this.id &&
          other.podcastFeedUrl == this.podcastFeedUrl &&
          other.title == this.title &&
          other.episodeDescription == this.episodeDescription &&
          other.podcastDescription == this.podcastDescription &&
          other.contentUrl == this.contentUrl &&
          other.publicationDate == this.publicationDate &&
          other.durationMs == this.durationMs &&
          other.positionMs == this.positionMs &&
          other.imageUrl == this.imageUrl &&
          other.isPlayedPercent == this.isPlayedPercent);
}

class PodcastEpisodeTableCompanion
    extends UpdateCompanion<PodcastEpisodeTableData> {
  final Value<int> id;
  final Value<String> podcastFeedUrl;
  final Value<String> title;
  final Value<String> episodeDescription;
  final Value<String> podcastDescription;
  final Value<String> contentUrl;
  final Value<DateTime> publicationDate;
  final Value<int?> durationMs;
  final Value<int> positionMs;
  final Value<String?> imageUrl;
  final Value<int> isPlayedPercent;
  const PodcastEpisodeTableCompanion({
    this.id = const Value.absent(),
    this.podcastFeedUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.episodeDescription = const Value.absent(),
    this.podcastDescription = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isPlayedPercent = const Value.absent(),
  });
  PodcastEpisodeTableCompanion.insert({
    this.id = const Value.absent(),
    required String podcastFeedUrl,
    required String title,
    required String episodeDescription,
    required String podcastDescription,
    required String contentUrl,
    required DateTime publicationDate,
    this.durationMs = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isPlayedPercent = const Value.absent(),
  }) : podcastFeedUrl = Value(podcastFeedUrl),
       title = Value(title),
       episodeDescription = Value(episodeDescription),
       podcastDescription = Value(podcastDescription),
       contentUrl = Value(contentUrl),
       publicationDate = Value(publicationDate);
  static Insertable<PodcastEpisodeTableData> custom({
    Expression<int>? id,
    Expression<String>? podcastFeedUrl,
    Expression<String>? title,
    Expression<String>? episodeDescription,
    Expression<String>? podcastDescription,
    Expression<String>? contentUrl,
    Expression<DateTime>? publicationDate,
    Expression<int>? durationMs,
    Expression<int>? positionMs,
    Expression<String>? imageUrl,
    Expression<int>? isPlayedPercent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastFeedUrl != null) 'podcast_feed_url': podcastFeedUrl,
      if (title != null) 'title': title,
      if (episodeDescription != null) 'episode_description': episodeDescription,
      if (podcastDescription != null) 'podcast_description': podcastDescription,
      if (contentUrl != null) 'content_url': contentUrl,
      if (publicationDate != null) 'publication_date': publicationDate,
      if (durationMs != null) 'duration_ms': durationMs,
      if (positionMs != null) 'position_ms': positionMs,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isPlayedPercent != null) 'is_played_percent': isPlayedPercent,
    });
  }

  PodcastEpisodeTableCompanion copyWith({
    Value<int>? id,
    Value<String>? podcastFeedUrl,
    Value<String>? title,
    Value<String>? episodeDescription,
    Value<String>? podcastDescription,
    Value<String>? contentUrl,
    Value<DateTime>? publicationDate,
    Value<int?>? durationMs,
    Value<int>? positionMs,
    Value<String?>? imageUrl,
    Value<int>? isPlayedPercent,
  }) {
    return PodcastEpisodeTableCompanion(
      id: id ?? this.id,
      podcastFeedUrl: podcastFeedUrl ?? this.podcastFeedUrl,
      title: title ?? this.title,
      episodeDescription: episodeDescription ?? this.episodeDescription,
      podcastDescription: podcastDescription ?? this.podcastDescription,
      contentUrl: contentUrl ?? this.contentUrl,
      publicationDate: publicationDate ?? this.publicationDate,
      durationMs: durationMs ?? this.durationMs,
      positionMs: positionMs ?? this.positionMs,
      imageUrl: imageUrl ?? this.imageUrl,
      isPlayedPercent: isPlayedPercent ?? this.isPlayedPercent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (podcastFeedUrl.present) {
      map['podcast_feed_url'] = Variable<String>(podcastFeedUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (episodeDescription.present) {
      map['episode_description'] = Variable<String>(episodeDescription.value);
    }
    if (podcastDescription.present) {
      map['podcast_description'] = Variable<String>(podcastDescription.value);
    }
    if (contentUrl.present) {
      map['content_url'] = Variable<String>(contentUrl.value);
    }
    if (publicationDate.present) {
      map['publication_date'] = Variable<DateTime>(publicationDate.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isPlayedPercent.present) {
      map['is_played_percent'] = Variable<int>(isPlayedPercent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastEpisodeTableCompanion(')
          ..write('id: $id, ')
          ..write('podcastFeedUrl: $podcastFeedUrl, ')
          ..write('title: $title, ')
          ..write('episodeDescription: $episodeDescription, ')
          ..write('podcastDescription: $podcastDescription, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('durationMs: $durationMs, ')
          ..write('positionMs: $positionMs, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isPlayedPercent: $isPlayedPercent')
          ..write(')'))
        .toString();
  }
}

class $DownloadedPodcastEpisodeTableTable extends DownloadedPodcastEpisodeTable
    with
        TableInfo<
          $DownloadedPodcastEpisodeTableTable,
          DownloadedPodcastEpisodeTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedPodcastEpisodeTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_episode_table (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, episodeId, filePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_podcast_episode_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedPodcastEpisodeTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadedPodcastEpisodeTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedPodcastEpisodeTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
    );
  }

  @override
  $DownloadedPodcastEpisodeTableTable createAlias(String alias) {
    return $DownloadedPodcastEpisodeTableTable(attachedDatabase, alias);
  }
}

class DownloadedPodcastEpisodeTableData extends DataClass
    implements Insertable<DownloadedPodcastEpisodeTableData> {
  final int id;
  final int episodeId;
  final String filePath;
  const DownloadedPodcastEpisodeTableData({
    required this.id,
    required this.episodeId,
    required this.filePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['episode_id'] = Variable<int>(episodeId);
    map['file_path'] = Variable<String>(filePath);
    return map;
  }

  DownloadedPodcastEpisodeTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadedPodcastEpisodeTableCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      filePath: Value(filePath),
    );
  }

  factory DownloadedPodcastEpisodeTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedPodcastEpisodeTableData(
      id: serializer.fromJson<int>(json['id']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      filePath: serializer.fromJson<String>(json['filePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'episodeId': serializer.toJson<int>(episodeId),
      'filePath': serializer.toJson<String>(filePath),
    };
  }

  DownloadedPodcastEpisodeTableData copyWith({
    int? id,
    int? episodeId,
    String? filePath,
  }) => DownloadedPodcastEpisodeTableData(
    id: id ?? this.id,
    episodeId: episodeId ?? this.episodeId,
    filePath: filePath ?? this.filePath,
  );
  DownloadedPodcastEpisodeTableData copyWithCompanion(
    DownloadedPodcastEpisodeTableCompanion data,
  ) {
    return DownloadedPodcastEpisodeTableData(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedPodcastEpisodeTableData(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, episodeId, filePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedPodcastEpisodeTableData &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.filePath == this.filePath);
}

class DownloadedPodcastEpisodeTableCompanion
    extends UpdateCompanion<DownloadedPodcastEpisodeTableData> {
  final Value<int> id;
  final Value<int> episodeId;
  final Value<String> filePath;
  const DownloadedPodcastEpisodeTableCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.filePath = const Value.absent(),
  });
  DownloadedPodcastEpisodeTableCompanion.insert({
    this.id = const Value.absent(),
    required int episodeId,
    required String filePath,
  }) : episodeId = Value(episodeId),
       filePath = Value(filePath);
  static Insertable<DownloadedPodcastEpisodeTableData> custom({
    Expression<int>? id,
    Expression<int>? episodeId,
    Expression<String>? filePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (filePath != null) 'file_path': filePath,
    });
  }

  DownloadedPodcastEpisodeTableCompanion copyWith({
    Value<int>? id,
    Value<int>? episodeId,
    Value<String>? filePath,
  }) {
    return DownloadedPodcastEpisodeTableCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedPodcastEpisodeTableCompanion(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }
}

class $DownloadTableTable extends DownloadTable
    with TableInfo<$DownloadTableTable, DownloadTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [url, filePath, feedUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  DownloadTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTableData(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
    );
  }

  @override
  $DownloadTableTable createAlias(String alias) {
    return $DownloadTableTable(attachedDatabase, alias);
  }
}

class DownloadTableData extends DataClass
    implements Insertable<DownloadTableData> {
  final String url;
  final String filePath;
  final String feedUrl;
  const DownloadTableData({
    required this.url,
    required this.filePath,
    required this.feedUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['file_path'] = Variable<String>(filePath);
    map['feed_url'] = Variable<String>(feedUrl);
    return map;
  }

  DownloadTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadTableCompanion(
      url: Value(url),
      filePath: Value(filePath),
      feedUrl: Value(feedUrl),
    );
  }

  factory DownloadTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTableData(
      url: serializer.fromJson<String>(json['url']),
      filePath: serializer.fromJson<String>(json['filePath']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'filePath': serializer.toJson<String>(filePath),
      'feedUrl': serializer.toJson<String>(feedUrl),
    };
  }

  DownloadTableData copyWith({
    String? url,
    String? filePath,
    String? feedUrl,
  }) => DownloadTableData(
    url: url ?? this.url,
    filePath: filePath ?? this.filePath,
    feedUrl: feedUrl ?? this.feedUrl,
  );
  DownloadTableData copyWithCompanion(DownloadTableCompanion data) {
    return DownloadTableData(
      url: data.url.present ? data.url.value : this.url,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableData(')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('feedUrl: $feedUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, filePath, feedUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTableData &&
          other.url == this.url &&
          other.filePath == this.filePath &&
          other.feedUrl == this.feedUrl);
}

class DownloadTableCompanion extends UpdateCompanion<DownloadTableData> {
  final Value<String> url;
  final Value<String> filePath;
  final Value<String> feedUrl;
  final Value<int> rowid;
  const DownloadTableCompanion({
    this.url = const Value.absent(),
    this.filePath = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTableCompanion.insert({
    required String url,
    required String filePath,
    required String feedUrl,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       filePath = Value(filePath),
       feedUrl = Value(feedUrl);
  static Insertable<DownloadTableData> custom({
    Expression<String>? url,
    Expression<String>? filePath,
    Expression<String>? feedUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (filePath != null) 'file_path': filePath,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTableCompanion copyWith({
    Value<String>? url,
    Value<String>? filePath,
    Value<String>? feedUrl,
    Value<int>? rowid,
  }) {
    return DownloadTableCompanion(
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      feedUrl: feedUrl ?? this.feedUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableCompanion(')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ArtistTableTable artistTable = $ArtistTableTable(this);
  late final $AlbumTableTable albumTable = $AlbumTableTable(this);
  late final $AlbumArtTableTable albumArtTable = $AlbumArtTableTable(this);
  late final $GenreTableTable genreTable = $GenreTableTable(this);
  late final $TrackTableTable trackTable = $TrackTableTable(this);
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  late final $PlaylistTrackTableTable playlistTrackTable =
      $PlaylistTrackTableTable(this);
  late final $LikedTrackTableTable likedTrackTable = $LikedTrackTableTable(
    this,
  );
  late final $PinnedAlbumTableTable pinnedAlbumTable = $PinnedAlbumTableTable(
    this,
  );
  late final $StarredStationTableTable starredStationTable =
      $StarredStationTableTable(this);
  late final $FavoriteRadioTagTableTable favoriteRadioTagTable =
      $FavoriteRadioTagTableTable(this);
  late final $FavoriteCountryTableTable favoriteCountryTable =
      $FavoriteCountryTableTable(this);
  late final $FavoriteLanguageTableTable favoriteLanguageTable =
      $FavoriteLanguageTableTable(this);
  late final $AppSettingTableTable appSettingTable = $AppSettingTableTable(
    this,
  );
  late final $PodcastTableTable podcastTable = $PodcastTableTable(this);
  late final $PodcastUpdateTableTable podcastUpdateTable =
      $PodcastUpdateTableTable(this);
  late final $PodcastEpisodeTableTable podcastEpisodeTable =
      $PodcastEpisodeTableTable(this);
  late final $DownloadedPodcastEpisodeTableTable downloadedPodcastEpisodeTable =
      $DownloadedPodcastEpisodeTableTable(this);
  late final $DownloadTableTable downloadTable = $DownloadTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    artistTable,
    albumTable,
    albumArtTable,
    genreTable,
    trackTable,
    playlistTable,
    playlistTrackTable,
    likedTrackTable,
    pinnedAlbumTable,
    starredStationTable,
    favoriteRadioTagTable,
    favoriteCountryTable,
    favoriteLanguageTable,
    appSettingTable,
    podcastTable,
    podcastUpdateTable,
    podcastEpisodeTable,
    downloadedPodcastEpisodeTable,
    downloadTable,
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
  _tracksByArtistTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.trackTable,
    aliasName: $_aliasNameGenerator(db.artistTable.id, db.trackTable.artist),
  );

  $$TrackTableTableProcessedTableManager get tracksByArtist {
    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.artist.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksByArtistTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackTableTable, List<TrackTableData>>
  _tracksByAlbumArtistTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.trackTable,
    aliasName: $_aliasNameGenerator(
      db.artistTable.id,
      db.trackTable.albumArtist,
    ),
  );

  $$TrackTableTableProcessedTableManager get tracksByAlbumArtist {
    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.albumArtist.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tracksByAlbumArtistTable($_db),
    );
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

  Expression<bool> tracksByArtist(
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

  Expression<bool> tracksByAlbumArtist(
    Expression<bool> Function($$TrackTableTableFilterComposer f) f,
  ) {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.albumArtist,
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

  Expression<T> tracksByArtist<T extends Object>(
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

  Expression<T> tracksByAlbumArtist<T extends Object>(
    Expression<T> Function($$TrackTableTableAnnotationComposer a) f,
  ) {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.albumArtist,
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
          PrefetchHooks Function({
            bool albumTableRefs,
            bool tracksByArtist,
            bool tracksByAlbumArtist,
          })
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
              ({
                albumTableRefs = false,
                tracksByArtist = false,
                tracksByAlbumArtist = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (albumTableRefs) db.albumTable,
                    if (tracksByArtist) db.trackTable,
                    if (tracksByAlbumArtist) db.trackTable,
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
                      if (tracksByArtist)
                        await $_getPrefetchedData<
                          ArtistTableData,
                          $ArtistTableTable,
                          TrackTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ArtistTableTableReferences
                              ._tracksByArtistTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtistTableTableReferences(
                                db,
                                table,
                                p0,
                              ).tracksByArtist,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artist == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tracksByAlbumArtist)
                        await $_getPrefetchedData<
                          ArtistTableData,
                          $ArtistTableTable,
                          TrackTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ArtistTableTableReferences
                              ._tracksByAlbumArtistTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtistTableTableReferences(
                                db,
                                table,
                                p0,
                              ).tracksByAlbumArtist,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumArtist == item.id,
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
      PrefetchHooks Function({
        bool albumTableRefs,
        bool tracksByArtist,
        bool tracksByAlbumArtist,
      })
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

  static MultiTypedResultKey<$AlbumArtTableTable, List<AlbumArtTableData>>
  _albumArtTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.albumArtTable,
    aliasName: $_aliasNameGenerator(db.albumTable.id, db.albumArtTable.album),
  );

  $$AlbumArtTableTableProcessedTableManager get albumArtTableRefs {
    final manager = $$AlbumArtTableTableTableManager(
      $_db,
      $_db.albumArtTable,
    ).filter((f) => f.album.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_albumArtTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  static MultiTypedResultKey<$PinnedAlbumTableTable, List<PinnedAlbumTableData>>
  _pinnedAlbumTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.pinnedAlbumTable,
    aliasName: $_aliasNameGenerator(
      db.albumTable.id,
      db.pinnedAlbumTable.albumId,
    ),
  );

  $$PinnedAlbumTableTableProcessedTableManager get pinnedAlbumTableRefs {
    final manager = $$PinnedAlbumTableTableTableManager(
      $_db,
      $_db.pinnedAlbumTable,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pinnedAlbumTableRefsTable($_db),
    );
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

  Expression<bool> albumArtTableRefs(
    Expression<bool> Function($$AlbumArtTableTableFilterComposer f) f,
  ) {
    final $$AlbumArtTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumArtTable,
      getReferencedColumn: (t) => t.album,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumArtTableTableFilterComposer(
            $db: $db,
            $table: $db.albumArtTable,
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

  Expression<bool> pinnedAlbumTableRefs(
    Expression<bool> Function($$PinnedAlbumTableTableFilterComposer f) f,
  ) {
    final $$PinnedAlbumTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinnedAlbumTable,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinnedAlbumTableTableFilterComposer(
            $db: $db,
            $table: $db.pinnedAlbumTable,
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

  Expression<T> albumArtTableRefs<T extends Object>(
    Expression<T> Function($$AlbumArtTableTableAnnotationComposer a) f,
  ) {
    final $$AlbumArtTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumArtTable,
      getReferencedColumn: (t) => t.album,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumArtTableTableAnnotationComposer(
            $db: $db,
            $table: $db.albumArtTable,
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

  Expression<T> pinnedAlbumTableRefs<T extends Object>(
    Expression<T> Function($$PinnedAlbumTableTableAnnotationComposer a) f,
  ) {
    final $$PinnedAlbumTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinnedAlbumTable,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinnedAlbumTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pinnedAlbumTable,
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
          PrefetchHooks Function({
            bool artist,
            bool albumArtTableRefs,
            bool trackTableRefs,
            bool pinnedAlbumTableRefs,
          })
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
          prefetchHooksCallback:
              ({
                artist = false,
                albumArtTableRefs = false,
                trackTableRefs = false,
                pinnedAlbumTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (albumArtTableRefs) db.albumArtTable,
                    if (trackTableRefs) db.trackTable,
                    if (pinnedAlbumTableRefs) db.pinnedAlbumTable,
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
                        if (artist) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.artist,
                                    referencedTable: $$AlbumTableTableReferences
                                        ._artistTable(db),
                                    referencedColumn:
                                        $$AlbumTableTableReferences
                                            ._artistTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (albumArtTableRefs)
                        await $_getPrefetchedData<
                          AlbumTableData,
                          $AlbumTableTable,
                          AlbumArtTableData
                        >(
                          currentTable: table,
                          referencedTable: $$AlbumTableTableReferences
                              ._albumArtTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AlbumTableTableReferences(
                                db,
                                table,
                                p0,
                              ).albumArtTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.album == item.id,
                              ),
                          typedResults: items,
                        ),
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.album == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pinnedAlbumTableRefs)
                        await $_getPrefetchedData<
                          AlbumTableData,
                          $AlbumTableTable,
                          PinnedAlbumTableData
                        >(
                          currentTable: table,
                          referencedTable: $$AlbumTableTableReferences
                              ._pinnedAlbumTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AlbumTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pinnedAlbumTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumId == item.id,
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
      PrefetchHooks Function({
        bool artist,
        bool albumArtTableRefs,
        bool trackTableRefs,
        bool pinnedAlbumTableRefs,
      })
    >;
typedef $$AlbumArtTableTableCreateCompanionBuilder =
    AlbumArtTableCompanion Function({
      Value<int> id,
      required int album,
      required Uint8List pictureData,
      required String pictureMimeType,
    });
typedef $$AlbumArtTableTableUpdateCompanionBuilder =
    AlbumArtTableCompanion Function({
      Value<int> id,
      Value<int> album,
      Value<Uint8List> pictureData,
      Value<String> pictureMimeType,
    });

final class $$AlbumArtTableTableReferences
    extends BaseReferences<_$Database, $AlbumArtTableTable, AlbumArtTableData> {
  $$AlbumArtTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AlbumTableTable _albumTable(_$Database db) =>
      db.albumTable.createAlias(
        $_aliasNameGenerator(db.albumArtTable.album, db.albumTable.id),
      );

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
}

class $$AlbumArtTableTableFilterComposer
    extends Composer<_$Database, $AlbumArtTableTable> {
  $$AlbumArtTableTableFilterComposer({
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

  ColumnFilters<Uint8List> get pictureData => $composableBuilder(
    column: $table.pictureData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pictureMimeType => $composableBuilder(
    column: $table.pictureMimeType,
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
}

class $$AlbumArtTableTableOrderingComposer
    extends Composer<_$Database, $AlbumArtTableTable> {
  $$AlbumArtTableTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get pictureData => $composableBuilder(
    column: $table.pictureData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pictureMimeType => $composableBuilder(
    column: $table.pictureMimeType,
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
}

class $$AlbumArtTableTableAnnotationComposer
    extends Composer<_$Database, $AlbumArtTableTable> {
  $$AlbumArtTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get pictureData => $composableBuilder(
    column: $table.pictureData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pictureMimeType => $composableBuilder(
    column: $table.pictureMimeType,
    builder: (column) => column,
  );

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
}

class $$AlbumArtTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $AlbumArtTableTable,
          AlbumArtTableData,
          $$AlbumArtTableTableFilterComposer,
          $$AlbumArtTableTableOrderingComposer,
          $$AlbumArtTableTableAnnotationComposer,
          $$AlbumArtTableTableCreateCompanionBuilder,
          $$AlbumArtTableTableUpdateCompanionBuilder,
          (AlbumArtTableData, $$AlbumArtTableTableReferences),
          AlbumArtTableData,
          PrefetchHooks Function({bool album})
        > {
  $$AlbumArtTableTableTableManager(_$Database db, $AlbumArtTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumArtTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumArtTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumArtTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> album = const Value.absent(),
                Value<Uint8List> pictureData = const Value.absent(),
                Value<String> pictureMimeType = const Value.absent(),
              }) => AlbumArtTableCompanion(
                id: id,
                album: album,
                pictureData: pictureData,
                pictureMimeType: pictureMimeType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int album,
                required Uint8List pictureData,
                required String pictureMimeType,
              }) => AlbumArtTableCompanion.insert(
                id: id,
                album: album,
                pictureData: pictureData,
                pictureMimeType: pictureMimeType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlbumArtTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({album = false}) {
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
                    if (album) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.album,
                                referencedTable: $$AlbumArtTableTableReferences
                                    ._albumTable(db),
                                referencedColumn: $$AlbumArtTableTableReferences
                                    ._albumTable(db)
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

typedef $$AlbumArtTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $AlbumArtTableTable,
      AlbumArtTableData,
      $$AlbumArtTableTableFilterComposer,
      $$AlbumArtTableTableOrderingComposer,
      $$AlbumArtTableTableAnnotationComposer,
      $$AlbumArtTableTableCreateCompanionBuilder,
      $$AlbumArtTableTableUpdateCompanionBuilder,
      (AlbumArtTableData, $$AlbumArtTableTableReferences),
      AlbumArtTableData,
      PrefetchHooks Function({bool album})
    >;
typedef $$GenreTableTableCreateCompanionBuilder =
    GenreTableCompanion Function({Value<int> id, required String name});
typedef $$GenreTableTableUpdateCompanionBuilder =
    GenreTableCompanion Function({Value<int> id, Value<String> name});

final class $$GenreTableTableReferences
    extends BaseReferences<_$Database, $GenreTableTable, GenreTableData> {
  $$GenreTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackTableTable, List<TrackTableData>>
  _tracksByGenreTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.trackTable,
    aliasName: $_aliasNameGenerator(db.genreTable.id, db.trackTable.genre),
  );

  $$TrackTableTableProcessedTableManager get tracksByGenre {
    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.genre.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksByGenreTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GenreTableTableFilterComposer
    extends Composer<_$Database, $GenreTableTable> {
  $$GenreTableTableFilterComposer({
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

  Expression<bool> tracksByGenre(
    Expression<bool> Function($$TrackTableTableFilterComposer f) f,
  ) {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.genre,
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

class $$GenreTableTableOrderingComposer
    extends Composer<_$Database, $GenreTableTable> {
  $$GenreTableTableOrderingComposer({
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

class $$GenreTableTableAnnotationComposer
    extends Composer<_$Database, $GenreTableTable> {
  $$GenreTableTableAnnotationComposer({
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

  Expression<T> tracksByGenre<T extends Object>(
    Expression<T> Function($$TrackTableTableAnnotationComposer a) f,
  ) {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.genre,
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

class $$GenreTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $GenreTableTable,
          GenreTableData,
          $$GenreTableTableFilterComposer,
          $$GenreTableTableOrderingComposer,
          $$GenreTableTableAnnotationComposer,
          $$GenreTableTableCreateCompanionBuilder,
          $$GenreTableTableUpdateCompanionBuilder,
          (GenreTableData, $$GenreTableTableReferences),
          GenreTableData,
          PrefetchHooks Function({bool tracksByGenre})
        > {
  $$GenreTableTableTableManager(_$Database db, $GenreTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GenreTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GenreTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GenreTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => GenreTableCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  GenreTableCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GenreTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tracksByGenre = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tracksByGenre) db.trackTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksByGenre)
                    await $_getPrefetchedData<
                      GenreTableData,
                      $GenreTableTable,
                      TrackTableData
                    >(
                      currentTable: table,
                      referencedTable: $$GenreTableTableReferences
                          ._tracksByGenreTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GenreTableTableReferences(
                            db,
                            table,
                            p0,
                          ).tracksByGenre,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.genre == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GenreTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $GenreTableTable,
      GenreTableData,
      $$GenreTableTableFilterComposer,
      $$GenreTableTableOrderingComposer,
      $$GenreTableTableAnnotationComposer,
      $$GenreTableTableCreateCompanionBuilder,
      $$GenreTableTableUpdateCompanionBuilder,
      (GenreTableData, $$GenreTableTableReferences),
      GenreTableData,
      PrefetchHooks Function({bool tracksByGenre})
    >;
typedef $$TrackTableTableCreateCompanionBuilder =
    TrackTableCompanion Function({
      Value<int> id,
      required String name,
      required String path,
      Value<int?> album,
      Value<int?> artist,
      Value<int?> albumArtist,
      Value<int?> discNumber,
      Value<int?> discTotal,
      Value<double?> durationMs,
      Value<int?> genre,
      Value<int?> trackNumber,
      Value<int?> year,
      Value<String?> lyrics,
    });
typedef $$TrackTableTableUpdateCompanionBuilder =
    TrackTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> path,
      Value<int?> album,
      Value<int?> artist,
      Value<int?> albumArtist,
      Value<int?> discNumber,
      Value<int?> discTotal,
      Value<double?> durationMs,
      Value<int?> genre,
      Value<int?> trackNumber,
      Value<int?> year,
      Value<String?> lyrics,
    });

final class $$TrackTableTableReferences
    extends BaseReferences<_$Database, $TrackTableTable, TrackTableData> {
  $$TrackTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlbumTableTable _albumTable(_$Database db) => db.albumTable
      .createAlias($_aliasNameGenerator(db.trackTable.album, db.albumTable.id));

  $$AlbumTableTableProcessedTableManager? get album {
    final $_column = $_itemColumn<int>('album');
    if ($_column == null) return null;
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

  $$ArtistTableTableProcessedTableManager? get artist {
    final $_column = $_itemColumn<int>('artist');
    if ($_column == null) return null;
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

  static $ArtistTableTable _albumArtistTable(_$Database db) =>
      db.artistTable.createAlias(
        $_aliasNameGenerator(db.trackTable.albumArtist, db.artistTable.id),
      );

  $$ArtistTableTableProcessedTableManager? get albumArtist {
    final $_column = $_itemColumn<int>('album_artist');
    if ($_column == null) return null;
    final manager = $$ArtistTableTableTableManager(
      $_db,
      $_db.artistTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumArtistTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GenreTableTable _genreTable(_$Database db) => db.genreTable
      .createAlias($_aliasNameGenerator(db.trackTable.genre, db.genreTable.id));

  $$GenreTableTableProcessedTableManager? get genre {
    final $_column = $_itemColumn<int>('genre');
    if ($_column == null) return null;
    final manager = $$GenreTableTableTableManager(
      $_db,
      $_db.genreTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_genreTable($_db));
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

  static MultiTypedResultKey<$LikedTrackTableTable, List<LikedTrackTableData>>
  _likedTrackTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.likedTrackTable,
    aliasName: $_aliasNameGenerator(
      db.trackTable.id,
      db.likedTrackTable.trackId,
    ),
  );

  $$LikedTrackTableTableProcessedTableManager get likedTrackTableRefs {
    final manager = $$LikedTrackTableTableTableManager(
      $_db,
      $_db.likedTrackTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _likedTrackTableRefsTable($_db),
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discTotal => $composableBuilder(
    column: $table.discTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
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

  $$ArtistTableTableFilterComposer get albumArtist {
    final $$ArtistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumArtist,
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

  $$GenreTableTableFilterComposer get genre {
    final $$GenreTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genre,
      referencedTable: $db.genreTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenreTableTableFilterComposer(
            $db: $db,
            $table: $db.genreTable,
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

  Expression<bool> likedTrackTableRefs(
    Expression<bool> Function($$LikedTrackTableTableFilterComposer f) f,
  ) {
    final $$LikedTrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.likedTrackTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LikedTrackTableTableFilterComposer(
            $db: $db,
            $table: $db.likedTrackTable,
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discTotal => $composableBuilder(
    column: $table.discTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
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

  $$ArtistTableTableOrderingComposer get albumArtist {
    final $$ArtistTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumArtist,
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

  $$GenreTableTableOrderingComposer get genre {
    final $$GenreTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genre,
      referencedTable: $db.genreTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenreTableTableOrderingComposer(
            $db: $db,
            $table: $db.genreTable,
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

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discTotal =>
      $composableBuilder(column: $table.discTotal, builder: (column) => column);

  GeneratedColumn<double> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);

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

  $$ArtistTableTableAnnotationComposer get albumArtist {
    final $$ArtistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumArtist,
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

  $$GenreTableTableAnnotationComposer get genre {
    final $$GenreTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genre,
      referencedTable: $db.genreTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenreTableTableAnnotationComposer(
            $db: $db,
            $table: $db.genreTable,
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

  Expression<T> likedTrackTableRefs<T extends Object>(
    Expression<T> Function($$LikedTrackTableTableAnnotationComposer a) f,
  ) {
    final $$LikedTrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.likedTrackTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LikedTrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.likedTrackTable,
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
            bool albumArtist,
            bool genre,
            bool playlistTrackTableRefs,
            bool likedTrackTableRefs,
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
                Value<String> path = const Value.absent(),
                Value<int?> album = const Value.absent(),
                Value<int?> artist = const Value.absent(),
                Value<int?> albumArtist = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<int?> discTotal = const Value.absent(),
                Value<double?> durationMs = const Value.absent(),
                Value<int?> genre = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> lyrics = const Value.absent(),
              }) => TrackTableCompanion(
                id: id,
                name: name,
                path: path,
                album: album,
                artist: artist,
                albumArtist: albumArtist,
                discNumber: discNumber,
                discTotal: discTotal,
                durationMs: durationMs,
                genre: genre,
                trackNumber: trackNumber,
                year: year,
                lyrics: lyrics,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String path,
                Value<int?> album = const Value.absent(),
                Value<int?> artist = const Value.absent(),
                Value<int?> albumArtist = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<int?> discTotal = const Value.absent(),
                Value<double?> durationMs = const Value.absent(),
                Value<int?> genre = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> lyrics = const Value.absent(),
              }) => TrackTableCompanion.insert(
                id: id,
                name: name,
                path: path,
                album: album,
                artist: artist,
                albumArtist: albumArtist,
                discNumber: discNumber,
                discTotal: discTotal,
                durationMs: durationMs,
                genre: genre,
                trackNumber: trackNumber,
                year: year,
                lyrics: lyrics,
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
                albumArtist = false,
                genre = false,
                playlistTrackTableRefs = false,
                likedTrackTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistTrackTableRefs) db.playlistTrackTable,
                    if (likedTrackTableRefs) db.likedTrackTable,
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
                        if (albumArtist) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.albumArtist,
                                    referencedTable: $$TrackTableTableReferences
                                        ._albumArtistTable(db),
                                    referencedColumn:
                                        $$TrackTableTableReferences
                                            ._albumArtistTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (genre) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.genre,
                                    referencedTable: $$TrackTableTableReferences
                                        ._genreTable(db),
                                    referencedColumn:
                                        $$TrackTableTableReferences
                                            ._genreTable(db)
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
                      if (likedTrackTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          LikedTrackTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._likedTrackTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).likedTrackTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
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
        bool albumArtist,
        bool genre,
        bool playlistTrackTableRefs,
        bool likedTrackTableRefs,
      })
    >;
typedef $$PlaylistTableTableCreateCompanionBuilder =
    PlaylistTableCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> fromExternalSource,
    });
typedef $$PlaylistTableTableUpdateCompanionBuilder =
    PlaylistTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> fromExternalSource,
    });

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

  ColumnFilters<bool> get fromExternalSource => $composableBuilder(
    column: $table.fromExternalSource,
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

  ColumnOrderings<bool> get fromExternalSource => $composableBuilder(
    column: $table.fromExternalSource,
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

  GeneratedColumn<bool> get fromExternalSource => $composableBuilder(
    column: $table.fromExternalSource,
    builder: (column) => column,
  );

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
                Value<bool> fromExternalSource = const Value.absent(),
              }) => PlaylistTableCompanion(
                id: id,
                name: name,
                fromExternalSource: fromExternalSource,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> fromExternalSource = const Value.absent(),
              }) => PlaylistTableCompanion.insert(
                id: id,
                name: name,
                fromExternalSource: fromExternalSource,
              ),
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
typedef $$LikedTrackTableTableCreateCompanionBuilder =
    LikedTrackTableCompanion Function({Value<int> id, required int trackId});
typedef $$LikedTrackTableTableUpdateCompanionBuilder =
    LikedTrackTableCompanion Function({Value<int> id, Value<int> trackId});

final class $$LikedTrackTableTableReferences
    extends
        BaseReferences<_$Database, $LikedTrackTableTable, LikedTrackTableData> {
  $$LikedTrackTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$Database db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(db.likedTrackTable.trackId, db.trackTable.id),
      );

  $$TrackTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<int>('track_id')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LikedTrackTableTableFilterComposer
    extends Composer<_$Database, $LikedTrackTableTable> {
  $$LikedTrackTableTableFilterComposer({
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

  $$TrackTableTableFilterComposer get trackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
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

class $$LikedTrackTableTableOrderingComposer
    extends Composer<_$Database, $LikedTrackTableTable> {
  $$LikedTrackTableTableOrderingComposer({
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

  $$TrackTableTableOrderingComposer get trackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
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

class $$LikedTrackTableTableAnnotationComposer
    extends Composer<_$Database, $LikedTrackTableTable> {
  $$LikedTrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$TrackTableTableAnnotationComposer get trackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
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

class $$LikedTrackTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $LikedTrackTableTable,
          LikedTrackTableData,
          $$LikedTrackTableTableFilterComposer,
          $$LikedTrackTableTableOrderingComposer,
          $$LikedTrackTableTableAnnotationComposer,
          $$LikedTrackTableTableCreateCompanionBuilder,
          $$LikedTrackTableTableUpdateCompanionBuilder,
          (LikedTrackTableData, $$LikedTrackTableTableReferences),
          LikedTrackTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$LikedTrackTableTableTableManager(_$Database db, $LikedTrackTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LikedTrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LikedTrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LikedTrackTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> trackId = const Value.absent(),
              }) => LikedTrackTableCompanion(id: id, trackId: trackId),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required int trackId}) =>
                  LikedTrackTableCompanion.insert(id: id, trackId: trackId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LikedTrackTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$LikedTrackTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$LikedTrackTableTableReferences
                                        ._trackIdTable(db)
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

typedef $$LikedTrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $LikedTrackTableTable,
      LikedTrackTableData,
      $$LikedTrackTableTableFilterComposer,
      $$LikedTrackTableTableOrderingComposer,
      $$LikedTrackTableTableAnnotationComposer,
      $$LikedTrackTableTableCreateCompanionBuilder,
      $$LikedTrackTableTableUpdateCompanionBuilder,
      (LikedTrackTableData, $$LikedTrackTableTableReferences),
      LikedTrackTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$PinnedAlbumTableTableCreateCompanionBuilder =
    PinnedAlbumTableCompanion Function({Value<int> id, required int albumId});
typedef $$PinnedAlbumTableTableUpdateCompanionBuilder =
    PinnedAlbumTableCompanion Function({Value<int> id, Value<int> albumId});

final class $$PinnedAlbumTableTableReferences
    extends
        BaseReferences<
          _$Database,
          $PinnedAlbumTableTable,
          PinnedAlbumTableData
        > {
  $$PinnedAlbumTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AlbumTableTable _albumIdTable(_$Database db) =>
      db.albumTable.createAlias(
        $_aliasNameGenerator(db.pinnedAlbumTable.albumId, db.albumTable.id),
      );

  $$AlbumTableTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<int>('album_id')!;

    final manager = $$AlbumTableTableTableManager(
      $_db,
      $_db.albumTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PinnedAlbumTableTableFilterComposer
    extends Composer<_$Database, $PinnedAlbumTableTable> {
  $$PinnedAlbumTableTableFilterComposer({
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

  $$AlbumTableTableFilterComposer get albumId {
    final $$AlbumTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
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
}

class $$PinnedAlbumTableTableOrderingComposer
    extends Composer<_$Database, $PinnedAlbumTableTable> {
  $$PinnedAlbumTableTableOrderingComposer({
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

  $$AlbumTableTableOrderingComposer get albumId {
    final $$AlbumTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
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
}

class $$PinnedAlbumTableTableAnnotationComposer
    extends Composer<_$Database, $PinnedAlbumTableTable> {
  $$PinnedAlbumTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$AlbumTableTableAnnotationComposer get albumId {
    final $$AlbumTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
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
}

class $$PinnedAlbumTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PinnedAlbumTableTable,
          PinnedAlbumTableData,
          $$PinnedAlbumTableTableFilterComposer,
          $$PinnedAlbumTableTableOrderingComposer,
          $$PinnedAlbumTableTableAnnotationComposer,
          $$PinnedAlbumTableTableCreateCompanionBuilder,
          $$PinnedAlbumTableTableUpdateCompanionBuilder,
          (PinnedAlbumTableData, $$PinnedAlbumTableTableReferences),
          PinnedAlbumTableData,
          PrefetchHooks Function({bool albumId})
        > {
  $$PinnedAlbumTableTableTableManager(
    _$Database db,
    $PinnedAlbumTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinnedAlbumTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinnedAlbumTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinnedAlbumTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> albumId = const Value.absent(),
              }) => PinnedAlbumTableCompanion(id: id, albumId: albumId),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required int albumId}) =>
                  PinnedAlbumTableCompanion.insert(id: id, albumId: albumId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PinnedAlbumTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumId = false}) {
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
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable:
                                    $$PinnedAlbumTableTableReferences
                                        ._albumIdTable(db),
                                referencedColumn:
                                    $$PinnedAlbumTableTableReferences
                                        ._albumIdTable(db)
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

typedef $$PinnedAlbumTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PinnedAlbumTableTable,
      PinnedAlbumTableData,
      $$PinnedAlbumTableTableFilterComposer,
      $$PinnedAlbumTableTableOrderingComposer,
      $$PinnedAlbumTableTableAnnotationComposer,
      $$PinnedAlbumTableTableCreateCompanionBuilder,
      $$PinnedAlbumTableTableUpdateCompanionBuilder,
      (PinnedAlbumTableData, $$PinnedAlbumTableTableReferences),
      PinnedAlbumTableData,
      PrefetchHooks Function({bool albumId})
    >;
typedef $$StarredStationTableTableCreateCompanionBuilder =
    StarredStationTableCompanion Function({
      required String uuid,
      Value<int> rowid,
    });
typedef $$StarredStationTableTableUpdateCompanionBuilder =
    StarredStationTableCompanion Function({
      Value<String> uuid,
      Value<int> rowid,
    });

class $$StarredStationTableTableFilterComposer
    extends Composer<_$Database, $StarredStationTableTable> {
  $$StarredStationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StarredStationTableTableOrderingComposer
    extends Composer<_$Database, $StarredStationTableTable> {
  $$StarredStationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StarredStationTableTableAnnotationComposer
    extends Composer<_$Database, $StarredStationTableTable> {
  $$StarredStationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);
}

class $$StarredStationTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $StarredStationTableTable,
          StarredStationTableData,
          $$StarredStationTableTableFilterComposer,
          $$StarredStationTableTableOrderingComposer,
          $$StarredStationTableTableAnnotationComposer,
          $$StarredStationTableTableCreateCompanionBuilder,
          $$StarredStationTableTableUpdateCompanionBuilder,
          (
            StarredStationTableData,
            BaseReferences<
              _$Database,
              $StarredStationTableTable,
              StarredStationTableData
            >,
          ),
          StarredStationTableData,
          PrefetchHooks Function()
        > {
  $$StarredStationTableTableTableManager(
    _$Database db,
    $StarredStationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StarredStationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StarredStationTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StarredStationTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StarredStationTableCompanion(uuid: uuid, rowid: rowid),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int> rowid = const Value.absent(),
              }) =>
                  StarredStationTableCompanion.insert(uuid: uuid, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StarredStationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $StarredStationTableTable,
      StarredStationTableData,
      $$StarredStationTableTableFilterComposer,
      $$StarredStationTableTableOrderingComposer,
      $$StarredStationTableTableAnnotationComposer,
      $$StarredStationTableTableCreateCompanionBuilder,
      $$StarredStationTableTableUpdateCompanionBuilder,
      (
        StarredStationTableData,
        BaseReferences<
          _$Database,
          $StarredStationTableTable,
          StarredStationTableData
        >,
      ),
      StarredStationTableData,
      PrefetchHooks Function()
    >;
typedef $$FavoriteRadioTagTableTableCreateCompanionBuilder =
    FavoriteRadioTagTableCompanion Function({
      Value<int> id,
      required String name,
    });
typedef $$FavoriteRadioTagTableTableUpdateCompanionBuilder =
    FavoriteRadioTagTableCompanion Function({
      Value<int> id,
      Value<String> name,
    });

class $$FavoriteRadioTagTableTableFilterComposer
    extends Composer<_$Database, $FavoriteRadioTagTableTable> {
  $$FavoriteRadioTagTableTableFilterComposer({
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
}

class $$FavoriteRadioTagTableTableOrderingComposer
    extends Composer<_$Database, $FavoriteRadioTagTableTable> {
  $$FavoriteRadioTagTableTableOrderingComposer({
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

class $$FavoriteRadioTagTableTableAnnotationComposer
    extends Composer<_$Database, $FavoriteRadioTagTableTable> {
  $$FavoriteRadioTagTableTableAnnotationComposer({
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
}

class $$FavoriteRadioTagTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $FavoriteRadioTagTableTable,
          FavoriteRadioTagTableData,
          $$FavoriteRadioTagTableTableFilterComposer,
          $$FavoriteRadioTagTableTableOrderingComposer,
          $$FavoriteRadioTagTableTableAnnotationComposer,
          $$FavoriteRadioTagTableTableCreateCompanionBuilder,
          $$FavoriteRadioTagTableTableUpdateCompanionBuilder,
          (
            FavoriteRadioTagTableData,
            BaseReferences<
              _$Database,
              $FavoriteRadioTagTableTable,
              FavoriteRadioTagTableData
            >,
          ),
          FavoriteRadioTagTableData,
          PrefetchHooks Function()
        > {
  $$FavoriteRadioTagTableTableTableManager(
    _$Database db,
    $FavoriteRadioTagTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteRadioTagTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FavoriteRadioTagTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FavoriteRadioTagTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => FavoriteRadioTagTableCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  FavoriteRadioTagTableCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteRadioTagTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $FavoriteRadioTagTableTable,
      FavoriteRadioTagTableData,
      $$FavoriteRadioTagTableTableFilterComposer,
      $$FavoriteRadioTagTableTableOrderingComposer,
      $$FavoriteRadioTagTableTableAnnotationComposer,
      $$FavoriteRadioTagTableTableCreateCompanionBuilder,
      $$FavoriteRadioTagTableTableUpdateCompanionBuilder,
      (
        FavoriteRadioTagTableData,
        BaseReferences<
          _$Database,
          $FavoriteRadioTagTableTable,
          FavoriteRadioTagTableData
        >,
      ),
      FavoriteRadioTagTableData,
      PrefetchHooks Function()
    >;
typedef $$FavoriteCountryTableTableCreateCompanionBuilder =
    FavoriteCountryTableCompanion Function({
      Value<int> id,
      required String code,
    });
typedef $$FavoriteCountryTableTableUpdateCompanionBuilder =
    FavoriteCountryTableCompanion Function({Value<int> id, Value<String> code});

class $$FavoriteCountryTableTableFilterComposer
    extends Composer<_$Database, $FavoriteCountryTableTable> {
  $$FavoriteCountryTableTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteCountryTableTableOrderingComposer
    extends Composer<_$Database, $FavoriteCountryTableTable> {
  $$FavoriteCountryTableTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteCountryTableTableAnnotationComposer
    extends Composer<_$Database, $FavoriteCountryTableTable> {
  $$FavoriteCountryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);
}

class $$FavoriteCountryTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $FavoriteCountryTableTable,
          FavoriteCountryTableData,
          $$FavoriteCountryTableTableFilterComposer,
          $$FavoriteCountryTableTableOrderingComposer,
          $$FavoriteCountryTableTableAnnotationComposer,
          $$FavoriteCountryTableTableCreateCompanionBuilder,
          $$FavoriteCountryTableTableUpdateCompanionBuilder,
          (
            FavoriteCountryTableData,
            BaseReferences<
              _$Database,
              $FavoriteCountryTableTable,
              FavoriteCountryTableData
            >,
          ),
          FavoriteCountryTableData,
          PrefetchHooks Function()
        > {
  $$FavoriteCountryTableTableTableManager(
    _$Database db,
    $FavoriteCountryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteCountryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteCountryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FavoriteCountryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
              }) => FavoriteCountryTableCompanion(id: id, code: code),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String code}) =>
                  FavoriteCountryTableCompanion.insert(id: id, code: code),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteCountryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $FavoriteCountryTableTable,
      FavoriteCountryTableData,
      $$FavoriteCountryTableTableFilterComposer,
      $$FavoriteCountryTableTableOrderingComposer,
      $$FavoriteCountryTableTableAnnotationComposer,
      $$FavoriteCountryTableTableCreateCompanionBuilder,
      $$FavoriteCountryTableTableUpdateCompanionBuilder,
      (
        FavoriteCountryTableData,
        BaseReferences<
          _$Database,
          $FavoriteCountryTableTable,
          FavoriteCountryTableData
        >,
      ),
      FavoriteCountryTableData,
      PrefetchHooks Function()
    >;
typedef $$FavoriteLanguageTableTableCreateCompanionBuilder =
    FavoriteLanguageTableCompanion Function({
      Value<int> id,
      required String isoCode,
    });
typedef $$FavoriteLanguageTableTableUpdateCompanionBuilder =
    FavoriteLanguageTableCompanion Function({
      Value<int> id,
      Value<String> isoCode,
    });

class $$FavoriteLanguageTableTableFilterComposer
    extends Composer<_$Database, $FavoriteLanguageTableTable> {
  $$FavoriteLanguageTableTableFilterComposer({
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

  ColumnFilters<String> get isoCode => $composableBuilder(
    column: $table.isoCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteLanguageTableTableOrderingComposer
    extends Composer<_$Database, $FavoriteLanguageTableTable> {
  $$FavoriteLanguageTableTableOrderingComposer({
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

  ColumnOrderings<String> get isoCode => $composableBuilder(
    column: $table.isoCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteLanguageTableTableAnnotationComposer
    extends Composer<_$Database, $FavoriteLanguageTableTable> {
  $$FavoriteLanguageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get isoCode =>
      $composableBuilder(column: $table.isoCode, builder: (column) => column);
}

class $$FavoriteLanguageTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $FavoriteLanguageTableTable,
          FavoriteLanguageTableData,
          $$FavoriteLanguageTableTableFilterComposer,
          $$FavoriteLanguageTableTableOrderingComposer,
          $$FavoriteLanguageTableTableAnnotationComposer,
          $$FavoriteLanguageTableTableCreateCompanionBuilder,
          $$FavoriteLanguageTableTableUpdateCompanionBuilder,
          (
            FavoriteLanguageTableData,
            BaseReferences<
              _$Database,
              $FavoriteLanguageTableTable,
              FavoriteLanguageTableData
            >,
          ),
          FavoriteLanguageTableData,
          PrefetchHooks Function()
        > {
  $$FavoriteLanguageTableTableTableManager(
    _$Database db,
    $FavoriteLanguageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteLanguageTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FavoriteLanguageTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FavoriteLanguageTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> isoCode = const Value.absent(),
              }) => FavoriteLanguageTableCompanion(id: id, isoCode: isoCode),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String isoCode,
              }) => FavoriteLanguageTableCompanion.insert(
                id: id,
                isoCode: isoCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteLanguageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $FavoriteLanguageTableTable,
      FavoriteLanguageTableData,
      $$FavoriteLanguageTableTableFilterComposer,
      $$FavoriteLanguageTableTableOrderingComposer,
      $$FavoriteLanguageTableTableAnnotationComposer,
      $$FavoriteLanguageTableTableCreateCompanionBuilder,
      $$FavoriteLanguageTableTableUpdateCompanionBuilder,
      (
        FavoriteLanguageTableData,
        BaseReferences<
          _$Database,
          $FavoriteLanguageTableTable,
          FavoriteLanguageTableData
        >,
      ),
      FavoriteLanguageTableData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingTableTableCreateCompanionBuilder =
    AppSettingTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingTableTableUpdateCompanionBuilder =
    AppSettingTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingTableTableFilterComposer
    extends Composer<_$Database, $AppSettingTableTable> {
  $$AppSettingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingTableTableOrderingComposer
    extends Composer<_$Database, $AppSettingTableTable> {
  $$AppSettingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingTableTableAnnotationComposer
    extends Composer<_$Database, $AppSettingTableTable> {
  $$AppSettingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $AppSettingTableTable,
          AppSettingTableData,
          $$AppSettingTableTableFilterComposer,
          $$AppSettingTableTableOrderingComposer,
          $$AppSettingTableTableAnnotationComposer,
          $$AppSettingTableTableCreateCompanionBuilder,
          $$AppSettingTableTableUpdateCompanionBuilder,
          (
            AppSettingTableData,
            BaseReferences<
              _$Database,
              $AppSettingTableTable,
              AppSettingTableData
            >,
          ),
          AppSettingTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingTableTableTableManager(_$Database db, $AppSettingTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $AppSettingTableTable,
      AppSettingTableData,
      $$AppSettingTableTableFilterComposer,
      $$AppSettingTableTableOrderingComposer,
      $$AppSettingTableTableAnnotationComposer,
      $$AppSettingTableTableCreateCompanionBuilder,
      $$AppSettingTableTableUpdateCompanionBuilder,
      (
        AppSettingTableData,
        BaseReferences<_$Database, $AppSettingTableTable, AppSettingTableData>,
      ),
      AppSettingTableData,
      PrefetchHooks Function()
    >;
typedef $$PodcastTableTableCreateCompanionBuilder =
    PodcastTableCompanion Function({
      required String feedUrl,
      required String name,
      required String artist,
      required String description,
      Value<String?> imageUrl,
      required DateTime lastUpdated,
      Value<bool> ascending,
      Value<int> rowid,
    });
typedef $$PodcastTableTableUpdateCompanionBuilder =
    PodcastTableCompanion Function({
      Value<String> feedUrl,
      Value<String> name,
      Value<String> artist,
      Value<String> description,
      Value<String?> imageUrl,
      Value<DateTime> lastUpdated,
      Value<bool> ascending,
      Value<int> rowid,
    });

final class $$PodcastTableTableReferences
    extends BaseReferences<_$Database, $PodcastTableTable, PodcastTableData> {
  $$PodcastTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $PodcastUpdateTableTable,
    List<PodcastUpdateTableData>
  >
  _podcastUpdateTableRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.podcastUpdateTable,
    aliasName: $_aliasNameGenerator(
      db.podcastTable.feedUrl,
      db.podcastUpdateTable.podcastFeedUrl,
    ),
  );

  $$PodcastUpdateTableTableProcessedTableManager get podcastUpdateTableRefs {
    final manager =
        $$PodcastUpdateTableTableTableManager(
          $_db,
          $_db.podcastUpdateTable,
        ).filter(
          (f) => f.podcastFeedUrl.feedUrl.sqlEquals(
            $_itemColumn<String>('feed_url')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _podcastUpdateTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PodcastTableTableFilterComposer
    extends Composer<_$Database, $PodcastTableTable> {
  $$PodcastTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ascending => $composableBuilder(
    column: $table.ascending,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> podcastUpdateTableRefs(
    Expression<bool> Function($$PodcastUpdateTableTableFilterComposer f) f,
  ) {
    final $$PodcastUpdateTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedUrl,
      referencedTable: $db.podcastUpdateTable,
      getReferencedColumn: (t) => t.podcastFeedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastUpdateTableTableFilterComposer(
            $db: $db,
            $table: $db.podcastUpdateTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastTableTableOrderingComposer
    extends Composer<_$Database, $PodcastTableTable> {
  $$PodcastTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ascending => $composableBuilder(
    column: $table.ascending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PodcastTableTableAnnotationComposer
    extends Composer<_$Database, $PodcastTableTable> {
  $$PodcastTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ascending =>
      $composableBuilder(column: $table.ascending, builder: (column) => column);

  Expression<T> podcastUpdateTableRefs<T extends Object>(
    Expression<T> Function($$PodcastUpdateTableTableAnnotationComposer a) f,
  ) {
    final $$PodcastUpdateTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.feedUrl,
          referencedTable: $db.podcastUpdateTable,
          getReferencedColumn: (t) => t.podcastFeedUrl,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastUpdateTableTableAnnotationComposer(
                $db: $db,
                $table: $db.podcastUpdateTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PodcastTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PodcastTableTable,
          PodcastTableData,
          $$PodcastTableTableFilterComposer,
          $$PodcastTableTableOrderingComposer,
          $$PodcastTableTableAnnotationComposer,
          $$PodcastTableTableCreateCompanionBuilder,
          $$PodcastTableTableUpdateCompanionBuilder,
          (PodcastTableData, $$PodcastTableTableReferences),
          PodcastTableData,
          PrefetchHooks Function({bool podcastUpdateTableRefs})
        > {
  $$PodcastTableTableTableManager(_$Database db, $PodcastTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedUrl = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> ascending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodcastTableCompanion(
                feedUrl: feedUrl,
                name: name,
                artist: artist,
                description: description,
                imageUrl: imageUrl,
                lastUpdated: lastUpdated,
                ascending: ascending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedUrl,
                required String name,
                required String artist,
                required String description,
                Value<String?> imageUrl = const Value.absent(),
                required DateTime lastUpdated,
                Value<bool> ascending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodcastTableCompanion.insert(
                feedUrl: feedUrl,
                name: name,
                artist: artist,
                description: description,
                imageUrl: imageUrl,
                lastUpdated: lastUpdated,
                ascending: ascending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastUpdateTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (podcastUpdateTableRefs) db.podcastUpdateTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (podcastUpdateTableRefs)
                    await $_getPrefetchedData<
                      PodcastTableData,
                      $PodcastTableTable,
                      PodcastUpdateTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PodcastTableTableReferences
                          ._podcastUpdateTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PodcastTableTableReferences(
                            db,
                            table,
                            p0,
                          ).podcastUpdateTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.podcastFeedUrl == item.feedUrl,
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

typedef $$PodcastTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PodcastTableTable,
      PodcastTableData,
      $$PodcastTableTableFilterComposer,
      $$PodcastTableTableOrderingComposer,
      $$PodcastTableTableAnnotationComposer,
      $$PodcastTableTableCreateCompanionBuilder,
      $$PodcastTableTableUpdateCompanionBuilder,
      (PodcastTableData, $$PodcastTableTableReferences),
      PodcastTableData,
      PrefetchHooks Function({bool podcastUpdateTableRefs})
    >;
typedef $$PodcastUpdateTableTableCreateCompanionBuilder =
    PodcastUpdateTableCompanion Function({
      Value<int> id,
      required String podcastFeedUrl,
    });
typedef $$PodcastUpdateTableTableUpdateCompanionBuilder =
    PodcastUpdateTableCompanion Function({
      Value<int> id,
      Value<String> podcastFeedUrl,
    });

final class $$PodcastUpdateTableTableReferences
    extends
        BaseReferences<
          _$Database,
          $PodcastUpdateTableTable,
          PodcastUpdateTableData
        > {
  $$PodcastUpdateTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PodcastTableTable _podcastFeedUrlTable(_$Database db) =>
      db.podcastTable.createAlias(
        $_aliasNameGenerator(
          db.podcastUpdateTable.podcastFeedUrl,
          db.podcastTable.feedUrl,
        ),
      );

  $$PodcastTableTableProcessedTableManager get podcastFeedUrl {
    final $_column = $_itemColumn<String>('podcast_feed_url')!;

    final manager = $$PodcastTableTableTableManager(
      $_db,
      $_db.podcastTable,
    ).filter((f) => f.feedUrl.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastFeedUrlTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PodcastUpdateTableTableFilterComposer
    extends Composer<_$Database, $PodcastUpdateTableTable> {
  $$PodcastUpdateTableTableFilterComposer({
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

  $$PodcastTableTableFilterComposer get podcastFeedUrl {
    final $$PodcastTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastFeedUrl,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.feedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableFilterComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastUpdateTableTableOrderingComposer
    extends Composer<_$Database, $PodcastUpdateTableTable> {
  $$PodcastUpdateTableTableOrderingComposer({
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

  $$PodcastTableTableOrderingComposer get podcastFeedUrl {
    final $$PodcastTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastFeedUrl,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.feedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableOrderingComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastUpdateTableTableAnnotationComposer
    extends Composer<_$Database, $PodcastUpdateTableTable> {
  $$PodcastUpdateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$PodcastTableTableAnnotationComposer get podcastFeedUrl {
    final $$PodcastTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastFeedUrl,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.feedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableAnnotationComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastUpdateTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PodcastUpdateTableTable,
          PodcastUpdateTableData,
          $$PodcastUpdateTableTableFilterComposer,
          $$PodcastUpdateTableTableOrderingComposer,
          $$PodcastUpdateTableTableAnnotationComposer,
          $$PodcastUpdateTableTableCreateCompanionBuilder,
          $$PodcastUpdateTableTableUpdateCompanionBuilder,
          (PodcastUpdateTableData, $$PodcastUpdateTableTableReferences),
          PodcastUpdateTableData,
          PrefetchHooks Function({bool podcastFeedUrl})
        > {
  $$PodcastUpdateTableTableTableManager(
    _$Database db,
    $PodcastUpdateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastUpdateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastUpdateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastUpdateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> podcastFeedUrl = const Value.absent(),
              }) => PodcastUpdateTableCompanion(
                id: id,
                podcastFeedUrl: podcastFeedUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String podcastFeedUrl,
              }) => PodcastUpdateTableCompanion.insert(
                id: id,
                podcastFeedUrl: podcastFeedUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastUpdateTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastFeedUrl = false}) {
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
                    if (podcastFeedUrl) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastFeedUrl,
                                referencedTable:
                                    $$PodcastUpdateTableTableReferences
                                        ._podcastFeedUrlTable(db),
                                referencedColumn:
                                    $$PodcastUpdateTableTableReferences
                                        ._podcastFeedUrlTable(db)
                                        .feedUrl,
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

typedef $$PodcastUpdateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PodcastUpdateTableTable,
      PodcastUpdateTableData,
      $$PodcastUpdateTableTableFilterComposer,
      $$PodcastUpdateTableTableOrderingComposer,
      $$PodcastUpdateTableTableAnnotationComposer,
      $$PodcastUpdateTableTableCreateCompanionBuilder,
      $$PodcastUpdateTableTableUpdateCompanionBuilder,
      (PodcastUpdateTableData, $$PodcastUpdateTableTableReferences),
      PodcastUpdateTableData,
      PrefetchHooks Function({bool podcastFeedUrl})
    >;
typedef $$PodcastEpisodeTableTableCreateCompanionBuilder =
    PodcastEpisodeTableCompanion Function({
      Value<int> id,
      required String podcastFeedUrl,
      required String title,
      required String episodeDescription,
      required String podcastDescription,
      required String contentUrl,
      required DateTime publicationDate,
      Value<int?> durationMs,
      Value<int> positionMs,
      Value<String?> imageUrl,
      Value<int> isPlayedPercent,
    });
typedef $$PodcastEpisodeTableTableUpdateCompanionBuilder =
    PodcastEpisodeTableCompanion Function({
      Value<int> id,
      Value<String> podcastFeedUrl,
      Value<String> title,
      Value<String> episodeDescription,
      Value<String> podcastDescription,
      Value<String> contentUrl,
      Value<DateTime> publicationDate,
      Value<int?> durationMs,
      Value<int> positionMs,
      Value<String?> imageUrl,
      Value<int> isPlayedPercent,
    });

final class $$PodcastEpisodeTableTableReferences
    extends
        BaseReferences<
          _$Database,
          $PodcastEpisodeTableTable,
          PodcastEpisodeTableData
        > {
  $$PodcastEpisodeTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PodcastTableTable _podcastFeedUrlTable(_$Database db) =>
      db.podcastTable.createAlias(
        $_aliasNameGenerator(
          db.podcastEpisodeTable.podcastFeedUrl,
          db.podcastTable.feedUrl,
        ),
      );

  $$PodcastTableTableProcessedTableManager get podcastFeedUrl {
    final $_column = $_itemColumn<String>('podcast_feed_url')!;

    final manager = $$PodcastTableTableTableManager(
      $_db,
      $_db.podcastTable,
    ).filter((f) => f.feedUrl.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastFeedUrlTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PodcastTableTable _podcastDescriptionTable(_$Database db) =>
      db.podcastTable.createAlias(
        $_aliasNameGenerator(
          db.podcastEpisodeTable.podcastDescription,
          db.podcastTable.description,
        ),
      );

  $$PodcastTableTableProcessedTableManager get podcastDescription {
    final $_column = $_itemColumn<String>('podcast_description')!;

    final manager = $$PodcastTableTableTableManager(
      $_db,
      $_db.podcastTable,
    ).filter((f) => f.description.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastDescriptionTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $DownloadedPodcastEpisodeTableTable,
    List<DownloadedPodcastEpisodeTableData>
  >
  _downloadedPodcastEpisodeTableRefsTable(_$Database db) =>
      MultiTypedResultKey.fromTable(
        db.downloadedPodcastEpisodeTable,
        aliasName: $_aliasNameGenerator(
          db.podcastEpisodeTable.id,
          db.downloadedPodcastEpisodeTable.episodeId,
        ),
      );

  $$DownloadedPodcastEpisodeTableTableProcessedTableManager
  get downloadedPodcastEpisodeTableRefs {
    final manager = $$DownloadedPodcastEpisodeTableTableTableManager(
      $_db,
      $_db.downloadedPodcastEpisodeTable,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _downloadedPodcastEpisodeTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PodcastEpisodeTableTableFilterComposer
    extends Composer<_$Database, $PodcastEpisodeTableTable> {
  $$PodcastEpisodeTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeDescription => $composableBuilder(
    column: $table.episodeDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isPlayedPercent => $composableBuilder(
    column: $table.isPlayedPercent,
    builder: (column) => ColumnFilters(column),
  );

  $$PodcastTableTableFilterComposer get podcastFeedUrl {
    final $$PodcastTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastFeedUrl,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.feedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableFilterComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PodcastTableTableFilterComposer get podcastDescription {
    final $$PodcastTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastDescription,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.description,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableFilterComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> downloadedPodcastEpisodeTableRefs(
    Expression<bool> Function(
      $$DownloadedPodcastEpisodeTableTableFilterComposer f,
    )
    f,
  ) {
    final $$DownloadedPodcastEpisodeTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.downloadedPodcastEpisodeTable,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DownloadedPodcastEpisodeTableTableFilterComposer(
                $db: $db,
                $table: $db.downloadedPodcastEpisodeTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PodcastEpisodeTableTableOrderingComposer
    extends Composer<_$Database, $PodcastEpisodeTableTable> {
  $$PodcastEpisodeTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeDescription => $composableBuilder(
    column: $table.episodeDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isPlayedPercent => $composableBuilder(
    column: $table.isPlayedPercent,
    builder: (column) => ColumnOrderings(column),
  );

  $$PodcastTableTableOrderingComposer get podcastFeedUrl {
    final $$PodcastTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastFeedUrl,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.feedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableOrderingComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PodcastTableTableOrderingComposer get podcastDescription {
    final $$PodcastTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastDescription,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.description,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableOrderingComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastEpisodeTableTableAnnotationComposer
    extends Composer<_$Database, $PodcastEpisodeTableTable> {
  $$PodcastEpisodeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get episodeDescription => $composableBuilder(
    column: $table.episodeDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get isPlayedPercent => $composableBuilder(
    column: $table.isPlayedPercent,
    builder: (column) => column,
  );

  $$PodcastTableTableAnnotationComposer get podcastFeedUrl {
    final $$PodcastTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastFeedUrl,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.feedUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableAnnotationComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PodcastTableTableAnnotationComposer get podcastDescription {
    final $$PodcastTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastDescription,
      referencedTable: $db.podcastTable,
      getReferencedColumn: (t) => t.description,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastTableTableAnnotationComposer(
            $db: $db,
            $table: $db.podcastTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> downloadedPodcastEpisodeTableRefs<T extends Object>(
    Expression<T> Function(
      $$DownloadedPodcastEpisodeTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$DownloadedPodcastEpisodeTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.downloadedPodcastEpisodeTable,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DownloadedPodcastEpisodeTableTableAnnotationComposer(
                $db: $db,
                $table: $db.downloadedPodcastEpisodeTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PodcastEpisodeTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PodcastEpisodeTableTable,
          PodcastEpisodeTableData,
          $$PodcastEpisodeTableTableFilterComposer,
          $$PodcastEpisodeTableTableOrderingComposer,
          $$PodcastEpisodeTableTableAnnotationComposer,
          $$PodcastEpisodeTableTableCreateCompanionBuilder,
          $$PodcastEpisodeTableTableUpdateCompanionBuilder,
          (PodcastEpisodeTableData, $$PodcastEpisodeTableTableReferences),
          PodcastEpisodeTableData,
          PrefetchHooks Function({
            bool podcastFeedUrl,
            bool podcastDescription,
            bool downloadedPodcastEpisodeTableRefs,
          })
        > {
  $$PodcastEpisodeTableTableTableManager(
    _$Database db,
    $PodcastEpisodeTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastEpisodeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastEpisodeTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PodcastEpisodeTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> podcastFeedUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> episodeDescription = const Value.absent(),
                Value<String> podcastDescription = const Value.absent(),
                Value<String> contentUrl = const Value.absent(),
                Value<DateTime> publicationDate = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> isPlayedPercent = const Value.absent(),
              }) => PodcastEpisodeTableCompanion(
                id: id,
                podcastFeedUrl: podcastFeedUrl,
                title: title,
                episodeDescription: episodeDescription,
                podcastDescription: podcastDescription,
                contentUrl: contentUrl,
                publicationDate: publicationDate,
                durationMs: durationMs,
                positionMs: positionMs,
                imageUrl: imageUrl,
                isPlayedPercent: isPlayedPercent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String podcastFeedUrl,
                required String title,
                required String episodeDescription,
                required String podcastDescription,
                required String contentUrl,
                required DateTime publicationDate,
                Value<int?> durationMs = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> isPlayedPercent = const Value.absent(),
              }) => PodcastEpisodeTableCompanion.insert(
                id: id,
                podcastFeedUrl: podcastFeedUrl,
                title: title,
                episodeDescription: episodeDescription,
                podcastDescription: podcastDescription,
                contentUrl: contentUrl,
                publicationDate: publicationDate,
                durationMs: durationMs,
                positionMs: positionMs,
                imageUrl: imageUrl,
                isPlayedPercent: isPlayedPercent,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastEpisodeTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                podcastFeedUrl = false,
                podcastDescription = false,
                downloadedPodcastEpisodeTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (downloadedPodcastEpisodeTableRefs)
                      db.downloadedPodcastEpisodeTable,
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
                        if (podcastFeedUrl) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.podcastFeedUrl,
                                    referencedTable:
                                        $$PodcastEpisodeTableTableReferences
                                            ._podcastFeedUrlTable(db),
                                    referencedColumn:
                                        $$PodcastEpisodeTableTableReferences
                                            ._podcastFeedUrlTable(db)
                                            .feedUrl,
                                  )
                                  as T;
                        }
                        if (podcastDescription) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.podcastDescription,
                                    referencedTable:
                                        $$PodcastEpisodeTableTableReferences
                                            ._podcastDescriptionTable(db),
                                    referencedColumn:
                                        $$PodcastEpisodeTableTableReferences
                                            ._podcastDescriptionTable(db)
                                            .description,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (downloadedPodcastEpisodeTableRefs)
                        await $_getPrefetchedData<
                          PodcastEpisodeTableData,
                          $PodcastEpisodeTableTable,
                          DownloadedPodcastEpisodeTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PodcastEpisodeTableTableReferences
                              ._downloadedPodcastEpisodeTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PodcastEpisodeTableTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadedPodcastEpisodeTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
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

typedef $$PodcastEpisodeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PodcastEpisodeTableTable,
      PodcastEpisodeTableData,
      $$PodcastEpisodeTableTableFilterComposer,
      $$PodcastEpisodeTableTableOrderingComposer,
      $$PodcastEpisodeTableTableAnnotationComposer,
      $$PodcastEpisodeTableTableCreateCompanionBuilder,
      $$PodcastEpisodeTableTableUpdateCompanionBuilder,
      (PodcastEpisodeTableData, $$PodcastEpisodeTableTableReferences),
      PodcastEpisodeTableData,
      PrefetchHooks Function({
        bool podcastFeedUrl,
        bool podcastDescription,
        bool downloadedPodcastEpisodeTableRefs,
      })
    >;
typedef $$DownloadedPodcastEpisodeTableTableCreateCompanionBuilder =
    DownloadedPodcastEpisodeTableCompanion Function({
      Value<int> id,
      required int episodeId,
      required String filePath,
    });
typedef $$DownloadedPodcastEpisodeTableTableUpdateCompanionBuilder =
    DownloadedPodcastEpisodeTableCompanion Function({
      Value<int> id,
      Value<int> episodeId,
      Value<String> filePath,
    });

final class $$DownloadedPodcastEpisodeTableTableReferences
    extends
        BaseReferences<
          _$Database,
          $DownloadedPodcastEpisodeTableTable,
          DownloadedPodcastEpisodeTableData
        > {
  $$DownloadedPodcastEpisodeTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PodcastEpisodeTableTable _episodeIdTable(_$Database db) =>
      db.podcastEpisodeTable.createAlias(
        $_aliasNameGenerator(
          db.downloadedPodcastEpisodeTable.episodeId,
          db.podcastEpisodeTable.id,
        ),
      );

  $$PodcastEpisodeTableTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$PodcastEpisodeTableTableTableManager(
      $_db,
      $_db.podcastEpisodeTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadedPodcastEpisodeTableTableFilterComposer
    extends Composer<_$Database, $DownloadedPodcastEpisodeTableTable> {
  $$DownloadedPodcastEpisodeTableTableFilterComposer({
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

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  $$PodcastEpisodeTableTableFilterComposer get episodeId {
    final $$PodcastEpisodeTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.podcastEpisodeTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastEpisodeTableTableFilterComposer(
            $db: $db,
            $table: $db.podcastEpisodeTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadedPodcastEpisodeTableTableOrderingComposer
    extends Composer<_$Database, $DownloadedPodcastEpisodeTableTable> {
  $$DownloadedPodcastEpisodeTableTableOrderingComposer({
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

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$PodcastEpisodeTableTableOrderingComposer get episodeId {
    final $$PodcastEpisodeTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.podcastEpisodeTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastEpisodeTableTableOrderingComposer(
                $db: $db,
                $table: $db.podcastEpisodeTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DownloadedPodcastEpisodeTableTableAnnotationComposer
    extends Composer<_$Database, $DownloadedPodcastEpisodeTableTable> {
  $$DownloadedPodcastEpisodeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  $$PodcastEpisodeTableTableAnnotationComposer get episodeId {
    final $$PodcastEpisodeTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.podcastEpisodeTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastEpisodeTableTableAnnotationComposer(
                $db: $db,
                $table: $db.podcastEpisodeTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DownloadedPodcastEpisodeTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $DownloadedPodcastEpisodeTableTable,
          DownloadedPodcastEpisodeTableData,
          $$DownloadedPodcastEpisodeTableTableFilterComposer,
          $$DownloadedPodcastEpisodeTableTableOrderingComposer,
          $$DownloadedPodcastEpisodeTableTableAnnotationComposer,
          $$DownloadedPodcastEpisodeTableTableCreateCompanionBuilder,
          $$DownloadedPodcastEpisodeTableTableUpdateCompanionBuilder,
          (
            DownloadedPodcastEpisodeTableData,
            $$DownloadedPodcastEpisodeTableTableReferences,
          ),
          DownloadedPodcastEpisodeTableData,
          PrefetchHooks Function({bool episodeId})
        > {
  $$DownloadedPodcastEpisodeTableTableTableManager(
    _$Database db,
    $DownloadedPodcastEpisodeTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedPodcastEpisodeTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DownloadedPodcastEpisodeTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DownloadedPodcastEpisodeTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> episodeId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
              }) => DownloadedPodcastEpisodeTableCompanion(
                id: id,
                episodeId: episodeId,
                filePath: filePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int episodeId,
                required String filePath,
              }) => DownloadedPodcastEpisodeTableCompanion.insert(
                id: id,
                episodeId: episodeId,
                filePath: filePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadedPodcastEpisodeTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
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
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable:
                                    $$DownloadedPodcastEpisodeTableTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$DownloadedPodcastEpisodeTableTableReferences
                                        ._episodeIdTable(db)
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

typedef $$DownloadedPodcastEpisodeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $DownloadedPodcastEpisodeTableTable,
      DownloadedPodcastEpisodeTableData,
      $$DownloadedPodcastEpisodeTableTableFilterComposer,
      $$DownloadedPodcastEpisodeTableTableOrderingComposer,
      $$DownloadedPodcastEpisodeTableTableAnnotationComposer,
      $$DownloadedPodcastEpisodeTableTableCreateCompanionBuilder,
      $$DownloadedPodcastEpisodeTableTableUpdateCompanionBuilder,
      (
        DownloadedPodcastEpisodeTableData,
        $$DownloadedPodcastEpisodeTableTableReferences,
      ),
      DownloadedPodcastEpisodeTableData,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$DownloadTableTableCreateCompanionBuilder =
    DownloadTableCompanion Function({
      required String url,
      required String filePath,
      required String feedUrl,
      Value<int> rowid,
    });
typedef $$DownloadTableTableUpdateCompanionBuilder =
    DownloadTableCompanion Function({
      Value<String> url,
      Value<String> filePath,
      Value<String> feedUrl,
      Value<int> rowid,
    });

class $$DownloadTableTableFilterComposer
    extends Composer<_$Database, $DownloadTableTable> {
  $$DownloadTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTableTableOrderingComposer
    extends Composer<_$Database, $DownloadTableTable> {
  $$DownloadTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTableTableAnnotationComposer
    extends Composer<_$Database, $DownloadTableTable> {
  $$DownloadTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);
}

class $$DownloadTableTableTableManager
    extends
        RootTableManager<
          _$Database,
          $DownloadTableTable,
          DownloadTableData,
          $$DownloadTableTableFilterComposer,
          $$DownloadTableTableOrderingComposer,
          $$DownloadTableTableAnnotationComposer,
          $$DownloadTableTableCreateCompanionBuilder,
          $$DownloadTableTableUpdateCompanionBuilder,
          (
            DownloadTableData,
            BaseReferences<_$Database, $DownloadTableTable, DownloadTableData>,
          ),
          DownloadTableData,
          PrefetchHooks Function()
        > {
  $$DownloadTableTableTableManager(_$Database db, $DownloadTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTableCompanion(
                url: url,
                filePath: filePath,
                feedUrl: feedUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required String filePath,
                required String feedUrl,
                Value<int> rowid = const Value.absent(),
              }) => DownloadTableCompanion.insert(
                url: url,
                filePath: filePath,
                feedUrl: feedUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTableTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $DownloadTableTable,
      DownloadTableData,
      $$DownloadTableTableFilterComposer,
      $$DownloadTableTableOrderingComposer,
      $$DownloadTableTableAnnotationComposer,
      $$DownloadTableTableCreateCompanionBuilder,
      $$DownloadTableTableUpdateCompanionBuilder,
      (
        DownloadTableData,
        BaseReferences<_$Database, $DownloadTableTable, DownloadTableData>,
      ),
      DownloadTableData,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ArtistTableTableTableManager get artistTable =>
      $$ArtistTableTableTableManager(_db, _db.artistTable);
  $$AlbumTableTableTableManager get albumTable =>
      $$AlbumTableTableTableManager(_db, _db.albumTable);
  $$AlbumArtTableTableTableManager get albumArtTable =>
      $$AlbumArtTableTableTableManager(_db, _db.albumArtTable);
  $$GenreTableTableTableManager get genreTable =>
      $$GenreTableTableTableManager(_db, _db.genreTable);
  $$TrackTableTableTableManager get trackTable =>
      $$TrackTableTableTableManager(_db, _db.trackTable);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
  $$PlaylistTrackTableTableTableManager get playlistTrackTable =>
      $$PlaylistTrackTableTableTableManager(_db, _db.playlistTrackTable);
  $$LikedTrackTableTableTableManager get likedTrackTable =>
      $$LikedTrackTableTableTableManager(_db, _db.likedTrackTable);
  $$PinnedAlbumTableTableTableManager get pinnedAlbumTable =>
      $$PinnedAlbumTableTableTableManager(_db, _db.pinnedAlbumTable);
  $$StarredStationTableTableTableManager get starredStationTable =>
      $$StarredStationTableTableTableManager(_db, _db.starredStationTable);
  $$FavoriteRadioTagTableTableTableManager get favoriteRadioTagTable =>
      $$FavoriteRadioTagTableTableTableManager(_db, _db.favoriteRadioTagTable);
  $$FavoriteCountryTableTableTableManager get favoriteCountryTable =>
      $$FavoriteCountryTableTableTableManager(_db, _db.favoriteCountryTable);
  $$FavoriteLanguageTableTableTableManager get favoriteLanguageTable =>
      $$FavoriteLanguageTableTableTableManager(_db, _db.favoriteLanguageTable);
  $$AppSettingTableTableTableManager get appSettingTable =>
      $$AppSettingTableTableTableManager(_db, _db.appSettingTable);
  $$PodcastTableTableTableManager get podcastTable =>
      $$PodcastTableTableTableManager(_db, _db.podcastTable);
  $$PodcastUpdateTableTableTableManager get podcastUpdateTable =>
      $$PodcastUpdateTableTableTableManager(_db, _db.podcastUpdateTable);
  $$PodcastEpisodeTableTableTableManager get podcastEpisodeTable =>
      $$PodcastEpisodeTableTableTableManager(_db, _db.podcastEpisodeTable);
  $$DownloadedPodcastEpisodeTableTableTableManager
  get downloadedPodcastEpisodeTable =>
      $$DownloadedPodcastEpisodeTableTableTableManager(
        _db,
        _db.downloadedPodcastEpisodeTable,
      );
  $$DownloadTableTableTableManager get downloadTable =>
      $$DownloadTableTableTableManager(_db, _db.downloadTable);
}
