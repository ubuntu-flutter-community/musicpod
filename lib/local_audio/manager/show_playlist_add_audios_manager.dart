import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'show_playlist_add_audios_manager.g.dart';

@riverpod
class ShowPlaylistAddAudiosManager extends _$ShowPlaylistAddAudiosManager {
  @override
  bool build(String playlistId) => false;

  void toggle() => state = !state;

  void set(bool value) => state = value;
}
