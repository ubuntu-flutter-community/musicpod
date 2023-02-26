import 'dart:convert';

class Audio {
  AudioType? audioType;
  String? path;
  String? url;
  String? name;
  Audio({
    this.audioType,
    this.path,
    this.url,
    this.name,
  });

  Audio copyWith({
    String? path,
    String? url,
    String? name,
  }) {
    return Audio(
      path: path ?? this.path,
      url: url ?? this.url,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (path != null) {
      result.addAll({'path': path});
    }
    if (url != null) {
      result.addAll({'url': url});
    }
    if (name != null) {
      result.addAll({'name': name});
    }

    return result;
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      path: map['path'],
      url: map['url'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) => Audio.fromMap(json.decode(source));

  @override
  String toString() => 'Audio(path: $path, url: $url, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio &&
        other.path == path &&
        other.url == url &&
        other.name == name;
  }

  @override
  int get hashCode => path.hashCode ^ url.hashCode ^ name.hashCode;
}

enum AudioType {
  local,
  radio,
  podcast,
}
