import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:github/github.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:yaru/theme.dart';

import '../constants.dart';
import '../expose/expose_service.dart';
import '../settings/settings_service.dart';

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
  Future<void> connectToDiscord() async => _exposeService.connectToDiscord();
  Future<void> disconnectFromDiscord() async =>
      _exposeService.disconnectFromDiscord();

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
  }

  int? getExtendedVersionNumber(String? version) {
    if (version == null) return null;
    version = version.replaceAll('v', '');
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  Future<String?> getOnlineVersion() async {
    final release = await _gitHub.repositories
        .listReleases(RepositorySlug.full(kGitHubShortLink))
        .toList();
    return release.firstOrNull?.tagName;
  }

  Future<List<Contributor>> getContributors() async {
    final list = await _gitHub.repositories
        .listContributors(
          RepositorySlug.full(kGitHubShortLink),
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
