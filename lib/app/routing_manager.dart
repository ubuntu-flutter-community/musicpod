import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/logging.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'page_ids.dart';
import '../extensions/taget_platform_x.dart';
import '../local_audio/local_audio_service.dart';
import '../podcasts/podcast_service.dart';
import '../radio/radio_service.dart';
import 'view/mobile_page.dart';

@lazySingleton
class RoutingManager extends SafeChangeNotifier implements NavigatorObserver {
  RoutingManager({
    required PodcastService podcastService,
    required LocalAudioService localAudioService,
    required RadioService radioService,
    required SettingsService settingsService,
  }) : _podcastService = podcastService,
       _localAudioService = localAudioService,
       _radioService = radioService,
       _settingsService = settingsService {
    _podcastPropertiesChangedSub ??= _podcastService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
    _localAudioPropertiesChangedSub ??= _localAudioService.propertiesChanged
        .listen((_) => notifyListeners());
    _radioPropertiesChangedSub ??= _radioService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
    _settingsChangedChangedSub ??= _settingsService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final PodcastService _podcastService;
  final LocalAudioService _localAudioService;
  final RadioService _radioService;
  final SettingsService _settingsService;
  StreamSubscription<bool>? _podcastPropertiesChangedSub;
  StreamSubscription<bool>? _localAudioPropertiesChangedSub;
  StreamSubscription<bool>? _radioPropertiesChangedSub;
  StreamSubscription<bool>? _settingsChangedChangedSub;

  @disposeMethod
  @override
  Future<void> dispose() async {
    await _podcastPropertiesChangedSub?.cancel();
    await _localAudioPropertiesChangedSub?.cancel();
    await _radioPropertiesChangedSub?.cancel();
    await _settingsChangedChangedSub?.cancel();
    super.dispose();
  }

  bool isPageInLibrary(String? pageId) =>
      pageId != null &&
      (PageIDs.permanent.contains(pageId) ||
          (int.tryParse(pageId) != null &&
              _localAudioService.isPinnedAlbum(int.parse(pageId))) ||
          _radioService.isStarredStation(pageId) ||
          _localAudioService.isPlaylistSaved(pageId) ||
          _podcastService.isPodcastSubscribed(pageId));

  String? get selectedPageId => _settingsService.getString(SPKeys.selectedPage);
  void _setSelectedPageId(String pageId) =>
      _settingsService.setValue(SPKeys.selectedPage, pageId);

  Future<void> push({
    required String pageId,
    Widget Function(BuildContext context)? builder,
    bool maintainState = false,
    bool replace = false,
  }) async {
    final inLibrary = isPageInLibrary(pageId);
    assert(inLibrary || builder != null);
    if (selectedPageId == pageId && !replace) {
      return;
    }
    if (inLibrary) {
      if (replace || PageIDs.replacers.contains(pageId)) {
        await _masterNavigatorKey.currentState?.pushReplacementNamed(pageId);
      } else {
        await _masterNavigatorKey.currentState?.pushNamed(pageId);
      }
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

  void pop() {
    if (!PageIDs.replacers.contains(selectedPageId)) {
      _masterNavigatorKey.currentState?.maybePop();
    } else {
      _masterNavigatorKey.currentState?.popUntil(
        (route) => route.settings.name == selectedPageId,
      );
    }
  }

  bool get canPop => PageIDs.replacers.contains(selectedPageId)
      ? false
      : _masterNavigatorKey.currentState?.canPop() == true;

  @override
  void didPop(Route route, Route? previousRoute) {
    final pageId = previousRoute?.settings.name;

    printMessageInDebugMode(
      'didPop: ${route.settings.name}, previousPageId: ${previousRoute?.settings.name}',
    );
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final pageId = route.settings.name;
    printMessageInDebugMode(
      'didPush: $pageId, previousPageId: ${previousRoute?.settings.name}',
    );
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final pageId = route.settings.name;
    printMessageInDebugMode(
      'didRemove: $pageId, previousPageId: ${previousRoute?.settings.name}',
    );
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    printMessageInDebugMode(
      'didReplace: ${oldRoute?.settings.name}, newPageId: ${newRoute?.settings.name}',
    );
    final pageId = newRoute?.settings.name;
    if (pageId == null) return;
    _setSelectedPageId(pageId);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    printMessageInDebugMode(
      'didStartUserGesture: ${route.settings.name}, previousPageId: ${previousRoute?.settings.name}',
    );
  }

  @override
  void didStopUserGesture() {
    printMessageInDebugMode('didStopUserGesture');
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    printMessageInDebugMode('didChangeTop');
  }

  // Note: Navigator.initState ensures assert(observer.navigator == null);
  // Afterwards the Navigator itself!!! sets the navigator of its observers...
  @override
  NavigatorState? get navigator => null;
  final GlobalKey<NavigatorState> _masterNavigatorKey =
      GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get masterNavigatorKey => _masterNavigatorKey;
}
