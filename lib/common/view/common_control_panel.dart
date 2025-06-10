import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import 'icons.dart';
import 'theme.dart';

class CommonControlPanel extends StatelessWidget {
  const CommonControlPanel({
    super.key,
    required this.labels,
    required this.isSelected,
    required this.onSelected,
  });

  final List<Widget> labels;
  final List<bool> isSelected;
  final void Function(int index)? onSelected;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.center,
    child: YaruChoiceChipBar(
      clearOnSelect: false,
      selectedFirst: false,
      showCheckMarks: false,
      style: YaruChoiceChipBarStyle.stack,
      shrinkWrap: true,
      goNextIcon: Icon(Iconz.goNext),
      goPreviousIcon: Icon(Iconz.goBack),
      chipHeight: chipHeight,
      labels: labels,
      isSelected: isSelected,
      onSelected: onSelected,
    ),
  );
}
