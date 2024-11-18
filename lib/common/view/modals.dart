import 'package:flutter/material.dart';
import 'package:yaru/theme.dart';

Future<void> showModal({
  required BuildContext context,
  required Widget content,
}) async {
  Widget builder(context) => content;

  if (isMobile) {
    showModalBottomSheet(context: context, builder: builder);
  } else {
    showDialog(
      context: context,
      builder: builder,
    );
  }
}
