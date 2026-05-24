import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../player/view/player_view.dart';
import '../app_manager.dart';
import 'common_handlers_and_commands.dart';
import 'master_detail_page.dart';

class DesktopHomePage extends StatelessWidget
    with WatchItMixin, CommonHandlersAndCommandsMixin {
  const DesktopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isInFullWindowMode = watchValue((AppManager m) => m.fullWindowMode);

    setupCommonHandlersAndCommands(context);

    // This scaffold is mainly used to have a unified place for snackbars
    return Scaffold(
      body: Stack(
        children: [
          const MasterDetailPage(),
          if (isInFullWindowMode) const PlayerView.fullWindow(),
        ],
      ),
      bottomNavigationBar: const PlayerView.bottom(),
    );
  }
}
