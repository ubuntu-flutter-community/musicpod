import 'package:flutter/material.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/radio/stations.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../data/audio.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.spawnPageWithWindowControls = true,
  });

  final bool spawnPageWithWindowControls;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final localAudioModel = context.watch<LocalAudioModel>();

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
            ? '${option.metadata?.artist} - ${option.metadata?.title} - ${option.metadata?.album}'
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
        final allAudios = (localAudioModel.audios != null
                ? localAudioModel.audios!.toList()
                : <Audio>[]) +
            stationsMap.entries
                .map(
                  (e) => Audio(
                    name: e.key,
                    url: e.value,
                    audioType: AudioType.radio,
                  ),
                )
                .toList();

        return allAudios.where((a) {
          if (a.toString().toLowerCase().contains(
                textEditingValue.text.replaceAll(' ', '').toLowerCase(),
              )) {
            return true;
          }

          return false;
        }).toList();
      },
      onSelected: (audio) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            final album = localAudioModel.audios?.where(
              (a) =>
                  a.metadata != null &&
                  a.metadata!.album != null &&
                  a.metadata?.album == audio.metadata?.album,
            );

            return AudioPage(
              showWindowControls: widget.spawnPageWithWindowControls,
              deletable: false,
              audioPageType: audio.metadata?.album != null
                  ? AudioPageType.albumList
                  : AudioPageType.list,
              editableName: false,
              audios: album?.isNotEmpty == true ? Set.from(album!) : {audio},
              pageName: audio.metadata?.album ??
                  audio.metadata?.title ??
                  audio.name ??
                  '',
            );
          },
        ),
      ),
    );

    return autoComplete;
  }
}
