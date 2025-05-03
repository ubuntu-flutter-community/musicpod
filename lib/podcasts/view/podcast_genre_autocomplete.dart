import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/podcast_genre.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';

class PodcastGenreAutoComplete extends StatelessWidget with WatchItMixin {
  const PodcastGenreAutoComplete({
    super.key,
    this.onSelected,
    this.genres,
    required this.value,
    this.textStyle,
    required this.addFav,
    required this.removeFav,
    this.favs,
    this.width,
    this.height,
    this.style,
    this.isDense = false,
    this.filled = true,
    this.border,
    this.fillColor,
    this.contentPadding,
  });

  final void Function(PodcastGenre? podcastGenre)? onSelected;
  final List<PodcastGenre>? genres;
  final Set<String>? favs;
  final PodcastGenre? value;
  final TextStyle? textStyle;
  final void Function(PodcastGenre? podcastGenre) addFav;
  final void Function(PodcastGenre? podcastGenre) removeFav;
  final double? width;
  final double? height;
  final TextStyle? style;
  final bool isDense, filled;
  final Color? fillColor;
  final OutlineInputBorder? border;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);

    return SizedBox(
      height: height ?? getInputHeight(useYaruTheme),
      width: width,
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Autocomplete<PodcastGenre>(
            key: ValueKey(value?.name),
            initialValue: TextEditingValue(
              text: value?.localize(context.l10n) ?? context.l10n.all,
            ),
            displayStringForOption: (option) => option.localize(context.l10n),
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              return TextField(
                maxLines: 1,
                onTap: () {
                  textEditingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: textEditingController.value.text.length,
                  );
                },
                style:
                    style ?? (useYaruTheme ? theme.textTheme.bodyMedium : null),
                strutStyle: useYaruTheme
                    ? const StrutStyle(
                        leading: 0.2,
                      )
                    : null,
                textAlignVertical:
                    useYaruTheme ? TextAlignVertical.center : null,
                cursorWidth: useYaruTheme ? 1 : 2.0,
                decoration: useYaruTheme
                    ? createYaruDecoration(
                        theme: theme,
                        style: style,
                        fillColor: fillColor,
                        contentPadding: contentPadding,
                        border: border,
                      )
                    : createMaterialDecoration(
                        colorScheme: theme.colorScheme,
                        style: style,
                        isDense: isDense,
                        border: border,
                        filled: filled,
                        fillColor: fillColor,
                        contentPadding: contentPadding,
                      ),
                controller: textEditingController,
                focusNode: focusNode,
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width ?? searchBarWidth,
                  height:
                      (options.length * 50) > 400 ? 400 : options.length * 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Material(
                      color: theme.popupMenuTheme.color,
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
                              return _PodcastGenreTile(
                                onSelected: (v) => onSelected(v),
                                fallBackTextStyle: style,
                                highlight: highlight,
                                theme: theme,
                                t: t,
                                favs: favs,
                                // addFav: addFav,
                                // removeFav: removeFav,
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
                return genres ?? [];
              }
              return genres?.where(
                    (e) => e
                        .localize(context.l10n)
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

class _PodcastGenreTile extends StatelessWidget {
  const _PodcastGenreTile({
    required this.fallBackTextStyle,
    required this.highlight,
    required this.theme,
    required this.t,
    required this.favs,
    // required this.addFav,
    // required this.removeFav,
    required this.onSelected,
  });

  final TextStyle? fallBackTextStyle;
  final bool highlight;
  final ThemeData theme;
  final PodcastGenre t;
  final Set<String>? favs;
  // final void Function(PodcastGenre? tag) addFav;
  // final void Function(PodcastGenre? tag) removeFav;
  final void Function(PodcastGenre tag) onSelected;

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
      title: Text(t.localize(context.l10n)),
      // trailing: IconButton(
      //   onPressed: () {
      //     favs?.contains(t.id) == false ? addFav(t) : removeFav(t);
      //   },
      //   icon: Icon(
      //     favs?.contains(t.id) == true ? Iconz.starFilled : Iconz.star,
      //   ),
      // ),
    );
  }
}
