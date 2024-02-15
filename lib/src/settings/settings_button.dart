import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../l10n.dart';
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
    final model = context.read<SettingsModel>();
    return Center(
      child: PopupMenuButton(
        tooltip: context.l10n.moreOptions,
        icon: Icon(Iconz().menu),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Center(
              child: ImportantButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  model.playOpenedFile();
                },
                child: Text(context.l10n.open),
              ),
            ),
          ),
          PopupMenuItem(
            enabled: false,
            child: Center(
              child: TextButton(
                child: Text(context.l10n.settings),
                onPressed: () {
                  Navigator.of(context).pop();
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
