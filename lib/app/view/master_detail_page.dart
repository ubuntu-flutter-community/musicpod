import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/back_gesture.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../settings/view/settings_action.dart';
import 'master_items.dart';
import 'master_tile.dart';

class MasterDetailPage extends StatelessWidget with WatchItMixin {
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = watchIt<LibraryModel>();
    final masterItems = createMasterItems(libraryModel: libraryModel);

    final drawer = Drawer(
      width: kMasterDetailSideBarWidth,
      child: Stack(
        children: [
          MasterPanel(masterItems: masterItems),
          Positioned(
            left: Platform.isMacOS ? 5 : null,
            top: 5,
            right: Platform.isMacOS ? null : 5,
            child: IconButton(
              onPressed: Platform.isMacOS
                  ? masterScaffoldKey.currentState?.closeEndDrawer
                  : masterScaffoldKey.currentState?.closeDrawer,
              icon: Icon(
                Iconz.close,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: AppConfig.isMobilePlatform ? false : null,
      key: masterScaffoldKey,
      endDrawer: Platform.isMacOS ? drawer : null,
      drawer: Platform.isMacOS ? null : drawer,
      body: Row(
        children: [
          if (context.showMasterPanel)
            MasterPanel(
              masterItems: masterItems,
            ),
          if (context.showMasterPanel) const VerticalDivider(),
          Expanded(
            child: Navigator(
              initialRoute: libraryModel.selectedPageId ?? PageIDs.searchPage,
              onDidRemovePage: (page) {},
              key: libraryModel.masterNavigatorKey,
              observers: [libraryModel],
              onGenerateRoute: (settings) {
                final page = (masterItems.firstWhereOrNull(
                          (e) => e.pageId == settings.name,
                        ) ??
                        masterItems.elementAt(0))
                    .pageBuilder(context);

                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => BackGesture(child: page),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MasterPanel extends StatelessWidget {
  const MasterPanel({
    super.key,
    required this.masterItems,
  });

  final List<MasterItem> masterItems;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    return SizedBox(
      width: kMasterDetailSideBarWidth,
      child: Column(
        children: [
          const HeaderBar(
            includeBackButton: false,
            includeSidebarButton: false,
            backgroundColor: Colors.transparent,
            style: YaruTitleBarStyle.undecorated,
            adaptive: false,
            title: Text(AppConfig.appTitle),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: masterItems.length,
              itemBuilder: (context, index) {
                final item = masterItems.elementAt(index);
                return MasterTile(
                  key: ValueKey(item.pageId),
                  onTap: () {
                    libraryModel.push(pageId: item.pageId);

                    if (!context.showMasterPanel) {
                      if (Platform.isMacOS) {
                        masterScaffoldKey.currentState?.closeEndDrawer();
                      } else {
                        masterScaffoldKey.currentState?.closeDrawer();
                      }
                    }
                  },
                  pageId: item.pageId,
                  leading: item.iconBuilder
                      ?.call(libraryModel.selectedPageId == item.pageId),
                  title: item.titleBuilder(context),
                  subtitle: item.subtitleBuilder?.call(context),
                  selected: libraryModel.selectedPageId == item.pageId,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(
                height: 5,
              ),
            ),
          ),
          const SettingsButton.tile(),
        ],
      ),
    );
  }
}
