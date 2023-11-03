import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n.dart';
import '../../local_audio.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.onDirectorySelected});

  final Future<void> Function(String? directoryPath) onDirectorySelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          YaruIcons.menu,
        ),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              child: Column(
                children: [
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final directoryPath = await getDirectoryPath();

                      await onDirectorySelected(directoryPath)
                          .then((value) => Navigator.of(context).pop());
                    },
                    child: Text(context.l10n.pickMusicCollection),
                  ),
                  const ShopRecommendations(),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}
