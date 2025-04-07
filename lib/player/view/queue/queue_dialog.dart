import 'package:flutter/material.dart';

import '../../../common/view/ui_constants.dart';
import '../player_main_controls.dart';
import 'queue_body.dart';

class QueueDialog extends StatelessWidget {
  const QueueDialog({super.key});

  @override
  Widget build(BuildContext context) => const AlertDialog(
        titlePadding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: kLargestSpace,
          bottom: 10,
        ),
        contentPadding: EdgeInsets.only(bottom: kLargestSpace, top: 10),
        title: PlayerMainControls(active: true),
        actionsAlignment: MainAxisAlignment.center,
        content: QueueBody(),
      );
}
