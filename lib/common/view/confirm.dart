import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../util/result.dart';
import 'icons.dart';
import 'theme.dart';
import 'ui_constants.dart';

class ConfirmationDialog<T> extends StatefulWidget {
  const ConfirmationDialog({
    super.key,
    this.onConfirm,
    this.initialFuture,
    this.onCancel,
    this.additionalActions,
    this.title,
    this.subtitle,
    this.avatarContent,
    this.headerIcon,
    this.headerIconData,
    this.loadingTitle,
    this.content,
    this.showCancel = true,
    this.showConfirm = true,
    this.scrollable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmEnabled = true,
    this.createErrorText,
    this.onError,
    this.onErrorConfirm,
    this.loadingIndicator,
    this.dialogWidth = DialogWidth.medium,
    this.modalLevel = ModalLevel.info,
    this.presentAsBottomSheet = false,
    this.avatarModalLevel,
    this.destructiveActionStyle = DestructiveActionStyle.outlined,
    this.cancelButtonStyle = CancelButtonStyle.outlined,
    this.barrierDismissible = true,
  });

  final dynamic Function()? onConfirm;
  final Future<T> Function()? initialFuture;
  final dynamic Function()? onCancel;
  final List<Widget>? additionalActions;
  final Widget? title;
  final Widget? subtitle;
  final Widget? avatarContent;
  final Widget? headerIcon;
  final IconData? headerIconData;
  final Widget? loadingTitle;
  final Widget? content;
  final bool showCancel;
  final bool showConfirm;
  final bool scrollable;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool confirmEnabled;
  final String? Function(Object? error)? createErrorText;
  final String Function(Object? error)? onError;
  final void Function()? onErrorConfirm;
  final Widget? loadingIndicator;
  final ModalLevel modalLevel;
  final ModalLevel? avatarModalLevel;
  final DestructiveActionStyle destructiveActionStyle;
  final CancelButtonStyle cancelButtonStyle;
  final DialogWidth dialogWidth;
  final bool presentAsBottomSheet;
  final bool barrierDismissible;

  static Future<Result<T, Exception>> show<T>({
    required BuildContext context,
    Key? key,
    dynamic Function()? onConfirm,
    Future<T> Function()? initialFuture,
    Widget? title,
    Widget? subtitle,
    Widget? avatarContent,
    Widget? headerIcon,
    IconData? headerIconData,
    Widget? loadingTitle,
    Widget? content,
    String? confirmLabel,
    String? cancelLabel,
    bool barrierDismissible = true,
    bool confirmEnabled = true,
    bool scrollable = false,
    List<Widget>? additionalActions,
    dynamic Function()? onCancel,
    bool showCancel = true,
    bool showConfirm = true,
    String? Function(Object? error)? createErrorText,
    String Function(Object? error)? onError,
    void Function()? onErrorConfirm,
    Widget? loadingIndicator,
    ModalLevel modalLevel = ModalLevel.info,
    ModalLevel? modalAvatarLevel,
    DestructiveActionStyle destructiveActionStyle =
        DestructiveActionStyle.outlined,
    CancelButtonStyle cancelButtonStyle = CancelButtonStyle.outlined,
    DialogWidth dialogWidth = DialogWidth.medium,
    Widget Function(BuildContext context, bool asBottomSheet)? builder,
  }) async {
    final asBottomSheet = context.isPortrait;

    Widget builderFn(BuildContext context, {required bool asBottomSheet}) =>
        ConfirmationDialog<T>(
          key: key,
          title: title,
          subtitle: subtitle,
          avatarContent: avatarContent,
          headerIcon: headerIcon,
          headerIconData: headerIconData,
          content: content,
          onConfirm: onConfirm,
          initialFuture: initialFuture,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          confirmEnabled: confirmEnabled,
          scrollable: scrollable,
          additionalActions: additionalActions,
          onCancel: onCancel,
          showCancel: showCancel,
          showConfirm: showConfirm,
          loadingTitle: loadingTitle,
          createErrorText: createErrorText,
          onError: onError,
          onErrorConfirm: onErrorConfirm,
          loadingIndicator: loadingIndicator,
          modalLevel: modalLevel,
          avatarModalLevel: modalAvatarLevel,
          destructiveActionStyle: destructiveActionStyle,
          cancelButtonStyle: cancelButtonStyle,
          presentAsBottomSheet: asBottomSheet,
          barrierDismissible: barrierDismissible,
          dialogWidth: dialogWidth,
        );

    final Result<dynamic, Exception>? result;
    if (asBottomSheet) {
      result = await showModalBottomSheet<Result<dynamic, Exception>>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        isDismissible: barrierDismissible,
        enableDrag: barrierDismissible,
        showDragHandle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        builder: (context) =>
            builder?.call(context, asBottomSheet) ??
            builderFn(context, asBottomSheet: asBottomSheet),
      );
    } else {
      result = await showDialog<Result<dynamic, Exception>>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) =>
            builder?.call(context, asBottomSheet) ??
            builderFn(context, asBottomSheet: asBottomSheet),
      );
    }

    return switch (result) {
      Success(:final value) => Success(value as T),
      Failure(:final error) => Failure(error),
      null => Failure(Exception('AdaptiveModal canceled')),
    };
  }

  @override
  State<ConfirmationDialog<T>> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState<T> extends State<ConfirmationDialog<T>> {
  bool _loading = false;
  String? _error;
  Object? _errorObject;

  void _popResult(Result<T, Exception> result) {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop<Result<T, Exception>>(result);
    }
  }

  String _resolveErrorText(Object error) =>
      widget.createErrorText?.call(error) ??
      widget.onError?.call(error) ??
      error.toString();

  @override
  void initState() {
    super.initState();
    if (widget.initialFuture != null) {
      _loading = true;
      widget.initialFuture!()
          .then((value) => _popResult(Success(value)))
          .catchError((Object error, StackTrace stackTrace) {
            setState(() {
              _loading = false;
              _errorObject = error;
              _error = _resolveErrorText(error);
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final content = _error != null
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
        ? (widget.loadingIndicator ??
              const SizedBox.square(
                dimension: 60,
                child: Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ))
        : widget.content != null
        ? DefaultTextStyle(
            style:
                context.textTheme.bodyMedium?.copyWith(height: 1.6) ??
                const TextStyle(height: 1.6),
            child: widget.content!,
          )
        : null;

    final title = _loading ? widget.loadingTitle : widget.title;

    void onConfirmErrorPressed() {
      widget.onErrorConfirm?.call();
      final error = _errorObject;
      _popResult(
        Failure(
          error is Exception
              ? error
              : Exception(error?.toString() ?? 'AdaptiveModal error'),
        ),
      );
    }

    final onCancelPressed = _loading
        ? null
        : () {
            if (widget.onCancel != null) {
              if (widget.onCancel is Future<T> Function()) {
                setState(() => _loading = true);
                widget.onCancel!()
                    .then((_) {
                      _popResult(Failure(Exception('AdaptiveModal canceled')));
                    })
                    .catchError((error) {
                      setState(() {
                        _loading = false;
                        _error = error.toString();
                      });
                    });
              } else {
                _popResult(Failure(Exception('AdaptiveModal canceled')));
                widget.onCancel?.call();
              }
            } else {
              _popResult(Failure(Exception('AdaptiveModal canceled')));
            }
          };

    final onConfirmPressed = _loading
        ? null
        : widget.confirmEnabled
        ? () {
            if (widget.onConfirm != null) {
              if (widget.onConfirm is Future<T> Function()) {
                setState(() => _loading = true);
                widget.onConfirm!()
                    .then((value) {
                      _popResult(Success(value as T));
                    })
                    .catchError((Object error, StackTrace stackTrace) {
                      setState(() {
                        _loading = false;
                        _errorObject = error;
                        _error = _resolveErrorText(error);
                      });
                    });
              } else {
                _popResult(Success(null as T));
                widget.onConfirm!();
              }
            } else {
              _popResult(Success(null as T));
            }
          }
        : null;

    if (widget.presentAsBottomSheet) {
      final dialogTheme = context.theme.dialogTheme;
      return SafeArea(
        bottom: isAndroid,
        child: Padding(
          // this padding is the gap to the screen!
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                // this is the content padding
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  color: dialogTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(kYaruContainerRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 24,
                  children: [
                    if (title != null)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.initialFuture == null)
                            widget.headerIcon ??
                                ModalAvatar(
                                  type:
                                      widget.avatarModalLevel ??
                                      widget.modalLevel,
                                  icon: widget.avatarContent,
                                  iconData: widget.headerIconData,
                                )
                          else
                            const SizedBox(height: 40),
                          widget.headerIcon ??
                              ModalAvatar(
                                type:
                                    widget.avatarModalLevel ??
                                    widget.modalLevel,
                                icon: widget.avatarContent,
                                iconData: widget.headerIconData,
                              ),
                          const SizedBox(height: 16),
                          DefaultTextStyle(
                            style: dialogTitleTextStyle(context.colorScheme),
                            textAlign: TextAlign.center,
                            child: title,
                          ),
                          if (widget.subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 24,
                              ),
                              child: DefaultTextStyle(
                                style: dialogSubtitleTextStyle(
                                  context.colorScheme,
                                ),
                                textAlign: TextAlign.center,
                                child: widget.subtitle!,
                              ),
                            ),
                        ],
                      ),
                    if (content != null)
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: DefaultTextStyle(
                            style: dialogSubtitleTextStyle(context.colorScheme),
                            textAlign: TextAlign.center,
                            child: content,
                          ),
                        ),
                      ),
                    // Actions
                    Column(
                      spacing: 8,
                      children: _error != null
                          ? [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: onConfirmErrorPressed,
                                  child: Text(l10n.ok),
                                ),
                              ),
                            ]
                          : widget.initialFuture != null
                          ? [
                              if (widget.showConfirm)
                                SizedBox(
                                  width: double.infinity,
                                  child:
                                      widget.modalLevel == ModalLevel.error &&
                                          widget.destructiveActionStyle ==
                                              DestructiveActionStyle.outlined
                                      ? OutlinedButton(
                                          onPressed: onConfirmPressed,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                context.colorScheme.error,
                                            side: BorderSide(
                                              color: context.colorScheme.error,
                                            ),
                                          ),
                                          child: Text(
                                            widget.confirmLabel ?? l10n.ok,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: onConfirmPressed,
                                          style:
                                              widget.modalLevel ==
                                                  ModalLevel.error
                                              ? context
                                                    .theme
                                                    .elevatedButtonTheme
                                                    .style
                                                    ?.copyWith(
                                                      foregroundColor:
                                                          WidgetStateProperty.all(
                                                            context
                                                                .colorScheme
                                                                .onError,
                                                          ),
                                                      backgroundColor:
                                                          WidgetStateProperty.all(
                                                            context
                                                                .colorScheme
                                                                .error,
                                                          ),
                                                    )
                                              : null,
                                          child: Text(
                                            widget.confirmLabel ?? l10n.ok,
                                          ),
                                        ),
                                ),
                              ...?widget.additionalActions,
                              if (widget.showCancel)
                                SizedBox(
                                  width: double.infinity,
                                  child:
                                      widget.cancelButtonStyle ==
                                          CancelButtonStyle.outlined
                                      ? OutlinedButton(
                                          onPressed: onCancelPressed,
                                          child: Text(
                                            widget.cancelLabel ?? l10n.cancel,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: onCancelPressed,
                                          child: Text(
                                            widget.cancelLabel ?? l10n.cancel,
                                          ),
                                        ),
                                ),
                            ]
                          : [],
                    ),
                  ],
                ),
              ),
              if (widget.barrierDismissible)
                Positioned(
                  top: 12,
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: widget.dialogWidth.width,
        minWidth: widget.dialogWidth.width,
      ),
      titlePadding: EdgeInsets.zero,
      title: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.initialFuture == null)
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 40),
                  child:
                      widget.headerIcon ??
                      ModalAvatar(
                        type: widget.avatarModalLevel ?? widget.modalLevel,
                        icon: widget.avatarContent,
                        iconData: widget.headerIconData,
                      ),
                )
              else
                const SizedBox(height: 40),
              const SizedBox(height: 16),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DefaultTextStyle(
                    style: dialogTitleTextStyle(context.colorScheme),
                    textAlign: TextAlign.center,
                    child: title,
                  ),
                ),
              if (widget.subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DefaultTextStyle(
                    style: dialogSubtitleTextStyle(context.colorScheme),
                    textAlign: TextAlign.center,
                    child: widget.subtitle!,
                  ),
                ),
            ],
          ),
          if (widget.barrierDismissible)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  Iconz.close,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                onPressed: onCancelPressed,
              ),
            ),
        ],
      ),
      scrollable: widget.scrollable,
      content: content,
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 12),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        if (_error != null)
          OutlinedButton(onPressed: onConfirmErrorPressed, child: Text(l10n.ok))
        else if (widget.initialFuture != null)
          ...[]
        else ...[
          if (widget.showCancel)
            widget.cancelButtonStyle == CancelButtonStyle.elevated
                ? ElevatedButton(
                    onPressed: onCancelPressed,
                    child: Text(widget.cancelLabel ?? l10n.cancel),
                  )
                : OutlinedButton(
                    onPressed: onCancelPressed,
                    child: Text(widget.cancelLabel ?? l10n.cancel),
                  ),
          ...?widget.additionalActions,
          if (widget.showConfirm)
            widget.destructiveActionStyle == DestructiveActionStyle.outlined &&
                    widget.modalLevel == ModalLevel.error
                ? OutlinedButton(
                    onPressed: onConfirmPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                      side: BorderSide(color: context.colorScheme.error),
                    ),
                    child: Text(widget.confirmLabel ?? l10n.ok),
                  )
                : ElevatedButton(
                    style: widget.modalLevel == ModalLevel.error
                        ? context.theme.elevatedButtonTheme.style?.copyWith(
                            foregroundColor: WidgetStateProperty.all(
                              context.colorScheme.onError,
                            ),
                            backgroundColor: WidgetStateProperty.all(
                              context.colorScheme.error,
                            ),
                          )
                        : null,
                    onPressed: onConfirmPressed,
                    child: Text(widget.confirmLabel ?? l10n.ok),
                  ),
        ],
      ],
    );
  }
}

class ModalAvatar extends StatelessWidget {
  const ModalAvatar({
    super.key,
    required ModalLevel type,
    this.icon,
    this.iconData,
    this.avatarRadius = 24,
  }) : _type = type;
  const ModalAvatar.info({
    super.key,
    this.icon,
    this.iconData,
    this.avatarRadius = 24,
  }) : _type = ModalLevel.info;
  const ModalAvatar.warning({
    super.key,
    this.icon,
    this.iconData,
    this.avatarRadius = 24,
  }) : _type = ModalLevel.warning;
  const ModalAvatar.error({
    super.key,
    this.icon,
    this.iconData,
    this.avatarRadius = 24,
  }) : _type = ModalLevel.error;
  const ModalAvatar.success({
    super.key,
    this.icon,
    this.iconData,
    this.avatarRadius = 24,
  }) : _type = ModalLevel.success;
  const ModalAvatar.neutral({
    super.key,
    this.icon,
    this.iconData,
    this.avatarRadius = 24,
  }) : _type = ModalLevel.neutral;

  final ModalLevel _type;
  final Widget? icon;
  final IconData? iconData;
  final double avatarRadius;

  @override
  Widget build(BuildContext context) {
    final color = _type.getColor(context.colorScheme);

    return CircleAvatar(
      radius: avatarRadius,
      backgroundColor: switch (_type) {
        ModalLevel.warning => context.colorScheme.warning,
        ModalLevel.error => context.colorScheme.error,
        ModalLevel.info => context.colorScheme.primary,
        ModalLevel.success => context.colorScheme.success,
        ModalLevel.neutral => context.colorScheme.surface,
      },
      child:
          icon ??
          (iconData != null ? Icon(iconData, color: color) : null) ??
          switch (_type) {
            ModalLevel.warning => Icon(Iconz.warning, color: color),
            ModalLevel.error => Icon(Iconz.warning, color: color),
            ModalLevel.info => Icon(Iconz.info, color: color),
            ModalLevel.success => Icon(Iconz.check, color: color),
            ModalLevel.neutral => Icon(Iconz.info, color: color),
          },
    );
  }
}

enum ModalLevel {
  warning,
  error,
  info,
  success,
  neutral;

  Color getColor(ColorScheme colorScheme) => (switch (this) {
    ModalLevel.warning => colorScheme.warning,
    ModalLevel.error => colorScheme.error,
    ModalLevel.info => colorScheme.primary,
    ModalLevel.success => colorScheme.success,
    ModalLevel.neutral => colorScheme.surface,
  }).contrastColor;
}

enum DialogWidth {
  small,
  medium,
  large;

  double get width => switch (this) {
    DialogWidth.small => kDialogWidthSmall,
    DialogWidth.medium => kDialogWidthMedium,
    DialogWidth.large => kDialogWidthLarge,
  };
}

enum DestructiveActionStyle { elevated, outlined }

enum CancelButtonStyle { elevated, outlined }
