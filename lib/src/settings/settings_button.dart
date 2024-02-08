import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../library.dart';
import '../../local_audio.dart';
import 'settings_model.dart';
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
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<SettingsModel>(),
            child: ChangeNotifierProvider.value(
              value: context.read<LocalAudioModel>(),
              child: ChangeNotifierProvider.value(
                value: context.read<LibraryModel>(),
                child: const SettingsDialog(),
              ),
            ),
          ),
        );
      },
    );
  }
}
