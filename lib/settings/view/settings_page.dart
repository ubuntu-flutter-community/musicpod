import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'about_section.dart';
import 'expose_online_section.dart';
import 'local_audio_section.dart';
import 'podcast_section.dart';
import 'reset_section.dart';
import 'resource_section.dart';
import 'theme_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listView = ListView(
      padding: EdgeInsets.only(bottom: bottomPlayerPageGap ?? 0),
      children: const [
        ThemeSection(),
        PodcastSection(),
        LocalAudioSection(),
        ExposeOnlineSection(),
        ResourceSection(),
        ResetSection(),
        AboutSection(),
      ],
    );
    if (isMobilePlatform) {
      return Scaffold(
        appBar: HeaderBar(
          adaptive: false,
          title: Text(context.l10n.settings),
        ),
        body: listView,
      );
    }

    return Column(
      children: [
        YaruDialogTitleBar(
          border: BorderSide.none,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          onClose: (p0) => Navigator.of(rootNavigator: true, context).pop(),
          title: Text(context.l10n.settings),
        ),
        Expanded(
          child: listView,
        ),
      ],
    );
  }
}
