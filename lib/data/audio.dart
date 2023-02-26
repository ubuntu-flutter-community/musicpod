import 'package:metadata_god/metadata_god.dart';

class Audio {
  final String? path;
  final String? url;
  final String? name;
  final Metadata? metadata;
  final AudioType? audioType;

  Audio({
    this.path,
    this.url,
    this.name,
    this.metadata,
    this.audioType,
  });

  Audio copyWith({
    String? path,
    String? url,
    String? name,
    Metadata? metadata,
    AudioType? audioType,
  }) {
    return Audio(
      path: path ?? this.path,
      url: url ?? this.url,
      name: name ?? this.name,
      metadata: metadata ?? this.metadata,
      audioType: audioType ?? this.audioType,
    );
  }

  @override
  String toString() {
    return 'Audio(path: $path, url: $url, name: $name, metadata: $metadata, audioType: $audioType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio &&
        other.path == path &&
        other.url == url &&
        other.name == name &&
        other.metadata == metadata &&
        other.audioType == audioType;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        url.hashCode ^
        name.hashCode ^
        metadata.hashCode ^
        audioType.hashCode;
  }
}

enum AudioType {
  local,
  radio,
  podcast,
}
