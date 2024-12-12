import 'dart:io';

import 'package:flutter/material.dart';

Future<void> showModal({
  required BuildContext context,
  required Widget content,
  required ModalMode mode,
  bool isScrollControlled = false,
  bool enableDrag = true,
  bool? showDragHandle,
}) async {
  Widget builder(context) => content;

  switch (mode) {
    case ModalMode.bottomSheet:
      showModalBottomSheet(
        isScrollControlled: isScrollControlled,
        context: context,
        builder: builder,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
      );

    case ModalMode.dialog:
      showDialog(
        context: context,
        builder: builder,
      );
  }
}

enum ModalMode {
  dialog,
  bottomSheet;

  static ModalMode get platformModalMode =>
      Platform.isAndroid || Platform.isIOS || Platform.isFuchsia
          ? ModalMode.bottomSheet
          : ModalMode.dialog;
}

enum OverlayMode {
  popup,
  bottomSheet;

  static OverlayMode get platformModalMode =>
      Platform.isAndroid || Platform.isIOS || Platform.isFuchsia
          ? OverlayMode.bottomSheet
          : OverlayMode.popup;
}
