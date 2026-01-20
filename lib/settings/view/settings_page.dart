import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';
import 'about_section.dart';
import 'expose_online_section.dart';
import 'local_audio_section.dart';
import 'lyrics_section.dart';
import 'podcast_section.dart';
import 'radio_section.dart';
import 'reset_section.dart';
import 'resource_section.dart';
import 'theme_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.scrollToIndex(
        di<SettingsModel>().scrollIndex,
        preferPosition: AutoScrollPosition.begin,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HeaderBar(
      adaptive: true,
      title: Text(context.l10n.settings),
      actions: [
        Padding(
          padding: appBarSingleActionSpacing,
          child: const SearchButton(),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => ListView(
        controller: _scrollController,
        padding: getAdaptiveHorizontalPadding(
          constraints: constraints,
          limit: 600,
          min: 0,
        ).copyWith(bottom: bottomPlayerPageGap),
        children:
            const [
                  ThemeSection(),
                  PodcastSection(),
                  LocalAudioSection(),
                  RadioSection(),
                  ExposeOnlineSection(),
                  ResourceSection(),
                  ResetSection(),
                  LyricsSection(),
                  AboutSection(),
                ]
                .mapIndexed(
                  (i, e) => AutoScrollTag(
                    key: ValueKey(i),
                    controller: _scrollController,
                    index: i,
                    child: e,
                  ),
                )
                .toList(),
      ),
    ),
  );
}
