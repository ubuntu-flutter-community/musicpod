import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../l10n/l10n.dart';
import 'theme.dart';
import 'ui_constants.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
    this.additionalActions,
    this.title,
    this.content,
    this.showCancel = true,
    this.showCloseIcon = true,
    this.scrollable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmEnabled = true,
    this.contentPadding,
  });

  final dynamic Function()? onConfirm;
  final bool confirmEnabled;
  final dynamic Function()? onCancel;
  final List<Widget>? additionalActions;
  final Widget? title;
  final Widget? content;
  final bool showCancel;
  final bool showCloseIcon;
  final bool scrollable;
  final String? confirmLabel, cancelLabel;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: YaruDialogTitleBar(
        title: title,
        backgroundColor: Colors.transparent,
        border: BorderSide.none,
        isClosable: showCloseIcon,
      ),
      scrollable: scrollable,
      titlePadding: EdgeInsets.zero,
      content: content,
      contentPadding: contentPadding,
      actionsAlignment: MainAxisAlignment.start,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsPadding: const EdgeInsets.all(kMediumSpace),
      actions: [
        Row(
          children: space(
            expandAll: true,
            widthGap: kMediumSpace,
            children: [
              ...?additionalActions,
              if (showCancel)
                OutlinedButton(
                  onPressed: () {
                    onCancel?.call();
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(cancelLabel ?? l10n.cancel),
                ),
              ElevatedButton(
                onPressed: confirmEnabled
                    ? () {
                        onConfirm?.call();

                        if (context.mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                child: Text(confirmLabel ?? l10n.ok),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
