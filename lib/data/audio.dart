import 'package:metadata_god/metadata_god.dart';

class Audio {
  final String? path;
  final String? url;
  final String? name;
  final Metadata? metadata;
  final AudioType? audioType;
  final String? imageUrl;
  final String? description;
  final String? website;

  Audio({
    this.path,
    this.url,
    this.name,
    this.metadata,
    this.audioType,
    this.imageUrl,
    this.description,
    this.website,
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
    String? stringFromMetadata;
    if (metadata != null) {
      stringFromMetadata =
          '${metadata!.artist?.isNotEmpty == true ? metadata!.artist : ''}${metadata!.title?.isNotEmpty == true ? metadata!.title : ''}${metadata!.album?.isNotEmpty == true ? metadata!.album : ''}';
    }

    return stringFromMetadata?.isNotEmpty == true
        ? stringFromMetadata!
        : path ??
            url ??
            'Audio(path: $path, url: $url, name: $name, metadata: $metadata, audioType: $audioType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is Audio &&
        other.audioType == AudioType.local &&
        other.path != null &&
        other.path == path) {
      return true;
    }

    if (other is Audio &&
        other.audioType == AudioType.radio &&
        audioType == AudioType.radio &&
        url != null &&
        other.url != null &&
        other.url == url) {
      return true;
    }

    if (other is Audio &&
        other.audioType == AudioType.podcast &&
        audioType == AudioType.podcast &&
        url != null &&
        other.url != null &&
        other.url == url) {
      return true;
    }

    return false;
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
