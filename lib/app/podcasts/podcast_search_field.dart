import 'package:flutter/material.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastSearchField extends StatefulWidget {
  const PodcastSearchField({
    super.key,
  });

  @override
  State<PodcastSearchField> createState() => _PodcastSearchFieldState();
}

class _PodcastSearchFieldState extends State<PodcastSearchField> {
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
    final model = context.read<PodcastModel>();

    return SizedBox(
      height: 35,
      width: 400,
      child: TextField(
        style: theme.textTheme.bodyMedium,
        strutStyle: const StrutStyle(
          leading: 0.2,
        ),
        textAlignVertical: TextAlignVertical.center,
        cursorWidth: 1,
        onSubmitted: (value) {
          model.setSearchQuery(value);
          model.search(searchQuery: value);
        },
        controller: _controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          prefixIcon: const Icon(
            YaruIcons.search,
            size: 16,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 34, minHeight: 30),
          hintText: context.l10n.search,
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 35, maxWidth: 35),
          suffixIcon: _controller.text.isEmpty
              ? null
              : YaruIconButton(
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
