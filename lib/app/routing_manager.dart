import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../local_audio/service/local_audio_service.dart';
import '../podcasts/service/podcast_service.dart';
import '../radio/service/radio_service.dart';
import '../search/view/search_page.dart';
import '../settings/data/shared_preferences_keys.dart';
import '../settings/service/settings_service.dart';
import 'app_router.dart';
import 'page_ids.dart';

@lazySingleton
class RoutingManager {
  RoutingManager({
    required PodcastService podcastService,
    required LocalAudioService localAudioService,
    required RadioService radioService,
    required SettingsService settingsService,
  }) : _podcastService = podcastService,
       _localAudioService = localAudioService,
       _radioService = radioService,
       _settingsService = settingsService {
    selectedPageIdCommand.run();
  }

  final PodcastService _podcastService;
  final LocalAudioService _localAudioService;
  final RadioService _radioService;
  final SettingsService _settingsService;

  String? _topRouteName;

  late final GoRouter router = createAppRouter(
    initialLocation: locationForPageId(
      _settingsService.getString(SPKeys.selectedPage) ?? PageIDs.searchPage,
    ),
  );

  GlobalKey<NavigatorState> get masterNavigatorKey => shellNavigatorKey;

  String? get currentRouteName {
    if (_topRouteName != null) {
      return _topRouteName;
    }
    final uri = router.routeInformationProvider.value.uri;
    return pageIdForLocation(uri);
  }

  Future<bool> isPageInLibrary(String? pageId) async =>
      pageId != null &&
      (PageIDs.permanent.contains(pageId) ||
          (int.tryParse(pageId) != null &&
              await _localAudioService.isPinnedAlbum(int.parse(pageId))) ||
          await _radioService.isStarredStation(pageId) ||
          await _localAudioService.isPlaylistSaved(pageId) ||
          await _podcastService.isPodcastSubscribed(pageId));

  late final Command<String?, String> selectedPageIdCommand =
      Command.createAsync(
        (String? pageId) async {
          if (pageId != null) {
            await _settingsService.setValue(SPKeys.selectedPage, pageId);
          }

          return _settingsService.getString(SPKeys.selectedPage) ??
              PageIDs.searchPage;
        },
        initialValue:
            _settingsService.getString(SPKeys.selectedPage) ??
            PageIDs.searchPage,
      );

  Future<void> push({
    required String pageId,
    Widget Function(BuildContext context)? builder,
    bool maintainState = false,
    bool replace = false,
  }) async {
    if (pageId == currentRouteName) {
      return;
    }

    if (pageId == PageIDs.searchPage && currentRouteName != null) {
      final previousPageId = currentRouteName;
      final currentLoc = router.routeInformationProvider.value.uri.path;
      _topRouteName = pageId;
      selectedPageIdCommand(pageId);

      final materialPageRoute = PageRouteBuilder(
        maintainState: maintainState,
        settings: const RouteSettings(name: PageIDs.searchPage),
        pageBuilder: (context, __, ___) => const SearchPage(),
      );

      if (replace) {
        await shellNavigatorKey.currentState?.pushReplacement(
          materialPageRoute,
        );
      } else {
        await shellNavigatorKey.currentState?.push(materialPageRoute);
        if (router.routeInformationProvider.value.uri.path == currentLoc) {
          _topRouteName = previousPageId;
          if (previousPageId != null) {
            selectedPageIdCommand(previousPageId);
          }
        }
      }
      return;
    }

    final inLibrary = await isPageInLibrary(pageId);
    assert(inLibrary || builder != null);

    if (inLibrary) {
      _topRouteName = null;
      selectedPageIdCommand(pageId);
      router.go(locationForPageId(pageId));
    } else if (builder != null) {
      final previousPageId = currentRouteName;
      final currentLoc = router.routeInformationProvider.value.uri.path;
      _topRouteName = pageId;
      selectedPageIdCommand(pageId);

      final materialPageRoute = PageRouteBuilder(
        maintainState: maintainState,
        settings: RouteSettings(name: pageId),
        pageBuilder: (context, __, ___) => builder(context),
      );

      if (replace) {
        await shellNavigatorKey.currentState?.pushReplacement(
          materialPageRoute,
        );
      } else {
        await shellNavigatorKey.currentState?.push(materialPageRoute);
        if (router.routeInformationProvider.value.uri.path == currentLoc) {
          _topRouteName = previousPageId;
          if (previousPageId != null) {
            selectedPageIdCommand(previousPageId);
          }
        }
      }
    }
  }

  void pop() {
    if (shellNavigatorKey.currentState?.canPop() == true) {
      shellNavigatorKey.currentState?.maybePop();
    } else if (rootNavigatorKey.currentState?.canPop() == true) {
      rootNavigatorKey.currentState?.maybePop();
    }
  }

  bool get canPop =>
      (shellNavigatorKey.currentState?.canPop() == true) ||
      (rootNavigatorKey.currentState?.canPop() == true);
}
