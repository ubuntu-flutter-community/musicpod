import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/logging.dart';
import '../../extensions/taget_platform_x.dart';
import '../../library/library_service.dart';
import 'mobile_page.dart';

class RoutingManager extends SafeChangeNotifier implements NavigatorObserver {
  RoutingManager({
    required LibraryService libraryService,
  }) : _libraryService = libraryService {
    _propertiesChangedSub ??=
        _libraryService.propertiesChanged.listen((_) => notifyListeners());
  }

  final LibraryService _libraryService;
  StreamSubscription<bool>? _propertiesChangedSub;

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  bool isPageInLibrary(String? pageId) =>
      _libraryService.isPageInLibrary(pageId);

  String? get selectedPageId => _libraryService.selectedPageId;
  void _setSelectedPageId(String pageId) =>
      _libraryService.setSelectedPageId(pageId);

  Future<void> push({
    required String pageId,
    Widget Function(BuildContext context)? builder,
    bool maintainState = false,
    bool replace = false,
  }) async {
    final inLibrary = isPageInLibrary(pageId);
    assert(inLibrary || builder != null);
    if (inLibrary) {
      if (replace) {
        await _masterNavigatorKey.currentState?.pushReplacementNamed(pageId);
      } else {
        await _masterNavigatorKey.currentState?.pushNamed(pageId);
      }
    } else if (builder != null) {
      final materialPageRoute = MaterialPageRoute(
        maintainState: maintainState,
        settings: RouteSettings(
          name: pageId,
        ),
        builder: (context) =>
            isMobile ? MobilePage(page: builder(context)) : builder(context),
      );

      if (replace) {
        await _masterNavigatorKey.currentState?.pushReplacement(
          materialPageRoute,
        );
      } else {
        await _masterNavigatorKey.currentState?.push(
          materialPageRoute,
        );
      }
    }
  }

  void pop() => _masterNavigatorKey.currentState?.maybePop();

  bool get canPop => _masterNavigatorKey.currentState?.canPop() == true;

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
