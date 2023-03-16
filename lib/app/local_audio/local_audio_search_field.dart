import 'package:flutter/material.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioSearchField extends StatefulWidget {
  const LocalAudioSearchField({
    super.key,
  });

  @override
  State<LocalAudioSearchField> createState() => _LocalAudioSearchFieldState();
}

class _LocalAudioSearchFieldState extends State<LocalAudioSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final text = context.read<PodcastModel>().searchQuery;
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final model = context.watch<LocalAudioModel>();

    return SizedBox(
      height: 35,
      width: 400,
      child: TextField(
        onSubmitted: (value) {
          model.setSearchQuery(value);
          // model.search(searchQuery: value, useAlbumImage: true);
        },
        controller: _controller,
        decoration: InputDecoration(
          hintText: context.l10n.search,
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 35, maxWidth: 35),
          suffixIcon: YaruIconButton(
            onPressed: () => _controller.clear(),
            icon: const Icon(
              YaruIcons.edit_clear,
            ),
          ),
          fillColor: light ? Colors.white : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
