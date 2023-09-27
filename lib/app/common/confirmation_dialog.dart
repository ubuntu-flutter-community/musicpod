import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_widgets/constants.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.message,
  });

  final Widget message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
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
