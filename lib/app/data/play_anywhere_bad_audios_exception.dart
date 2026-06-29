import 'play_anywhere_result.dart';

class PlayAnywhereBadAudiosException implements Exception {
  final PlayAnywhereResult result;

  PlayAnywhereBadAudiosException(this.result);

  @override
  String toString() =>
      'PlayAnywhereBadAudiosException: No audios found for pageId: ${result.param.pageId} and audioPageType: ${result.param.audioPageType}';
}
