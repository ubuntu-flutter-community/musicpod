import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/responsive_master_tile.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.onDirectorySelected});

  final Future<void> Function(String? directoryPath) onDirectorySelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ResponsiveMasterTile(
        title: const Text('Settings'),
        leading: const Icon(YaruIcons.settings),
        availableWidth: constraints.maxWidth,
        onTap: () => showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              titlePadding: EdgeInsets.zero,
              title: const YaruDialogTitleBar(
                title: Text('Chose collection directory'),
              ),
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final directoryPath = await getDirectoryPath();

                      await onDirectorySelected(directoryPath)
                          .then((value) => Navigator.of(context).pop());
                    },
                    child: const Text('Pick your music collection'),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
