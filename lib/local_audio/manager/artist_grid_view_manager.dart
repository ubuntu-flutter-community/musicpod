import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'artist_grid_view_manager.g.dart';

@riverpod
class ArtistGridViewManager extends _$ArtistGridViewManager {
  @override
  bool build(String artist) => true;

  void setUseArtistGridView(bool value) => state = value;
}
