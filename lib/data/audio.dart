import 'dart:convert';

class Audio {
  AudioType? audioType;
  String? resourcePath;
  String? resourceUrl;
  String? name;
  String? description;
  String? author;
  Audio({
    this.audioType,
    this.resourcePath,
    this.resourceUrl,
    this.name,
    this.description,
    this.author,
  });

  Audio copyWith({
    String? resourcePath,
    String? resourceUrl,
    String? name,
    String? description,
    String? author,
  }) {
    return Audio(
      resourcePath: resourcePath ?? this.resourcePath,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (resourcePath != null) {
      result.addAll({'resourcePath': resourcePath});
    }
    if (resourceUrl != null) {
      result.addAll({'resourceUrl': resourceUrl});
    }
    if (name != null) {
      result.addAll({'name': name});
    }
    if (description != null) {
      result.addAll({'description': description});
    }
    if (author != null) {
      result.addAll({'author': author});
    }

    return result;
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      resourcePath: map['resourcePath'],
      resourceUrl: map['resourceUrl'],
      name: map['name'],
      description: map['description'],
      author: map['author'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) => Audio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Audio(resourcePath: $resourcePath, resourceUrl: $resourceUrl, name: $name, description: $description, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio &&
        other.resourcePath == resourcePath &&
        other.resourceUrl == resourceUrl &&
        other.name == name &&
        other.description == description &&
        other.author == author;
  }

  @override
  int get hashCode {
    return resourcePath.hashCode ^
        resourceUrl.hashCode ^
        name.hashCode ^
        description.hashCode ^
        author.hashCode;
  }
}

enum AudioType {
  local,
  radio,
  podcast,
}
