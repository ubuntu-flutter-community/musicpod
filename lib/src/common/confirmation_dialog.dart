import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

import '../../build_context_x.dart';
import '../l10n/l10n.dart';

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.message,
  });

  final Widget message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: DefaultTextStyle(
        style: context.t.textTheme.bodyLarge ?? const TextStyle(),
        child: SizedBox(
          width: 300,
          child: message,
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      kYaruContainerRadius,
                    ),
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(
                      kYaruContainerRadius,
                    ),
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop<bool>(true),
              child: Text(context.l10n.ok),
            ),
          ].map((e) => Expanded(child: e)).toList(),
        ),
      ],
    );
  }
}

void runOrConfirm({
  required BuildContext context,
  required bool noConfirm,
  required String message,
  required Function run,
  required Function onCancel,
}) {
  if (noConfirm) {
    run();
  } else {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return _ConfirmationDialog(
          message: Text(
            context.l10n.queueConfirmMessage(
              message,
            ),
          ),
        );
      },
    ).then((value) {
      if (value == true) {
        run();
      } else {
        onCancel();
      }
    });
  }
}
