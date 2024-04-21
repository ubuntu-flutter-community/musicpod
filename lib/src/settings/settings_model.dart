import 'dart:async';

import 'package:github/github.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../constants.dart';
import '../../external_path.dart';
import 'settings_service.dart';

class SettingsModel extends SafeChangeNotifier {
  SettingsModel({
    required SettingsService service,
    required ExternalPathService externalPathService,
    required GitHub gitHub,
  })  : _service = service,
        _externalPathService = externalPathService,
        _gitHub = gitHub;

  final SettingsService _service;
  final ExternalPathService _externalPathService;
  final GitHub _gitHub;

  StreamSubscription<bool>? _usePodcastIndexChangedSub;
  StreamSubscription<bool>? _podcastIndexApiKeyChangedSub;
  StreamSubscription<bool>? _podcastIndexApiSecretChangedSub;
  StreamSubscription<bool>? _neverShowFailedImportsSub;
  StreamSubscription<bool>? _directoryChangedSub;
  StreamSubscription<bool>? _themeIndexChangedSub;
  StreamSubscription<bool>? _recentPatchNotesDisposedChangedSub;
  StreamSubscription<bool>? _useArtistGridViewChangedSub;

  bool get allowManualUpdate => _service.allowManualUpdates;
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
  Future<void> setUsePodcastIndex(bool value) async =>
      await _service.setUsePodcastIndex(value);

  int get themeIndex => _service.themeIndex;
  void setThemeIndex(int value) => _service.setThemeIndex(value);

  String? get podcastIndexApiKey => _service.podcastIndexApiKey;
  void setPodcastIndexApiKey(String value) =>
      _service.setPodcastIndexApiKey(value);

  String? get podcastIndexApiSecret => _service.podcastIndexApiSecret;
  void setPodcastIndexApiSecret(String value) async =>
      _service.setPodcastIndexApiSecret(value);

  void playOpenedFile() => _externalPathService.playOpenedFile();

  Future<String?> getPathOfDirectory() async =>
      await _externalPathService.getPathOfDirectory();

  bool get useArtistGridView => _service.useArtistGridView;
  void setUseArtistGridView(bool value) => _service.setUseArtistGridView(value);

  void init() {
    _themeIndexChangedSub ??=
        _service.themeIndexChanged.listen((_) => notifyListeners());
    _usePodcastIndexChangedSub ??=
        _service.usePodcastIndexChanged.listen((_) => notifyListeners());
    _podcastIndexApiKeyChangedSub ??=
        _service.podcastIndexApiKeyChanged.listen((_) => notifyListeners());
    _podcastIndexApiSecretChangedSub ??=
        _service.podcastIndexApiSecretChanged.listen((_) => notifyListeners());
    _neverShowFailedImportsSub ??=
        _service.neverShowFailedImportsChanged.listen((_) => notifyListeners());
    _directoryChangedSub ??=
        _service.directoryChanged.listen((_) => notifyListeners());
    _useArtistGridViewChangedSub ??=
        _service.useArtistGridViewChanged.listen((_) => notifyListeners());
    _recentPatchNotesDisposedChangedSub ??= _service
        .recentPatchNotesDisposedChanged
        .listen((_) => notifyListeners());
  }

  @override
  Future<void> dispose() async {
    await _themeIndexChangedSub?.cancel();
    await _usePodcastIndexChangedSub?.cancel();
    await _podcastIndexApiKeyChangedSub?.cancel();
    await _podcastIndexApiSecretChangedSub?.cancel();
    await _neverShowFailedImportsSub?.cancel();
    await _directoryChangedSub?.cancel();
    await _recentPatchNotesDisposedChangedSub?.cancel();
    await _useArtistGridViewChangedSub?.cancel();
    super.dispose();
  }

  Future<String?> getOnlineVersion() async {
    final release = await (_gitHub.repositories
            .listReleases(RepositorySlug.full(kGitHubShortLink)))
        .toList();
    return release.firstOrNull?.tagName;
  }

  Future<List<Contributor>> getContributors() async {
    return (await _gitHub.repositories
        .listContributors(
          RepositorySlug.full(kGitHubShortLink),
        )
        .where((c) => c.type == 'User')
        .toList());
  }

  bool? _updateAvailable;
  bool? get updateAvailable => _updateAvailable;
  String? _onlineVersion;
  String? get onlineVersion => _onlineVersion;
  Future<void> checkForUpdate() async {
    _updateAvailable == null;
    notifyListeners();

    _onlineVersion = await getOnlineVersion();
    final onlineVersion = getExtendedVersionNumber(_onlineVersion) ?? 0;
    final currentVersion = getExtendedVersionNumber(version) ?? 0;
    if (onlineVersion > currentVersion) {
      _updateAvailable = true;
    } else {
      _updateAvailable = false;
    }
    notifyListeners();
  }

  int? getExtendedVersionNumber(String? version) {
    if (version == null) return null;
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }
}
