import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../settings/service/settings_service.dart';
import '../settings/data/shared_preferences_keys.dart';
import 'page_ids.dart';
import '../extensions/platform_x.dart';
import '../local_audio/service/local_audio_service.dart';
import '../podcasts/service/podcast_service.dart';
import '../radio/service/radio_service.dart';
import 'view/mobile_page.dart';

@lazySingleton
class RoutingManager extends SafeChangeNotifier {
  RoutingManager({
    required PodcastService podcastService,
    required LocalAudioService localAudioService,
    required RadioService radioService,
    required SettingsService settingsService,
  }) : _podcastService = podcastService,
       _localAudioService = localAudioService,
       _radioService = radioService,
       _settingsService = settingsService;

  final PodcastService _podcastService;
  final LocalAudioService _localAudioService;
  final RadioService _radioService;
  final SettingsService _settingsService;

  Future<bool> isPageInLibrary(String? pageId) async =>
      pageId != null &&
      (PageIDs.permanent.contains(pageId) ||
          (int.tryParse(pageId) != null &&
              await _localAudioService.isPinnedAlbum(int.parse(pageId))) ||
          await _radioService.isStarredStation(pageId) ||
          await _localAudioService.isPlaylistSaved(pageId) ||
          await _podcastService.isPodcastSubscribed(pageId));

  String _selectedPageId = PageIDs.searchPage;
  String get selectedPageId => _selectedPageId;
  void _setSelectedPageId(String pageId) => _settingsService
      .setValue(SPKeys.selectedPage, pageId, throwOnError: false)
      .then((saved) {
        if (saved) {
          _selectedPageId = pageId;
          notifyListeners();
        }
      });

  Future<void> push({
    required String pageId,
    Widget Function(BuildContext context)? builder,
    bool maintainState = false,
    bool replace = false,
  }) async {
    final inLibrary = await isPageInLibrary(pageId);
    assert(inLibrary || builder != null);

    _setSelectedPageId(pageId);

    if (inLibrary) {
      await _masterNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        pageId,
        (route) => false,
      );
    } else if (builder != null) {
      final materialPageRoute = PageRouteBuilder(
        maintainState: maintainState,
        settings: RouteSettings(name: pageId),
        pageBuilder: (context, __, ___) =>
            isMobile ? MobilePage(page: builder(context)) : builder(context),
      );

      if (replace) {
        await _masterNavigatorKey.currentState?.pushReplacement(
          materialPageRoute,
        );
      } else {
        await _masterNavigatorKey.currentState?.push(materialPageRoute);
      }
    }
  }

  void pop() => _masterNavigatorKey.currentState?.maybePop();

  bool get canPop => _masterNavigatorKey.currentState?.canPop() == true;

  final GlobalKey<NavigatorState> _masterNavigatorKey =
      GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get masterNavigatorKey => _masterNavigatorKey;
}
