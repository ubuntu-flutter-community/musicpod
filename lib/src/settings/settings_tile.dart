import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n.dart';
import '../../local_audio.dart';
import '../common/icons.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.onDirectorySelected});

  final Future<void> Function(String? directoryPath) onDirectorySelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Iconz().menu,
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
