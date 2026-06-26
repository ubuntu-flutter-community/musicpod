import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/util/keep_alive_registry.dart';
import '../../common/view/audio_filter.dart';
import 'local_audio_manager.dart';

@injectable
class FindTitlesOfArtistManager {
  FindTitlesOfArtistManager._({
    required String artist,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findTitlesOfArtist(artist, AudioFilter.album),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindTitlesOfArtistManager create({
    @factoryParam required String artist,
    required LocalAudioManager localAudioManager,
  }) => _registry.getOrRegister(
    id: artist,
    factoryFunction: () => FindTitlesOfArtistManager._(
      artist: artist,
      localAudioManager: localAudioManager,
    ),
  );

  static final _registry =
      KeepAliveRegistry<String, FindTitlesOfArtistManager>();
  static void dispose(String artist) => _registry.dispose(artist);
  late final Command<void, List<Audio>?> command;

  final useArtistGridView = SafeValueNotifier<bool>(true);
  void setUseArtistGridView(bool value) {
    if (value == useArtistGridView.value) return;
    useArtistGridView.value = value;
  }
}
