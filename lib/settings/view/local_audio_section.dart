import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_model.dart';
import '../settings_model.dart';

class LocalAudioSection extends StatelessWidget with WatchItMixin {
  const LocalAudioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final directory =
        watchPropertyValue((SettingsModel m) => m.directory ?? '');

    return YaruSection(
      headline: Text(context.l10n.localAudio),
      margin: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.musicCollectionLocation),
            subtitle: Text(directory),
            trailing: ImportantButton(
              onPressed: () async {
                final directoryPath =
                    await di<ExternalPathService>().getPathOfDirectory();
                if (directoryPath != null) {
                  await di<LocalAudioModel>().init(
                    forceInit: true,
                    directory: directoryPath,
                  );
                }
              },
              child: Text(
                context.l10n.select,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
