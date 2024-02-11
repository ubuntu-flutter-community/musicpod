import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import 'settings_dialog.dart';
import 'settings_model.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, required this.initLocalAudio});

  final Future<void> Function({
    required void Function(List<String>) onFail,
    bool forceInit,
  }) initLocalAudio;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Iconz().menu),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<SettingsModel>(),
            child: SettingsDialog(
              initLocalAudio: initLocalAudio,
            ),
          ),
        );
      },
    );
  }
}
