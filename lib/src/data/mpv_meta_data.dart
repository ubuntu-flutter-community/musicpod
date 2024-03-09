import 'dart:convert';

class MpvMetaData {
  final String icyBr;
  final String icyGenre;
  final String icyName;
  final String icyUrl;
  final String icyAudioInfo;
  final String icyPub;
  final String icyDescription;
  final String icyTitle;
  MpvMetaData({
    required this.icyBr,
    required this.icyGenre,
    required this.icyName,
    required this.icyUrl,
    required this.icyAudioInfo,
    required this.icyPub,
    required this.icyDescription,
    required this.icyTitle,
  });

  MpvMetaData copyWith({
    String? icyBr,
    String? icyGenre,
    String? icyName,
    String? icyUrl,
    String? icyAudioInfo,
    String? icyPub,
    String? icyDescription,
    String? icyTitle,
  }) {
    return MpvMetaData(
      icyBr: icyBr ?? this.icyBr,
      icyGenre: icyGenre ?? this.icyGenre,
      icyName: icyName ?? this.icyName,
      icyUrl: icyUrl ?? this.icyUrl,
      icyAudioInfo: icyAudioInfo ?? this.icyAudioInfo,
      icyPub: icyPub ?? this.icyPub,
      icyDescription: icyDescription ?? this.icyDescription,
      icyTitle: icyTitle ?? this.icyTitle,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'icy-br': icyBr});
    result.addAll({'icy-genre': icyGenre});
    result.addAll({'icy-name': icyName});
    result.addAll({'icy-url': icyUrl});
    result.addAll({'icy-audio-info': icyAudioInfo});
    result.addAll({'icy-pub': icyPub});
    result.addAll({'icy-description': icyDescription});
    result.addAll({'icy-title': icyTitle});

    return result;
  }

  factory MpvMetaData.fromMap(Map<String, dynamic> map) {
    return MpvMetaData(
      icyBr: map['icy-br'] ?? '',
      icyGenre: map['icy-genre'] ?? '',
      icyName: map['icy-name'] ?? '',
      icyUrl: map['icy-url'] ?? '',
      icyAudioInfo: map['icy-audio-info'] ?? '',
      icyPub: map['icy-pub'] ?? '',
      icyDescription: map['icy-description'] ?? '',
      icyTitle: map['icy-title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MpvMetaData.fromJson(String source) =>
      MpvMetaData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MpvMetaData(icyBr: $icyBr, icyGenre: $icyGenre, icyName: $icyName, icyUrl: $icyUrl, icyAudioInfo: $icyAudioInfo, icyPub: $icyPub, icyDescription: $icyDescription, icyTitle: $icyTitle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MpvMetaData &&
        other.icyBr == icyBr &&
        other.icyGenre == icyGenre &&
        other.icyName == icyName &&
        other.icyUrl == icyUrl &&
        other.icyAudioInfo == icyAudioInfo &&
        other.icyPub == icyPub &&
        other.icyDescription == icyDescription &&
        other.icyTitle == icyTitle;
  }

  @override
  int get hashCode {
    return icyBr.hashCode ^
        icyGenre.hashCode ^
        icyName.hashCode ^
        icyUrl.hashCode ^
        icyAudioInfo.hashCode ^
        icyPub.hashCode ^
        icyDescription.hashCode ^
        icyTitle.hashCode;
  }
}
