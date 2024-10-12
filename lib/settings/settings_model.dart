import 'dart:async';

import 'package:github/github.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../external_path/external_path_service.dart';
import '../common/data/close_btn_action.dart';
import 'settings_service.dart';

class SettingsModel extends SafeChangeNotifier {
  SettingsModel({
    required SettingsService service,
    required ExternalPathService externalPathService,
    required GitHub gitHub,
  })  : _service = service,
        _externalPathService = externalPathService;

  final SettingsService _service;
  final ExternalPathService _externalPathService;

  StreamSubscription<bool>? _propertiesChangedSub;

  String? get directory => _service.directory;
  Future<void> setDirectory(String value) async => _service.setDirectory(value);

  bool get neverShowFailedImports => _service.neverShowFailedImports;
  void setNeverShowFailedImports(bool value) =>
      _service.setNeverShowFailedImports(value);

  bool get enableDiscordRPC => _service.enableDiscordRPC;
  void setEnableDiscordRPC(bool value) => _service.setEnableDiscordRPC(value);

  bool get usePodcastIndex => _service.usePodcastIndex;
  Future<void> setUsePodcastIndex(bool value) async =>
      _service.setUsePodcastIndex(value);

  int get themeIndex => _service.themeIndex;
  void setThemeIndex(int value) => _service.setThemeIndex(value);

  String? get podcastIndexApiKey => _service.podcastIndexApiKey;
  void setPodcastIndexApiKey(String value) =>
      _service.setPodcastIndexApiKey(value);

  String? get podcastIndexApiSecret => _service.podcastIndexApiSecret;
  void setPodcastIndexApiSecret(String value) async =>
      _service.setPodcastIndexApiSecret(value);

  Future<String?> getPathOfDirectory() async =>
      _externalPathService.getPathOfDirectory();

  CloseBtnAction get closeBtnActionIndex => _service.closeBtnActionIndex;
  void setCloseBtnActionIndex(CloseBtnAction value) =>
      _service.setCloseBtnActionIndex(value);

  void init() => _propertiesChangedSub ??=
      _service.propertiesChanged.listen((_) => notifyListeners());

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
