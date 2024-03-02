import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../settings.dart';
import '../../theme.dart';
import '../globals.dart';
import 'master_items.dart';

class MasterDetailPage extends ConsumerWidget {
  const MasterDetailPage({
    super.key,
    required this.countryCode,
  });

  final String? countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Connectivity
    final isOnline =
        ref.watch(appModelProvider.select((value) => value.isOnline));

    // Library
    final libraryModel = ref.watch(libraryModelProvider);

    final localAudioModel = ref.read(localAudioModelProvider);

    final masterItems = createMasterItems(
      libraryModel: libraryModel,
      isOnline: isOnline,
      countryCode: countryCode,
    );

    return YaruMasterDetailTheme(
      data: YaruMasterDetailTheme.of(context).copyWith(
        sideBarColor: getSideBarColor(context.t),
      ),
      child: YaruMasterDetailPage(
        navigatorKey: navigatorKey,
        onSelected: (value) => libraryModel.setIndex(value ?? 0),
        appBar: HeaderBar(
          style: YaruTitleBarStyle.undecorated,
          title: const Text('MusicPod'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SettingsButton(
                initLocalAudio: localAudioModel.init,
              ),
            ),
          ],
        ),
        layoutDelegate: const YaruMasterFixedPaneDelegate(
          paneWidth: 250,
        ),
        breakpoint: kMasterDetailBreakPoint,
        controller: YaruPageController(
          length: libraryModel.totalListAmount,
          initialIndex: libraryModel.index ?? 0,
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
