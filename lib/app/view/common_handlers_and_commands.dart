import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../app_manager.dart';

mixin CommonHandlersAndCommandsMixin {
  void setupCommonHandlersAndCommands(BuildContext context) {
    callOnceAfterThisBuild((context) {
      final appManager = di<AppManager>();
      appManager.backupNeededCommand.run();
      appManager.recentPatchNotesDisposedCommand.run();
    });

    registerHandler(
      select: (AppManager m) => m.recentPatchNotesDisposedCommand,
      handler: (context, newValue, cancel) {
        if (newValue == false) {
          context.dialog((context) => const PatchNotesDialog());
        }
      },
    );

    registerHandler(
      select: (AppManager m) => m.backupNeededCommand,
      handler: (context, newValue, cancel) {
        if (newValue == true) {
          context.dialog(
            (context) => const BackupDialog(),
            barrierDismissible: false,
          );
        }
      },
    );
  }
}
