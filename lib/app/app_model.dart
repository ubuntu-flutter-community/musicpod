import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:github/github.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../app_config.dart';
import '../expose/expose_service.dart';
import '../extensions/taget_platform_x.dart';
import '../library/library_service.dart';
import '../local_audio/local_audio_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';

@lazySingleton
class AppModel extends SafeChangeNotifier {
  AppModel({
    required PackageInfo packageInfo,
    required SettingsService settingsService,
    required GitHub gitHub,
    required ExposeService exposeService,
    required LocalAudioService localAudioService,
    required LibraryService libraryService,
    required InternetConnection internetConnection,
  }) : _countryCode = WidgetsBinding
           .instance
           .platformDispatcher
           .locale
           .countryCode
           ?.toLowerCase(),
       _gitHub = gitHub,
       _settingsService = settingsService,
       _packageInfo = packageInfo,
       _exposeService = exposeService,
       _localAudioService = localAudioService,
       _libraryService = libraryService,
       _internetConnection = internetConnection;

  final ExposeService _exposeService;
  final LocalAudioService _localAudioService;
  final LibraryService _libraryService;
  final InternetConnection _internetConnection;
  final GitHub _gitHub;
  final SettingsService _settingsService;

  ValueNotifier<bool> get isLastFmAuthorized =>
      _exposeService.isLastFmAuthorized;
  Future<void> authorizeLastFm({
    required String apiKey,
    required String apiSecret,
  }) async =>
      _exposeService.authorizeLastFm(apiKey: apiKey, apiSecret: apiSecret);

  void initListenBrains() => _exposeService.initListenBrains();

  final bool _allowManualUpdates = !isLinux;
  bool get allowManualUpdate => _allowManualUpdates;

  final String? _countryCode;
  String? get countryCode => _countryCode;

  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }

  bool? _fullWindowMode;
  bool? get fullWindowMode => _fullWindowMode;
  Future<void> setFullWindowMode(bool? value) async {
    if (value == null || value == _fullWindowMode) return;
    _fullWindowMode = value;

    if (isMobile) {
      if (_fullWindowMode == true) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        await SystemChrome.setPreferredOrientations([]);
      }
    }

    notifyListeners();
  }

  final PackageInfo _packageInfo;
  String get version => _packageInfo.version;

  String? _onlineVersion;
  String? get onlineVersion => _onlineVersion;

  late final Command<void, bool> checkForUpdateCommand =
      Command.createAsyncNoParam(_checkForUpdate, initialValue: false);

  Future<bool> _checkForUpdate() async {
    var _updateAvailable = false;

    if (await _internetConnection.internetStatus != InternetStatus.connected) {
      return _updateAvailable;
    }

    _onlineVersion = await getOnlineVersion();
    final onlineVersion = getExtendedVersionNumber(_onlineVersion) ?? 0;
    final currentVersion = getExtendedVersionNumber(version) ?? 0;
    if (onlineVersion > currentVersion) {
      _updateAvailable = _allowManualUpdates && true;
    } else {
      _updateAvailable = false;
    }
    return _updateAvailable;
  }

  late final Command<void, int> fetchNumberOfDownloadsCommand =
      Command.createAsyncNoParam(fetchNumberOfDownloads, initialValue: 0);
  Future<int> fetchNumberOfDownloads() async {
    if (_latestRelease != null) {
      final assets = await _gitHub.repositories
          .listReleaseAssets(
            RepositorySlug.full(AppConfig.gitHubShortLink),
            _latestRelease!,
          )
          .toList();

      return assets.fold<int>(
        0,
        (previousValue, element) =>
            previousValue + (element.downloadCount ?? 0),
      );
    }

    return 0;
  }

  Future<void> disposePatchNotes() async {
    await _settingsService.setValue(SPKeys.patchNotesDisposed, version);
    recentPatchNotesDisposedCommand.run();
  }

  late final Command<void, bool?> recentPatchNotesDisposedCommand =
      Command.createSyncNoParam(recentPatchNotesDisposed, initialValue: null);

  bool recentPatchNotesDisposed() =>
      _settingsService.getString(SPKeys.patchNotesDisposed) == version;

  late final Command<void, bool?> backupNeededCommand =
      Command.createAsyncNoParam(() async {
        final needed =
            (_localAudioService.audios?.isNotEmpty ?? false) &&
            _libraryService.playlistIDs.isNotEmpty &&
            _libraryService.favoriteAlbums.isNotEmpty &&
            isCurrentVersionLowerThan(
              const String.fromEnvironment(
                'FORCED_UPDATE_THRESHOLD',
                defaultValue: '2.11.0',
              ),
            ) &&
            !wasBackupSaved;
        return needed;
      }, initialValue: null);

  bool get wasBackupSaved =>
      _settingsService.getBool(SPKeys.backupSaved + version) ?? false;

  Future<void> setBackupSaved(bool value) async {
    await _settingsService.setValue(SPKeys.backupSaved + version, value);
    notifyListeners();
  }

  bool isCurrentVersionLowerThan(String otherVersion) {
    final currentVersionInt = getExtendedVersionNumber(version) ?? 0;
    final otherVersionInt = getExtendedVersionNumber(otherVersion) ?? 0;
    return currentVersionInt < otherVersionInt;
  }

  bool _localAudioBackup = false;
  bool get localAudioBackup => _localAudioBackup;
  void setLocalAudioBackup(bool value) {
    _localAudioBackup = value;
    notifyListeners();
  }

  bool _podcastBackup = false;
  bool get podcastBackup => _podcastBackup;
  void setPodcastBackup(bool value) {
    _podcastBackup = value;
    notifyListeners();
  }

  bool _radioBackup = false;
  bool get radioBackup => _radioBackup;
  void setRadioBackup(bool value) {
    _radioBackup = value;
    notifyListeners();
  }

  void resetBackupSettings() {
    _localAudioBackup = false;
    _podcastBackup = false;
    _radioBackup = false;
    notifyListeners();
  }

  int? getExtendedVersionNumber(String? version) {
    if (version == null) return null;
    version = version.replaceAll('v', '');
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  Release? _latestRelease;
  Future<String?> getOnlineVersion() async {
    final release = await _gitHub.repositories
        .listReleases(RepositorySlug.full(AppConfig.gitHubShortLink))
        .toList();
    _latestRelease = release.firstOrNull;
    return _latestRelease?.tagName;
  }

  Future<List<Contributor>> getContributors() async {
    final list = await _gitHub.repositories
        .listContributors(RepositorySlug.full(AppConfig.gitHubShortLink))
        .where((c) => c.type == 'User')
        .toList();
    return [
      ...list,
      Contributor(
        login: 'ubuntujaggers',
        htmlUrl: 'https://github.com/ubuntujaggers',
        avatarUrl: 'https://avatars.githubusercontent.com/u/38893390?v=4',
      ),
    ];
  }
}
