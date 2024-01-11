import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../library.dart';
import '../../settings.dart';
import '../../theme.dart';
import '../globals.dart';
import 'master_item.dart';

class MasterDetailPage extends StatelessWidget {
  const MasterDetailPage({
    super.key,
    required this.setIndex,
    required this.index,
    required this.masterItems,
    required this.libraryModel,
  });

  final void Function(int? value) setIndex;
  final int? index;
  final List<MasterItem> masterItems;
  final LibraryModel libraryModel;

  @override
  Widget build(BuildContext context) {
    return YaruMasterDetailTheme(
      data: YaruMasterDetailTheme.of(context).copyWith(
        sideBarColor: getSideBarColor(context.t),
      ),
      child: YaruMasterDetailPage(
        navigatorKey: navigatorKey,
        onSelected: (value) => setIndex(value ?? 0),
        appBar: const HeaderBar(
          style: YaruTitleBarStyle.undecorated,
          title: Text('MusicPod'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: SettingsTile(),
            ),
          ],
        ),
        layoutDelegate: const YaruMasterFixedPaneDelegate(
          paneWidth: 250,
        ),
        breakpoint: 720,
        controller: YaruPageController(
          length: masterItems.length,
          initialIndex: index ?? 0,
        ),
        tileBuilder: (context, index, selected, availableWidth) {
          final item = masterItems[index];

          return MasterTile(
            pageId: item.pageId,
            libraryModel: libraryModel,
            selected: selected,
            title: item.titleBuilder(context),
            subtitle: item.subtitleBuilder?.call(context),
            leading: item.iconBuilder?.call(
              context,
              selected,
            ),
          );
        },
        pageBuilder: (context, index) => YaruDetailPage(
          body: masterItems[index].pageBuilder(context),
        ),
      ),
    );
  }
}
