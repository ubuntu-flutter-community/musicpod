import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../data/audio.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.label,
    required this.audios,
  });

  final String? label;
  final Set<Audio> audios;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

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
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.label == null ? null : widget.label!,
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
        return widget.audios.where((a) {
          if (a.url != null) {
            return true;
          }

          if (a.metadata == null) {
            return false;
          } else {
            if (a.metadata?.title == null) {
              return false;
            } else {
              if (a.metadata!.title!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase())) {
                return true;
              }
            }
            if (a.metadata?.artist == null) {
              return false;
            } else {
              if (a.metadata!.artist!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase())) {
                return true;
              }
            }
            if (a.metadata?.album == null) {
              return false;
            } else {
              if (a.metadata!.album!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase())) {
                return true;
              }
              return false;
            }
          }
        }).toList();
      },
      onSelected: (audio) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return AudioPage(
              audios: {audio},
              pageName: audio.metadata?.title ?? '',
            );
          },
        ),
      ),
    );

    return autoComplete;
  }
}
