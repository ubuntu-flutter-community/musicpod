import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'about_section.dart';
import 'expose_online_section.dart';
import 'local_audio_section.dart';
import 'podcast_section.dart';
import 'theme_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YaruDialogTitleBar(
          border: BorderSide.none,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          onClose: (p0) => Navigator.of(rootNavigator: true, context).pop(),
          title: Text(context.l10n.settings),
        ),
        Expanded(
          child: ListView(
            children: const [
              ThemeSection(),
              PodcastSection(),
              LocalAudioSection(),
              ExposeOnlineSection(),
              AboutSection(),
            ],
          ),
        ),
      ],
    );
  }
}
