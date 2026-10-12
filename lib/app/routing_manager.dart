import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../dependencies.dart';
import '../settings/data/shared_preferences_keys.dart';
import '../settings/service/settings_service.dart';
import 'app_router.dart';
import 'page_ids.dart';

part 'routing_manager.g.dart';

@Riverpod(keepAlive: true)
class RoutingManager extends _$RoutingManager implements NavigatorObserver {
  SettingsService get _settingsService => di<SettingsService>();

  String? _topRouteName;

  late final GoRouter router = createAppRouter(
    initialLocation: locationForPageId(state),
    observers: [this],
  );

  GlobalKey<NavigatorState> get masterNavigatorKey => shellNavigatorKey;

  @override
  NavigatorState? get navigator => null;

  String? get currentRouteName {
    if (_topRouteName != null) {
      return _topRouteName;
    }
    final uri = router.routeInformationProvider.value.uri;
    return pageIdForLocation(uri);
  }

  bool _isTopRoute(String? name) => name != null && !name.startsWith('/');

  @override
  String build() {
    return _settingsService.getString(SPKeys.selectedPage) ?? PageIDs.searchPage;
  }

  String get selectedPageId => state;

  Future<void> setSelectedPageId(String? pageId) async {
    if (pageId != null) {
      await _settingsService.setValue(SPKeys.selectedPage, pageId);
      state = pageId;
    } else {
      state = _settingsService.getString(SPKeys.selectedPage) ?? PageIDs.searchPage;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isTopRoute(route.settings.name)) {
      _topRouteName = route.settings.name;
      unawaited(setSelectedPageId(_topRouteName));
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final prevName = previousRoute?.settings.name;
    if (_isTopRoute(prevName)) {
      _topRouteName = prevName;
      unawaited(setSelectedPageId(_topRouteName));
    } else {
      _topRouteName = null;
      final basePageId = pageIdForLocation(
        router.routeInformationProvider.value.uri,
      );
      unawaited(setSelectedPageId(basePageId));
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newName = newRoute?.settings.name;
    if (_isTopRoute(newName)) {
      _topRouteName = newName;
      unawaited(setSelectedPageId(_topRouteName));
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == _topRouteName) {
      final prevName = previousRoute?.settings.name;
      if (_isTopRoute(prevName)) {
        _topRouteName = prevName;
        unawaited(setSelectedPageId(_topRouteName));
      } else {
        _topRouteName = null;
        final basePageId = pageIdForLocation(
          router.routeInformationProvider.value.uri,
        );
        unawaited(setSelectedPageId(basePageId));
      }
    }
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {}

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didStopUserGesture() {}

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
      unawaited(setSelectedPageId(PageIDs.searchPage));

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


    if (shellNavigatorKey.currentState?.canPop() == true) {
      shellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    _topRouteName = null;
    unawaited(setSelectedPageId(pageId));
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
