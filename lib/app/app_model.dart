import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:github/github.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../app_config.dart';
import '../common/view/snackbars.dart';
import '../expose/expose_service.dart';
import '../extensions/taget_platform_x.dart';
import '../settings/settings_service.dart';
import 'view/discord_connect_content.dart';

class AppModel extends SafeChangeNotifier {
  AppModel({
    required PackageInfo packageInfo,
    required SettingsService settingsService,
    required GitHub gitHub,
    required bool allowManualUpdates,
    required ExposeService exposeService,
  })  : _countryCode = WidgetsBinding
            .instance.platformDispatcher.locale.countryCode
            ?.toLowerCase(),
        _gitHub = gitHub,
        _allowManualUpdates = allowManualUpdates,
        _settingsService = settingsService,
        _packageInfo = packageInfo,
        _exposeService = exposeService;

  final ExposeService _exposeService;
  Stream<String?> get errorStream => _exposeService.discordErrorStream;
  Stream<bool> get isDiscordConnectedStream =>
      _exposeService.isDiscordConnectedStream;
  Future<void> connectToDiscord(bool value) async =>
      _exposeService.connectToDiscord(value);
  bool get isDiscordConnected => _exposeService.isDiscordConnected;

  ValueNotifier<bool> get isLastFmAuthorized =>
      _exposeService.isLastFmAuthorized;
  Future<void> authorizeLastFm({
    required String apiKey,
    required String apiSecret,
  }) async =>
      _exposeService.authorizeLastFm(
        apiKey: apiKey,
        apiSecret: apiSecret,
      );

  void initListenBrains() => _exposeService.initListenBrains();

  final GitHub _gitHub;
  final SettingsService _settingsService;
  final bool _allowManualUpdates;
  bool get allowManualUpdate => _allowManualUpdates;

  final String? _countryCode;
  String? get countryCode => _countryCode;

  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }

  bool _showQueueOverlay = false;
  bool get showQueueOverlay => _showQueueOverlay;
  void setOrToggleQueueOverlay({bool? value}) {
    _showQueueOverlay = value ?? !_showQueueOverlay;
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
        await SystemChrome.setPreferredOrientations(
          [],
        );
      }
    }

    notifyListeners();
  }

  final PackageInfo _packageInfo;
  String get version => _packageInfo.version;

  Future<void> disposePatchNotes() async =>
      _settingsService.disposePatchNotes(version);

  bool recentPatchNotesDisposed() =>
      _settingsService.recentPatchNotesDisposed(version);
  bool? _updateAvailable;
  bool? get updateAvailable => _updateAvailable;
  String? _onlineVersion;
  String? get onlineVersion => _onlineVersion;
  Future<void> checkForUpdate({
    required bool isOnline,
    Function(String error)? onError,
  }) async {
    _updateAvailable == null;
    notifyListeners();

    if (!_allowManualUpdates || !isOnline) {
      _updateAvailable = false;
      notifyListeners();
      return Future.value();
    }
    _onlineVersion = await getOnlineVersion().onError(
      (error, stackTrace) {
        onError?.call(error.toString());
        return null;
      },
    );
    final onlineVersion = getExtendedVersionNumber(_onlineVersion) ?? 0;
    final currentVersion = getExtendedVersionNumber(version) ?? 0;
    if (onlineVersion > currentVersion) {
      _updateAvailable = true;
    } else {
      _updateAvailable = false;
    }
    notifyListeners();
    await fetchNumberOfDownloads();
  }

  int? _downloads;
  int? get downloads => _downloads;
  void setDownloads(int? value) {
    _downloads = value;
    notifyListeners();
  }

  Future<void> fetchNumberOfDownloads() async {
    if (_latestRelease != null) {
      final assets = await _gitHub.repositories
          .listReleaseAssets(
            RepositorySlug.full(AppConfig.gitHubShortLink),
            _latestRelease!,
          )
          .toList();
      setDownloads(
        assets.fold<int>(
          0,
          (previousValue, element) =>
              previousValue + (element.downloadCount ?? 0),
        ),
      );
    }
  }

  bool get wasBackupSaved => _settingsService.getBackupSaved(version);
  Future<void> setBackupSaved(bool value) async {
    await _settingsService.setBackupSaved(version, value);
    notifyListeners();
  }

  bool get isBackupScreenNeeded =>
      isCurrentVersionLowerThan(_settingsService.forcedUpdateThreshold);

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
        .listContributors(
          RepositorySlug.full(AppConfig.gitHubShortLink),
        )
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

void discordConnectedHandler(
  BuildContext context,
  AsyncSnapshot<bool?> snapshot,
  void Function() cancel,
) {
  if (snapshot.data == true) {
    showSnackBar(
      context: context,
      duration: const Duration(seconds: 3),
      content: DiscordConnectContent(connected: snapshot.data == true),
    );
  }
}
