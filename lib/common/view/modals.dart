import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';

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
      context.bottomSheet(
        builder,
        isScrollControlled: isScrollControlled,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
      );

    case ModalMode.dialog:
      context.dialog(builder);
  }
}

enum ModalMode {
  dialog,
  bottomSheet;

  static ModalMode get platformModalMode =>
      isMobile ? ModalMode.bottomSheet : ModalMode.dialog;
}

enum OverlayMode {
  popup,
  bottomSheet;

  static OverlayMode get platformModalMode =>
      isMobile ? OverlayMode.bottomSheet : OverlayMode.popup;
}
