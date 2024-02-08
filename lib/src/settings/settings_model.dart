import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../library.dart';

class SettingsModel extends SafeChangeNotifier {
  final LibraryService _libraryService;

  String? _appName;
  StreamSubscription<bool>? _usePodcastIndexChangedSub;
  StreamSubscription<bool>? _podcastIndexApiKeyChangedSub;
  StreamSubscription<bool>? _podcastIndexApiSecretChangedSub;

  SettingsModel({
    required LibraryService libraryService,
  }) : _libraryService = libraryService;

  String? get appName => _appName;
  set appName(String? value) {
    if (value == null || value == _appName) return;
    _appName = value;
    notifyListeners();
  }

  String? _packageName;
  String? get packageName => _packageName;
  set packageName(String? value) {
    if (value == null || value == _packageName) return;
    _packageName = value;
    notifyListeners();
  }

  String? _version;
  String? get version => _version;
  set version(String? value) {
    if (value == null || value == _version) return;
    _version = value;
    notifyListeners();
  }

  String? _buildNumber;
  String? get buildNumber => _buildNumber;
  set buildNumber(String? value) {
    if (value == null || value == _buildNumber) return;
    _buildNumber = value;
    notifyListeners();
  }

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    _usePodcastIndexChangedSub =
        _libraryService.usePodcastIndexChanged.listen((_) => notifyListeners());
    _podcastIndexApiKeyChangedSub = _libraryService.podcastIndexApiKeyChanged
        .listen((_) => notifyListeners());
    _podcastIndexApiSecretChangedSub = _libraryService
        .podcastIndexApiSecretChanged
        .listen((_) => notifyListeners());

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    _usePodcastIndexChangedSub?.cancel();
    _podcastIndexApiKeyChangedSub?.cancel();
    _podcastIndexApiSecretChangedSub?.cancel();
    super.dispose();
  }

  bool get usePodcastIndex => _libraryService.usePodcastIndex;
  void setUsePodcastIndex(bool value) =>
      _libraryService.setUsePodcastIndex(value);

  void setThemeIndex(int value) => _libraryService.setThemeIndex(value);

  String? get podcastIndexApiKey => _libraryService.podcastIndexApiKey;
  Future<void> setPodcastIndexApiKey(String podcastIndexApiKey) async =>
      await _libraryService.setPodcastIndexApiKey(podcastIndexApiKey);

  String? get podcastIndexApiSecret => _libraryService.podcastIndexApiSecret;
  Future<void> setPodcastIndexApiSecret(String podcastIndexApiSecret) async =>
      await _libraryService.setPodcastIndexApiSecret(podcastIndexApiSecret);
}
