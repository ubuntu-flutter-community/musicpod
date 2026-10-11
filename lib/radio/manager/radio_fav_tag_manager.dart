import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/radio_service.dart';

part 'radio_fav_tag_manager.g.dart';

@Riverpod(keepAlive: true)
class RadioFavTagManager extends _$RadioFavTagManager {
  @override
  Future<Set<String>> build() => di<RadioService>().getFavRadioTags();

  Future<void> toggleFavRadioTag(String? tag) async {
    if (tag != null) {
      await di<RadioService>().toggleFavRadioTag(tag);
    }
    state = AsyncData(await di<RadioService>().getFavRadioTags());
  }
}
