import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../data/audio.dart';
import 'adaptive_container.dart';
import 'audio_page_header.dart';
import 'audio_page_type.dart';
import 'avatar_play_button.dart';
import 'common_widgets.dart';
import 'no_search_result_page.dart';
import 'sliver_audio_page_control_panel.dart';
import 'sliver_audio_tile_list.dart';

class SliverAudioPage extends StatelessWidget {
  const SliverAudioPage({
    super.key,
    required this.pageId,
    this.audios,
    required this.audioPageType,
    this.onPageSubTitleTab,
    this.onPageLabelTab,
    this.pageTitle,
    this.pageSubTitle,
    this.pageLabel,
    this.image,
    this.controlPanel,
    this.noSearchResultMessage,
    this.noSearchResultIcons,
    this.description,
  });

  final String pageId;
  final Set<Audio>? audios;
  final AudioPageType audioPageType;

  final String? pageTitle;
  final String? pageSubTitle;
  final String? pageLabel;
  final Widget? image;
  final Widget? description;

  final void Function(String text)? onPageSubTitleTab;
  final void Function(String)? onPageLabelTab;

  final Widget? controlPanel;

  final Widget? noSearchResultMessage;
  final Widget? noSearchResultIcons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: isMobile ? null : Text(pageTitle ?? pageId),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return audios == null
              ? const Center(
                  child: Progress(),
                )
              : audios!.isEmpty
                  ? NoSearchResultPage(
                      message: noSearchResultMessage,
                      icons: noSearchResultIcons,
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: AudioPageHeader(
                            title: pageTitle ?? pageId,
                            image: image,
                            subTitle: pageSubTitle,
                            label: pageLabel,
                            onLabelTab:
                                audioPageType == AudioPageType.likedAudio
                                    ? null
                                    : onPageLabelTab,
                            onSubTitleTab: onPageSubTitleTab,
                            description: description,
                          ),
                        ),
                        SliverAudioPageControlPanel(
                          controlPanel: controlPanel ??
                              AvatarPlayButton(
                                audios: audios ?? {},
                                pageId: pageId,
                              ),
                        ),
                        if (audios == null)
                          const SliverToBoxAdapter(
                            child: Center(
                              child: Progress(),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: getAdaptiveHorizontalPadding(constraints),
                            sliver: SliverAudioTileList(
                              audioPageType: audioPageType,
                              audios: audios!,
                              pageId: pageId,
                              onSubTitleTab: onPageLabelTab,
                            ),
                          ),
                      ],
                    );
        },
      ),
    );
  }
}
