import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';

import '../../common/logging.dart';
import '../../extensions/platform_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/service/settings_service.dart';

/// Service responsible for managing macOS App Sandbox security-scoped bookmarks.
///
/// Under macOS App Sandbox, directory permissions granted by NSOpenPanel are
/// temporary and expire as soon as the app process terminates.
///
/// This service:
/// 1. Mints security-scoped bookmarks and saves them in [SettingsService] when
///    the user selects a folder (e.g. music library, custom downloads).
/// 2. Restores access to all saved directories on app startup before any
///    file reads or audio streaming occur.
@lazySingleton
class SecureBookmarkService {
  final SettingsService _settingsService;
  final SecureBookmarks _secureBookmarks = SecureBookmarks();

  SecureBookmarkService({required SettingsService settingsService})
    : _settingsService = settingsService;

  static const _kLocalAudioBookmarkId = 'musicpod_local_audio';
  static const _kDownloadsBookmarkId = 'musicpod_downloads';

  /// Restores access to all persisted security-scoped bookmarks on macOS.
  Future<bool> restoreAllSavedBookmarks() async {
    if (!isMacOS || isTest) return true;

    await _restoreBookmark(
      id: _kLocalAudioBookmarkId,
      spKey: SPKeys.directoryBookmark,
    );
    await _restoreBookmark(
      id: _kDownloadsBookmarkId,
      spKey: SPKeys.downloadsBookmark,
    );
    return true;
  }

  /// Creates and saves a security-scoped bookmark for [path] under [spKey].
  Future<void> saveBookmarkFor({
    required String spKey,
    required String path,
  }) async {
    if (!isMacOS || isTest) return;

    try {
      final mint = await _secureBookmarks.mint(Directory(path));
      await _settingsService.setValue(spKey, base64Encode(mint.bookmark));
      Logger.i(
        'Saved macOS security-scoped bookmark for $path under $spKey',
        tag: '$SecureBookmarkService',
      );
    } catch (e, s) {
      Logger.e(
        'Failed to save security-scoped bookmark for $path: $e',
        trace: s,
        tag: '$SecureBookmarkService',
      );
    }
  }

  /// Releases a security-scoped bookmark scope on macOS.
  Future<void> releaseBookmark(String id) async {
    if (!isMacOS || isTest) return;
    try {
      await _secureBookmarks.release(id);
    } catch (e, s) {
      Logger.e(
        'Failed to release security-scoped bookmark for $id: $e',
        trace: s,
        tag: '$SecureBookmarkService',
      );
    }
  }

  Future<String?> _restoreBookmark({
    required String id,
    required String spKey,
  }) async {
    final bookmark = _settingsService.getString(spKey);
    if (bookmark == null || bookmark.isEmpty) return null;

    try {
      final bytes = base64Decode(bookmark);
      final resolution = await _secureBookmarks
          .resolve(id: id, bookmarkBytes: bytes)
          .timeout(const Duration(seconds: 3));

      Logger.i(
        'Restored macOS security-scoped access for $id: ${resolution.path}',
        tag: '$SecureBookmarkService',
      );

      // If the bookmark became stale (e.g. directory moved/renamed), persist the refreshed bytes.
      if (resolution.stale && resolution.refreshedBookmark != null) {
        await _settingsService.setValue(
          spKey,
          base64Encode(resolution.refreshedBookmark!),
        );
      }
      return resolution.path;
    } catch (e, s) {
      Logger.e(
        'Failed to restore security-scoped bookmark for $id: $e',
        trace: s,
        tag: '$SecureBookmarkService',
      );
      return null;
    }
  }
}
