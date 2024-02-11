import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'settings_service.dart';

class SettingsModel extends SafeChangeNotifier {
  SettingsModel({
    required SettingsService service,
  }) : _service = service;

  final SettingsService _service;

  StreamSubscription<bool>? _usePodcastIndexChangedSub;
  StreamSubscription<bool>? _podcastIndexApiKeyChangedSub;
  StreamSubscription<bool>? _podcastIndexApiSecretChangedSub;
  StreamSubscription<bool>? _neverShowFailedImportsSub;
  StreamSubscription<bool>? _directoryChangedSub;

  String? get appName => _service.appName;
  String? get packageName => _service.packageName;
  String? get version => _service.version;
  String? get buildNumber => _service.buildNumber;
  String? get directory => _service.directory;
  Future<void> setDirectory(String? value) async {
    if (value != null) {
      await _service.setDirectory(value);
    }
  }

  bool get recentPatchNotesDisposed => _service.recentPatchNotesDisposed;
  Future<void> disposePatchNotes() async => await _service.disposePatchNotes();

  bool get neverShowFailedImports => _service.neverShowFailedImports;
  void setNeverShowFailedImports(bool value) =>
      _service.setNeverShowFailedImports(value);

  bool get usePodcastIndex => _service.usePodcastIndex;
  void setUsePodcastIndex(bool value) => _service.setUsePodcastIndex(value);

  void setThemeIndex(int value) => _service.setThemeIndex(value);

  String? get podcastIndexApiKey => _service.podcastIndexApiKey;
  void setPodcastIndexApiKey(String podcastIndexApiKey) =>
      _service.setPodcastIndexApiKey(podcastIndexApiKey);

  String? get podcastIndexApiSecret => _service.podcastIndexApiSecret;
  void setPodcastIndexApiSecret(String podcastIndexApiSecret) async =>
      _service.setPodcastIndexApiSecret(podcastIndexApiSecret);

  void init() async {
    _usePodcastIndexChangedSub =
        _service.usePodcastIndexChanged.listen((_) => notifyListeners());
    _podcastIndexApiKeyChangedSub =
        _service.podcastIndexApiKeyChanged.listen((_) => notifyListeners());
    _podcastIndexApiSecretChangedSub =
        _service.podcastIndexApiSecretChanged.listen((_) => notifyListeners());
    _neverShowFailedImportsSub =
        _service.neverShowFailedImportsChanged.listen((_) => notifyListeners());
    _directoryChangedSub =
        _service.directoryChanged.listen((_) => notifyListeners());
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _usePodcastIndexChangedSub?.cancel();
    await _podcastIndexApiKeyChangedSub?.cancel();
    await _podcastIndexApiSecretChangedSub?.cancel();
    await _neverShowFailedImportsSub?.cancel();
    await _directoryChangedSub?.cancel();
    super.dispose();
  }
}
