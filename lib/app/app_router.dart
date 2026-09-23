import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_ids.dart';
import 'view/master_detail_shell.dart';
import 'view/master_item_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigatorKey',
);
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellNavigatorKey',
);

String locationForPageId(String pageId) => switch (pageId) {
  PageIDs.searchPage => '/search',
  PageIDs.localAudio => '/localAudio',
  PageIDs.radio => '/radio',
  PageIDs.podcasts => '/podcasts',
  PageIDs.likedAudios => '/likedAudios',
  PageIDs.settings => '/settings',
  PageIDs.customContent => '/customContent',
  _ => '/page?id=${Uri.encodeQueryComponent(pageId)}',
};

String pageIdForLocation(Uri uri) => switch (uri.path) {
  '/search' => PageIDs.searchPage,
  '/localAudio' => PageIDs.localAudio,
  '/radio' => PageIDs.radio,
  '/podcasts' => PageIDs.podcasts,
  '/likedAudios' => PageIDs.likedAudios,
  '/settings' => PageIDs.settings,
  '/customContent' => PageIDs.customContent,
  '/page' => uri.queryParameters['id'] ?? PageIDs.searchPage,
  _ => uri.queryParameters['id'] ?? PageIDs.searchPage,
};

GoRouter createAppRouter({
  required String initialLocation,
  List<NavigatorObserver>? observers,
}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation,
  observers: observers,
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      observers: observers,
      builder: (context, state, child) => MasterDetailShell(child: child),
      routes: [
        GoRoute(path: '/', redirect: (_, __) => initialLocation),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.searchPage),
            child: MasterItemPage(pageId: PageIDs.searchPage),
          ),
        ),
        GoRoute(
          path: '/localAudio',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.localAudio),
            child: MasterItemPage(pageId: PageIDs.localAudio),
          ),
        ),
        GoRoute(
          path: '/radio',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.radio),
            child: MasterItemPage(pageId: PageIDs.radio),
          ),
        ),
        GoRoute(
          path: '/podcasts',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.podcasts),
            child: MasterItemPage(pageId: PageIDs.podcasts),
          ),
        ),
        GoRoute(
          path: '/likedAudios',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.likedAudios),
            child: MasterItemPage(pageId: PageIDs.likedAudios),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.settings),
            child: MasterItemPage(pageId: PageIDs.settings),
          ),
        ),
        GoRoute(
          path: '/customContent',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey(PageIDs.customContent),
            child: MasterItemPage(pageId: PageIDs.customContent),
          ),
        ),
        GoRoute(
          path: '/page',
          pageBuilder: (context, state) {
            final pageId =
                state.uri.queryParameters['id'] ?? PageIDs.searchPage;
            return NoTransitionPage(
              key: ValueKey(pageId),
              child: MasterItemPage(pageId: pageId),
            );
          },
        ),
      ],
    ),
  ],
);
