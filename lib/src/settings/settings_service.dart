import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants.dart';
import '../../patch_notes.dart';
import '../../utils.dart';

class SettingsService {
  String? _appName;
  String? get appName => _appName;
  String? _packageName;
  String? get packageName => _packageName;
  String? _version;
  String? get version => _version;
  String? _buildNumber;
  String? get buildNumber => _buildNumber;

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;
    _packageName = packageInfo.packageName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
  }

  final _themeIndexController = StreamController<bool>.broadcast();
  Stream<bool> get themeIndexChanged => _themeIndexController.stream;
  int _themeIndex = 0;
  int get themeIndex => _themeIndex;
  void setThemeIndex(int value) {
    if (value == _themeIndex) return;
    writeSetting(kThemeIndex, value.toString()).then((_) {
      _themeIndex = value;
      _themeIndexController.add(true);
    });
  }

  Future<void> _initThemeIndex() async {
    final themeIndexStringOrNull = await readSetting(kThemeIndex);
    if (themeIndexStringOrNull != null) {
      final themeParse = int.tryParse(themeIndexStringOrNull);
      if (themeParse != null) {
        _themeIndex = themeParse;
      }
    }
  }

  bool _neverShowFailedImports = false;
  bool get neverShowFailedImports => _neverShowFailedImports;
  final _neverShowFailedImportsController = StreamController<bool>.broadcast();
  Stream<bool> get neverShowFailedImportsChanged =>
      _neverShowFailedImportsController.stream;
  void setNeverShowFailedImports(bool value) {
    writeSetting(
      kNeverShowImportFails,
      value.toString(),
    ).then((_) {
      _neverShowFailedImports = value;
      _neverShowFailedImportsController.add(true);
    });
  }

  Future<void> _initNeverShowImports() async {
    final neverShowImportsOrNull = await readSetting(kNeverShowImportFails);
    _neverShowFailedImports = neverShowImportsOrNull == null
        ? false
        : bool.parse(neverShowImportsOrNull);
  }

  final _recentPatchNotesDisposedController =
      StreamController<bool>.broadcast();
  Stream<bool> get recentPatchNotesDisposedChanged =>
      _recentPatchNotesDisposedController.stream;
  bool _recentPatchNotesDisposed = false;
  bool get recentPatchNotesDisposed => _recentPatchNotesDisposed;
  Future<void> disposePatchNotes() async {
    await writeSetting(kPatchNotesDisposed, kRecentPatchNotesDisposed)
        .then((_) {
      _recentPatchNotesDisposed = true;
      _recentPatchNotesDisposedController.add(true);
    });
  }

  Future<void> _initRecentPatchNotesDisposed() async {
    String? value = await readSetting(kPatchNotesDisposed);
    if (value == kRecentPatchNotesDisposed) {
      _recentPatchNotesDisposed = true;
    }
  }

  final _usePodcastIndexController = StreamController<bool>.broadcast();
  Stream<bool> get usePodcastIndexChanged => _usePodcastIndexController.stream;
  bool _usePodcastIndex = false;
  bool get usePodcastIndex => _usePodcastIndex;
  void setUsePodcastIndex(bool value) {
    writeSetting(kUsePodcastIndex, value.toString()).then((_) {
      _usePodcastIndex = value;
      _usePodcastIndexController.add(true);
    });
  }

  Future<void> _initUsePodcastIndex() async {
    final usePodcastIndexOrNull = await readSetting(kUsePodcastIndex);
    _usePodcastIndex = usePodcastIndexOrNull == null
        ? false
        : bool.parse(usePodcastIndexOrNull);
  }

  final _podcastIndexApiKeyController = StreamController<bool>.broadcast();
  Stream<bool> get podcastIndexApiKeyChanged =>
      _podcastIndexApiKeyController.stream;
  String? _podcastIndexApiKey;
  String? get podcastIndexApiKey => _podcastIndexApiKey;
  void setPodcastIndexApiKey(String value) {
    writeSetting(kPodcastIndexApiKey, value).then((_) {
      _podcastIndexApiKey = value;
      _podcastIndexApiKeyController.add(true);
    });
  }

  Future<void> _initPodcastIndexApiKey() async {
    String? value = await readSetting(kPodcastIndexApiKey);
    if (value != null) {
      _podcastIndexApiKey = value;
    }
  }

  final _podcastIndexApiSecretController = StreamController<bool>.broadcast();
  Stream<bool> get podcastIndexApiSecretChanged =>
      _podcastIndexApiSecretController.stream;
  String? _podcastIndexApiSecret;
  String? get podcastIndexApiSecret => _podcastIndexApiSecret;
  void setPodcastIndexApiSecret(String value) {
    writeSetting(kPodcastIndexApiSecret, value).then((_) {
      _podcastIndexApiSecret = value;
      _podcastIndexApiSecretController.add(true);
    });
  }

  Future<void> _initPodcastIndexApiSecret() async {
    String? value = await readSetting(kPodcastIndexApiSecret);
    if (value != null) {
      _podcastIndexApiSecret = value;
    }
  }

  final _directoryController = StreamController<bool>.broadcast();
  Stream<bool> get directoryChanged => _directoryController.stream;
  String? _directory;
  String? get directory => _directory;
  Future<void> setDirectory(String directory) async {
    await writeSetting(kDirectoryProperty, directory).then((_) {
      _directory = directory;
      _directoryController.add(true);
    });
  }

  Future<void> _initDirectory(String? testDir) async {
    String? value = testDir;
    value ??= await readSetting(kDirectoryProperty);
    value ??= await getMusicDir();
    if (value != null) {
      _directory = value;
    }
  }

  Future<void> init({@visibleForTesting String? testDir}) async {
    await _initPackageInfo();
    await _initSettings(testDir);
  }

  Future<void> _initSettings(String? testDir) async {
    await _initThemeIndex();
    await _initDirectory(testDir);
    await _initUsePodcastIndex();
    await _initPodcastIndexApiKey();
    await _initPodcastIndexApiSecret();
    await _initRecentPatchNotesDisposed();
    await _initNeverShowImports();
  }

  Future<void> dispose() async {
    await _themeIndexController.close();
    await _recentPatchNotesDisposedController.close();
    await _neverShowFailedImportsController.close();
    await _directoryController.close();
    await _podcastIndexApiSecretController.close();
    await _usePodcastIndexController.close();
    await _podcastIndexApiKeyController.close();
  }
}
