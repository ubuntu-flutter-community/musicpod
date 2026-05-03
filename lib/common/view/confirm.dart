import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'progress.dart';
import 'theme.dart';
import 'ui_constants.dart';

class ConfirmationDialog<T> extends StatefulWidget {
  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.additionalActions,
    this.title,
    this.constraints,
    this.content,
    this.showCancel = true,
    this.showCloseIcon = true,
    this.scrollable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.contentPadding,
    this.titlePadding,
  });
  final dynamic Function()? onConfirm;
  final dynamic Function()? onCancel;
  final List<Widget>? additionalActions;
  final Widget? title;
  final Widget? content;
  final bool showCancel;
  final bool showCloseIcon;
  final bool scrollable;
  final String? confirmLabel;
  final String? cancelLabel;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? titlePadding;
  final BoxConstraints? constraints;

  static Future<T?> show<T>({
    required BuildContext context,
    required dynamic Function() onConfirm,
    Widget? title,
    Widget? content,
    String? confirmLabel,
    String? cancelLabel,
    bool barrierDismissible = false,
    bool confirmEnabled = true,
    bool scrollable = false,
    List<Widget>? additionalActions,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? titlePadding,
    dynamic Function()? onCancel,
    bool showCancel = true,
    BoxConstraints? constraints,
  }) => showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => ConfirmationDialog<T>(
      title: title,
      content: content,
      onConfirm: onConfirm,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      showCloseIcon: barrierDismissible,
      scrollable: scrollable,
      additionalActions: additionalActions,
      contentPadding: contentPadding,
      onCancel: onCancel,
      showCancel: showCancel,
      titlePadding: titlePadding,
      constraints: constraints,
    ),
  );

  @override
  State<ConfirmationDialog<T>> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState<T> extends State<ConfirmationDialog<T>> {
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      constraints: widget.constraints,
      titlePadding: widget.titlePadding ?? EdgeInsets.zero,
      title: YaruDialogTitleBar(
        backgroundColor: Colors.transparent,
        title: widget.title,
        isClosable: widget.showCloseIcon,
        border: BorderSide.none,
      ),
      scrollable: widget.scrollable,
      content: _error != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: context.textTheme.bodyLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : _loading
          ? const SizedBox.square(
              dimension: 60,
              child: Center(
                child: SizedBox.square(dimension: 24, child: Progress()),
              ),
            )
          : widget.content,
      contentPadding: widget.contentPadding,
      actionsAlignment: MainAxisAlignment.start,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsPadding: const EdgeInsets.all(kMediumSpace),
      actions: [
        Row(
          children: space(
            expandAll: true,
            widthGap: 16,
            children: _error != null
                ? [
                    OutlinedButton(
                      onPressed: () {
                        if (context.mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(l10n.ok),
                    ),
                  ]
                : [
                    if (widget.showCancel)
                      OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                if (widget.onCancel is Future<T> Function()) {
                                  setState(() => _loading = true);
                                  widget.onCancel!()
                                      .then((_) {
                                        if (context.mounted &&
                                            Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                      })
                                      .catchError((error) {
                                        setState(() {
                                          _loading = false;
                                          _error = error.toString();
                                        });
                                      });
                                } else {
                                  widget.onCancel?.call();
                                  if (context.mounted &&
                                      Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                        child: Text(widget.cancelLabel ?? l10n.cancel),
                      ),
                    ...?widget.additionalActions,
                    ElevatedButton(
                      onPressed: _loading || widget.onConfirm == null
                          ? null
                          : () {
                              if (widget.onConfirm is Future<T> Function()) {
                                setState(() => _loading = true);
                                widget.onConfirm!()
                                    .then((_) {
                                      if (context.mounted &&
                                          Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    })
                                    .catchError((error) {
                                      setState(() {
                                        _loading = false;
                                        _error = error.toString();
                                      });
                                    });
                              } else {
                                widget.onConfirm!();
                                setState(() => _loading = false);
                                if (context.mounted &&
                                    Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                      child: Text(widget.confirmLabel ?? l10n.ok),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}
