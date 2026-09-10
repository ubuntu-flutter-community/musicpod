import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
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
  }) => Family.of(
    artist,
    () => FindTitlesOfArtistManager._(
      artist: artist,
      localAudioManager: localAudioManager,
    ),
    shouldDispose: (m) =>
        m.command.listenerCount == 0 && !m.useArtistGridView.hasListeners,
    onDispose: (m) {
      m.command.dispose();
      m.useArtistGridView.dispose();
    },
  );

  late final Command<void, List<Audio>?> command;

  final useArtistGridView = SafeValueNotifier<bool>(true);
  void setUseArtistGridView(bool value) {
    if (value == useArtistGridView.value) return;
    useArtistGridView.value = value;
  }
}
