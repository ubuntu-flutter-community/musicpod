import 'package:signals_flutter/signals_flutter.dart';

import '../../constants.dart';
import '../../utils.dart';

class AppStateService {
  Signal<bool> showWindowControls = signal(true);
  void setShowWindowControls(bool value) {
    if (value == showWindowControls.value) return;
    showWindowControls.value = value;
  }

  Signal<bool> fullScreen = signal(false);
  void setFullScreen(bool value) {
    if (value == fullScreen.value) return;
    fullScreen.value = value;
  }

  final Signal<int> localAudioIndex = signal(0);
  void setLocalAudioIndex(int value) {
    if (value == localAudioIndex.value) return;
    localAudioIndex.value = value;
  }

  Future<void> _initLocalAudioIndex() async {
    final localAudioIndexStringOrNull =
        await readSetting(kLocalAudioIndex, kAppStateFileName);
    if (localAudioIndexStringOrNull != null) {
      final localParse = int.tryParse(localAudioIndexStringOrNull);
      if (localParse != null) {
        localAudioIndex.value = localParse;
      }
    }
  }

  final Signal<int> radioIndex = signal(2); // Default to RadioSearch.country
  void setRadioIndex(int value) {
    if (value == radioIndex.value) return;
    radioIndex.value = value;
  }

  Future<void> _initRadioIndex() async {
    final radioIndexStringOrNull =
        await readSetting(kRadioIndex, kAppStateFileName);
    if (radioIndexStringOrNull != null) {
      final radioParse = int.tryParse(radioIndexStringOrNull);
      if (radioParse != null) {
        radioIndex.value = radioParse;
      }
    }
  }

  final Signal<int> podcastIndex = signal(0);
  void setPodcastIndex(int value) {
    if (value == podcastIndex.value) return;
    podcastIndex.value = value;
  }

  Future<void> _initPodcastIndex() async {
    final podcastIndexOrNull =
        await readSetting(kPodcastIndex, kAppStateFileName);
    podcastIndex.value =
        podcastIndexOrNull == null ? 0 : int.parse(podcastIndexOrNull);
  }

  final Signal<int> appIndex = signal(0);
  void setAppIndex(int value) {
    if (value == appIndex.value) return;
    appIndex.value = value;
  }

  Future<void> _initAppIndex() async {
    final appIndexOrNull = await readSetting(kAppIndex, kAppStateFileName);
    appIndex.value = appIndexOrNull == null ? 0 : int.parse(appIndexOrNull);
  }

  final Signal<String?> lastFav = signal(null);
  void setLastFav(String? value) {
    if (value == lastFav.value) return;
    writeSetting(kLastFav, value).then((_) => lastFav.value = value);
  }

  Future<void> _initLastFav() async {
    lastFav.value = (await readSetting(kLastFav, kAppStateFileName)) as String?;
  }

  final Signal<String?> lastCountryCode = signal(null);
  void setLastCountryCode(String? value) {
    if (value == lastCountryCode.value) return;
    writeSetting(kLastCountryCode, value)
        .then((_) => lastCountryCode.value = value);
  }

  Future<void> _initCountryCode() async {
    lastFav.value =
        (await readSetting(kLastCountryCode, kAppStateFileName)) as String?;
  }

  Future<void> init() async {
    await _initAppIndex();
    await _initLocalAudioIndex();
    await _initRadioIndex();
    await _initLastFav();
    await _initCountryCode();
    await _initPodcastIndex();
  }

  Future<void> dispose() async {
    await writeSetting(
      kLocalAudioIndex,
      localAudioIndex.value.toString(),
      kAppStateFileName,
    );
    await writeSetting(
      kRadioIndex,
      radioIndex.value.toString(),
      kAppStateFileName,
    );
    await writeSetting(
      kPodcastIndex,
      podcastIndex.value.toString(),
      kAppStateFileName,
    );
    await writeSetting(kAppIndex, appIndex.value.toString(), kAppStateFileName);
  }
}
