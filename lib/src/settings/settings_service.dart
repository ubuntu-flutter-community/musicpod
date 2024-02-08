import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../constants.dart';
import '../../globals.dart';
import '../../patch_notes.dart';
import '../../utils.dart';

class SettingsService {
  final Signal<String?> appName = signal(null);
  final Signal<String?> packageName = signal(null);
  final Signal<String?> version = signal(null);
  final Signal<String?> buildNumber = signal(null);

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName.value = packageInfo.appName;
    packageName.value = packageInfo.packageName;
    version.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
  }

  final Signal<int> _themeIndex = signal(0);
  void setThemeIndex(int value) {
    if (value == _themeIndex.value) return;
    writeSetting(kThemeIndex, _themeIndex.value.toString())
        .then((_) => _themeIndex.value = value);
  }

  Future<void> _initThemeIndex() async {
    final themeIndexStringOrNull = await readSetting(kThemeIndex);
    if (themeIndexStringOrNull != null) {
      final themeParse = int.tryParse(themeIndexStringOrNull);
      if (themeParse != null) {
        _themeIndex.value = themeParse;
        themeNotifier.value = ThemeMode.values[_themeIndex.value];
      }
    }
  }

  final Signal<bool> neverShowFailedImports = signal(false);
  void setNeverShowFailedImports(bool value) {
    if (value == neverShowFailedImports.value) return;
    writeSetting(
      kNeverShowImportFails,
      value.toString(),
    ).then((_) => neverShowFailedImports.value = value);
  }

  Future<void> _initNeverShowImports() async {
    final neverShowImportsOrNull = await readSetting(kNeverShowImportFails);
    neverShowFailedImports.value = neverShowImportsOrNull == null
        ? false
        : bool.parse(neverShowImportsOrNull);
  }

  final Signal<bool> recentPatchNotesDisposed = signal(false);
  Future<void> disposePatchNotes() async {
    await writeSetting(kPatchNotesDisposed, kRecentPatchNotesDisposed)
        .then((_) => recentPatchNotesDisposed.value = true);
  }

  Future<void> _initRecentPatchNotesDisposed() async {
    String? value = await readSetting(kPatchNotesDisposed);
    if (value == kRecentPatchNotesDisposed) {
      recentPatchNotesDisposed.value = true;
    }
  }

  final Signal<bool> usePodcastIndex = signal(false);
  void setUsePodcastIndex(bool value) {
    if (value == usePodcastIndex.value) return;
    writeSetting(kUsePodcastIndex, value ? 'true' : 'false').then((_) {
      usePodcastIndex.value = value;
    });
  }

  Future<void> _initUsePodcastIndex() async {
    String? value = await readSetting(kUsePodcastIndex);
    if (value != null) {
      usePodcastIndex.value = bool.tryParse(value) ?? false;
    }
  }

  final Signal<String?> podcastIndexApiKey = signal(null);
  void setPodcastIndexApiKey(String value) {
    if (podcastIndexApiKey.value == value) return;
    writeSetting(kPodcastIndexApiKey, value).then((_) {
      podcastIndexApiKey.value = value;
    });
  }

  Future<void> _initPodcastIndexApiKey() async {
    String? value = await readSetting(kPodcastIndexApiKey);
    if (value != null) {
      podcastIndexApiKey.value = value;
    }
  }

  final Signal<String?> podcastIndexApiSecret = signal(null);
  void setPodcastIndexApiSecret(String value) {
    if (value == podcastIndexApiSecret.value) return;
    writeSetting(kPodcastIndexApiSecret, value).then((_) {
      podcastIndexApiSecret.value = value;
    });
  }

  Future<void> _readPodcastIndexApiSecret() async {
    String? value = await readSetting(kPodcastIndexApiSecret);
    if (value != null) {
      podcastIndexApiSecret.value = value;
    }
  }

  Future<void> init() async {
    await _initPackageInfo();
    await _initSettings();
  }

  Future<void> _initSettings() async {
    await _initUsePodcastIndex();
    await _initPodcastIndexApiKey();
    await _readPodcastIndexApiSecret();
    await _initRecentPatchNotesDisposed();
    await _initNeverShowImports();
    await _initThemeIndex();
  }
}
