import '../../common/view/audio_page_type.dart';

class PlayAnywhereParam {
  final AudioPageType audioPageType;
  final String pageId;

  const PlayAnywhereParam({required this.audioPageType, required this.pageId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayAnywhereParam &&
          runtimeType == other.runtimeType &&
          audioPageType == other.audioPageType &&
          pageId == other.pageId;

  @override
  int get hashCode => audioPageType.hashCode ^ pageId.hashCode;
}
