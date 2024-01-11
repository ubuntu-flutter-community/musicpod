import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../l10n/l10n.dart';

class LimitPopup extends StatelessWidget {
  const LimitPopup({
    super.key,
    this.onSelected,
    this.limits,
    required this.value,
    this.textStyle,
  });

  final void Function(int value)? onSelected;
  final List<int>? limits;
  final int? value;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
    final fallBackTextStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    return YaruPopupMenuButton<int>(
      icon: const DropDownArrow(),
      style: buttonStyle,
      onSelected: onSelected,
      initialValue: value,
      child: Text(
        '${context.l10n.limit}: ${value?.toString() ?? ''} ',
        style: textStyle ?? fallBackTextStyle,
      ),
      itemBuilder: (context) {
        return [
          for (final c in limits ?? [10, 20, 50, 100])
            PopupMenuItem(
              value: c,
              child: Text('$c'),
            ),
        ];
      },
    );
  }
}
