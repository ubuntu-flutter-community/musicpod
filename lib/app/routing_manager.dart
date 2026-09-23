import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../local_audio/service/local_audio_service.dart';
import '../podcasts/service/podcast_service.dart';
import '../radio/service/radio_service.dart';
import '../settings/data/shared_preferences_keys.dart';
import '../settings/service/settings_service.dart';
import 'app_router.dart';
import 'page_ids.dart';

@lazySingleton
class RoutingManager extends NavigatorObserver {
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

  // Note: Navigator.initState ensures assert(observer.navigator == null);
  // Afterwards the Navigator itself!!! sets the navigator of its observers...
  @override
  NavigatorState? get navigator => null;

  final PodcastService _podcastService;
  final LocalAudioService _localAudioService;
  final RadioService _radioService;
  final SettingsService _settingsService;

  String? _topRouteName;

  late final GoRouter router = createAppRouter(
    initialLocation: locationForPageId(
      _settingsService.getString(SPKeys.selectedPage) ?? PageIDs.searchPage,
    ),
    observers: [this],
  );

  GlobalKey<NavigatorState> get masterNavigatorKey => shellNavigatorKey;

  String? get currentRouteName {
    if (_topRouteName != null) {
      return _topRouteName;
    }
    final uri = router.routeInformationProvider.value.uri;
    return pageIdForLocation(uri);
  }

  bool _isTopRoute(String? name) => name != null && !name.startsWith('/');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isTopRoute(route.settings.name)) {
      _topRouteName = route.settings.name;
      selectedPageIdCommand(_topRouteName);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final prevName = previousRoute?.settings.name;
    if (_isTopRoute(prevName)) {
      _topRouteName = prevName;
      selectedPageIdCommand(_topRouteName);
    } else {
      _topRouteName = null;
      final basePageId = pageIdForLocation(
        router.routeInformationProvider.value.uri,
      );
      selectedPageIdCommand(basePageId);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newName = newRoute?.settings.name;
    if (_isTopRoute(newName)) {
      _topRouteName = newName;
      selectedPageIdCommand(_topRouteName);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == _topRouteName) {
      final prevName = previousRoute?.settings.name;
      if (_isTopRoute(prevName)) {
        _topRouteName = prevName;
        selectedPageIdCommand(_topRouteName);
      } else {
        _topRouteName = null;
        final basePageId = pageIdForLocation(
          router.routeInformationProvider.value.uri,
        );
        selectedPageIdCommand(basePageId);
      }
    }
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

    if (pageId == PageIDs.searchPage) {
      if (shellNavigatorKey.currentState?.canPop() == true) {
        shellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }

      _topRouteName = null;
      selectedPageIdCommand(PageIDs.searchPage);

      final isAtSearchRoot =
          router.routeInformationProvider.value.uri.path ==
          locationForPageId(PageIDs.searchPage);

      if (!isAtSearchRoot) {
        router.go(locationForPageId(PageIDs.searchPage));
      }
      return;
    }

    if (builder != null) {
      final materialPageRoute = PageRouteBuilder(
        maintainState: maintainState,
        settings: RouteSettings(name: pageId),
        pageBuilder: (context, __, ___) => builder(context),
      );

      if (replace) {
        unawaited(
          shellNavigatorKey.currentState?.pushReplacement(materialPageRoute),
        );
      } else {
        unawaited(shellNavigatorKey.currentState?.push(materialPageRoute));
      }
      return;
    }

    final inLibrary = await isPageInLibrary(pageId);
    assert(inLibrary);

    if (shellNavigatorKey.currentState?.canPop() == true) {
      shellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    _topRouteName = null;
    selectedPageIdCommand(pageId);
    router.go(locationForPageId(pageId));
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
