import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/local_audio/shop_recommendations.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.onDirectorySelected});

  final Future<void> Function(String? directoryPath) onDirectorySelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: kYaruTitleBarItemHeight,
        width: kYaruTitleBarItemHeight,
        child: PopupMenuButton(
          icon: const Icon(
            YaruIcons.menu,
            size: 19,
          ),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: Column(
                  children: [
                    const ShopRecommendations(),
                    ElevatedButton(
                      onPressed: () async {
                        final directoryPath = await getDirectoryPath();

                        await onDirectorySelected(directoryPath)
                            .then((value) => Navigator.of(context).pop());
                      },
                      child: Text(context.l10n.pickMusicCollection),
                    ),
                    const SizedBox(
                      height: kYaruPagePadding,
                    )
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}
