import 'package:musicpod/app/radio/stations.dart';
import 'package:musicpod/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class RadioModel extends SafeChangeNotifier {
  Set<Audio>? _stations;
  Set<Audio>? get stations => _stations;
  set stations(Set<Audio>? value) {
    if (value == null) return;
    _stations = value;
    notifyListeners();
  }

  Future<void> init() async {
    _stations = Set.from(
      stationsMap.entries
          .map(
            (e) => Audio(
              name: e.key,
              url: e.value,
              title: e.key,
              artist: e.key,
              album: e.key,
              audioType: AudioType.radio,
            ),
          )
          .toList(),
    );
  }
}
