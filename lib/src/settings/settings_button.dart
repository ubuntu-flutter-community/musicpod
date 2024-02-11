import 'package:flutter/material.dart';

import '../../common.dart';
import 'settings_dialog.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Iconz().menu),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const SettingsDialog(),
        );
      },
    );
  }
}
