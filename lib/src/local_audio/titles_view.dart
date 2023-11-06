import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../l10n/l10n.dart';

class TitlesView extends StatefulWidget {
  const TitlesView({
    super.key,
    required this.audios,
    required this.showWindowControls,
    this.onTextTap,
  });

  final Set<Audio>? audios;
  final bool showWindowControls;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  State<TitlesView> createState() => _TitlesViewState();
}

class _TitlesViewState extends State<TitlesView> {
  List<Audio>? _titles;

  void _initTitles() {
    _titles = widget.audios?.toList();
    if (_titles == null) return;
    sortListByAudioFilter(
      audioFilter: AudioFilter.album,
      audios: _titles!,
    );
  }

  @override
  void initState() {
    super.initState();
    _initTitles();
  }

  @override
  void didUpdateWidget(covariant TitlesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initTitles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audios == null) {
      return const Center(
        child: Progress(),
      );
    }

    return AudioPageBody(
      noResultMessage: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.noLocalTitlesFound),
          const ShopRecommendations(),
        ],
      ),
      audios: _titles == null ? null : Set.from(_titles!),
      audioPageType: AudioPageType.immutable,
      pageId: context.l10n.localAudio,
      showAudioPageHeader: false,
      onTextTap: widget.onTextTap,
    );
  }
}
