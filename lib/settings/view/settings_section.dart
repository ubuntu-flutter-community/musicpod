import 'package:flutter/material.dart';

import '../../common/view/ui_constants.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.heading,
    required this.children,
  });

  final String heading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(heading),
          contentPadding: const EdgeInsets.only(bottom: kSmallestSpace),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ],
    );
  }
}
