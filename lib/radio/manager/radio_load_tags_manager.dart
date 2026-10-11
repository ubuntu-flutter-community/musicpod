import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'radio_manager.dart';

part 'radio_load_tags_manager.g.dart';

@Riverpod(keepAlive: true)
class RadioLoadTagsManager extends _$RadioLoadTagsManager {
  @override
  Future<List<Tag>> build() async {
    await ref.watch(radioManagerProvider.future);
    return ref.watch(radioManagerProvider.notifier).loadTags();
  }
}
