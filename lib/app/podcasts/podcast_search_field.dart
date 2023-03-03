import 'package:flutter/material.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final podcastModel = context.watch<PodcastModel>();

    final autoComplete = Autocomplete<Audio>(
      optionsViewBuilder: (context, onSelected, audios) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(kYaruContainerRadius),
            ),
            child: SizedBox(
              width: 400,
              height: 400,
              child: ListView.builder(
                itemCount: audios.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = audios.elementAt(index);
                  final i = AutocompleteHighlightedOption.of(context);
                  return ListTile(
                    onTap: () => onSelected(option),
                    selected: i == index,
                    title: Text(
                      option.metadata != null
                          ? '${option.metadata?.artist} - ${option.metadata?.title} - ${option.metadata?.album}'
                          : option.url != null
                              ? option.name ?? ''
                              : '',
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      displayStringForOption: (option) {
        return option.metadata != null
            ? '${option.metadata?.title}'
            : option.url != null
                ? option.name ?? ''
                : '';
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return SizedBox(
          height: 35,
          width: 400,
          child: TextField(
            onChanged: (value) => podcastModel.search(searchQuery: value),
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: context.l10n.search,
              contentPadding: const EdgeInsets.only(left: 10, right: 10),
              suffixIconConstraints:
                  const BoxConstraints(maxHeight: 35, maxWidth: 35),
              suffixIcon: YaruIconButton(
                onPressed: () => textEditingController.clear(),
                icon: const Icon(
                  YaruIcons.edit_clear,
                ),
              ),
              fillColor: light ? Colors.white : Theme.of(context).dividerColor,
            ),
          ),
        );
      },
      optionsBuilder: (textEditingValue) {
        return podcastModel.searchResult.where((a) {
          if (a.toString().toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              )) {
            return true;
          }

          return false;
        }).toList();
      },
      onSelected: (audio) => podcastModel.search(searchQuery: ' ').then(
            (value) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  final album = podcastModel.searchResult.where(
                    (a) =>
                        a.metadata != null &&
                        a.metadata!.album != null &&
                        a.metadata?.album == audio.metadata?.album,
                  );

                  return AudioPage(
                    title: const PodcastSearchField(),
                    deletable: false,
                    audioPageType: audio.metadata?.album != null
                        ? AudioPageType.albumList
                        : AudioPageType.list,
                    editableName: false,
                    audios:
                        album.isNotEmpty == true ? Set.from(album) : {audio},
                    pageName: audio.metadata?.album ??
                        audio.metadata?.title ??
                        audio.name ??
                        '',
                  );
                },
              ),
            ),
          ),
    );

    return autoComplete;
  }
}
