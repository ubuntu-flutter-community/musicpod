import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yaru/constants.dart';

import '../../app_config.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../data/audio.dart';
import 'theme.dart';

class AudioAutoComplete extends StatelessWidget {
  const AudioAutoComplete({
    super.key,
    this.onSelected,
    this.audios,
    this.textStyle,
  });

  final void Function(Audio? audio)? onSelected;
  final List<Audio>? audios;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final fallBackTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return SizedBox(
      height: AppConfig.yaruStyled ? kYaruTitleBarItemHeight : 38,
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Autocomplete<Audio>(
            displayStringForOption: (option) =>
                '${option.artist} - ${option.title}',
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              final hintText =
                  '${context.l10n.search}: ${context.l10n.localAudio}';
              return TextField(
                autofocus: true,
                maxLines: 1,
                onTap: () {
                  textEditingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: textEditingController.value.text.length,
                  );
                },
                style: AppConfig.yaruStyled ? theme.textTheme.bodyMedium : null,
                strutStyle: AppConfig.yaruStyled
                    ? const StrutStyle(
                        leading: 0.2,
                      )
                    : null,
                textAlignVertical:
                    AppConfig.yaruStyled ? TextAlignVertical.center : null,
                cursorWidth: AppConfig.yaruStyled ? 1 : 2.0,
                decoration: AppConfig.yaruStyled
                    ? createYaruDecoration(
                        theme: theme,
                        hintText: hintText,
                      )
                    : createMaterialDecoration(
                        colorScheme: colorScheme,
                        hintText: hintText,
                      ),
                controller: textEditingController,
                focusNode: focusNode,
                onSubmitted: (String value) {
                  onFieldSubmitted();
                  textEditingController.clear();
                  focusNode.requestFocus();
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: searchBarWidth,
                  height:
                      (options.length * 50) > 400 ? 400 : options.length * 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Material(
                      color: theme.isLight
                          ? colorScheme.surface
                          : colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                      elevation: 1,
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return Builder(
                            builder: (BuildContext context) {
                              final bool highlight =
                                  AutocompleteHighlightedOption.of(
                                        context,
                                      ) ==
                                      index;
                              if (highlight) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((Duration timeStamp) {
                                  Scrollable.ensureVisible(
                                    context,
                                    alignment: 0.5,
                                  );
                                });
                              }
                              final t = options.elementAt(index);
                              return _AudioTile(
                                onSelected: (v) => onSelected(v),
                                fallBackTextStyle: fallBackTextStyle,
                                highlight: highlight,
                                theme: theme,
                                t: t,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return audios ?? [];
              }
              return audios?.where(
                    (a) => '${a.artist} ${a.title}'
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()),
                  ) ??
                  [];
            },
            onSelected: (option) => onSelected?.call(option),
          );
        },
      ),
    );
  }
}

class _AudioTile extends StatelessWidget {
  const _AudioTile({
    required this.fallBackTextStyle,
    required this.highlight,
    required this.theme,
    required this.t,
    required this.onSelected,
  });

  final TextStyle? fallBackTextStyle;
  final bool highlight;
  final ThemeData theme;
  final Audio t;
  final void Function(Audio tag) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 10,
        right: 5,
      ),
      titleTextStyle: fallBackTextStyle?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      hoverColor: highlight ? theme.focusColor : null,
      tileColor: highlight ? theme.focusColor : null,
      onTap: () => onSelected(t),
      title: Text('${t.artist} - ${t.title}'),
    );
  }
}
