import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';
import '../l10n/l10n.dart';

class TagPopup extends StatelessWidget {
  const TagPopup({
    super.key,
    this.onSelected,
    this.tags,
    required this.value,
    this.textStyle,
    required this.addFav,
    required this.removeFav,
    this.favs,
  });

  final void Function(Tag? tag)? onSelected;
  final List<Tag>? tags;
  final Set<String>? favs;
  final Tag? value;
  final TextStyle? textStyle;
  final void Function(Tag? tag) addFav;
  final void Function(Tag? tag) removeFav;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final fallBackTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return SizedBox(
      width: kSearchBarWidth,
      height: 38,
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Autocomplete<Tag>(
            key: ValueKey(value?.name),
            initialValue: TextEditingValue(
              text: value?.name ?? context.l10n.all,
            ),
            displayStringForOption: (option) => option.name,
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              final outlineInputBorder = OutlineInputBorder(
                borderSide:
                    BorderSide(width: 2, color: theme.colorScheme.primary),
              );
              return TextField(
                style: yaruStyled
                    ? const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      )
                    : null,
                maxLines: 1,
                onTap: () {
                  textEditingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: textEditingController.value.text.length,
                  );
                },
                // style: fallBackTextStyle,
                decoration: yaruStyled
                    ? _createYaruDecoration(theme.colorScheme)
                    : InputDecoration(
                        filled: true,
                        contentPadding: const EdgeInsets.all(10),
                        border: outlineInputBorder,
                        errorBorder: outlineInputBorder,
                        enabledBorder: outlineInputBorder,
                        focusedBorder: outlineInputBorder,
                        disabledBorder: outlineInputBorder,
                        focusedErrorBorder: outlineInputBorder,
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
                  width: kSearchBarWidth - 22,
                  height:
                      (options.length * 50) > 400 ? 400 : options.length * 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Material(
                      color: theme.isLight
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceVariant,
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
                              return _TagTile(
                                onSelected: (v) => onSelected(v),
                                fallBackTextStyle: fallBackTextStyle,
                                highlight: highlight,
                                theme: theme,
                                t: t,
                                favs: favs,
                                addFav: addFav,
                                removeFav: removeFav,
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
                return tags ?? [];
              }
              return tags?.where(
                    (e) => e.name
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

  InputDecoration _createYaruDecoration(ColorScheme colorScheme) {
    final radius = BorderRadius.circular(6);
    const width = 1.0;
    const strokeAlign = 0.0;
    final fill = colorScheme.isLight
        ? const Color(0xFFededed)
        : const Color.fromARGB(255, 40, 40, 40);
    final border = colorScheme.isHighContrast
        ? colorScheme.outlineVariant
        : colorScheme.outline;
    final disabledBorder = colorScheme.isLight
        ? const Color.fromARGB(255, 237, 237, 237)
        : const Color.fromARGB(255, 67, 67, 67);

    const textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    );

    return InputDecoration(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          width: width,
          color: border,
        ),
        borderRadius: radius,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: width, color: colorScheme.primary),
        borderRadius: radius,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(width: width, color: border, strokeAlign: strokeAlign),
        borderRadius: radius,
      ),
      // activeIndicatorBorder:
      //     const BorderSide(width: width, strokeAlign: strokeAlign),
      // outlineBorder: const BorderSide(width: width, strokeAlign: strokeAlign),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: width,
          color: colorScheme.error,
          strokeAlign: strokeAlign,
        ),
        borderRadius: radius,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: width,
          color: colorScheme.error,
          strokeAlign: strokeAlign,
        ),
        borderRadius: radius,
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: width,
          color: disabledBorder,
          strokeAlign: strokeAlign,
        ),
        borderRadius: radius,
      ),
      isDense: true,
      iconColor: colorScheme.onSurface,
      contentPadding:
          const EdgeInsets.only(left: 12, right: 12, bottom: 9, top: 10),
      helperStyle: textStyle,
      hintStyle: textStyle,
      labelStyle: textStyle,
      suffixStyle: textStyle.copyWith(
        color: colorScheme.onSurface.scale(lightness: -0.2),
      ),
      prefixStyle: textStyle.copyWith(
        color: colorScheme.onSurface.scale(lightness: -0.2),
      ),
    );
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.fallBackTextStyle,
    required this.highlight,
    required this.theme,
    required this.t,
    required this.favs,
    required this.addFav,
    required this.removeFav,
    required this.onSelected,
  });

  final TextStyle? fallBackTextStyle;
  final bool highlight;
  final ThemeData theme;
  final Tag t;
  final Set<String>? favs;
  final void Function(Tag? tag) addFav;
  final void Function(Tag? tag) removeFav;
  final void Function(Tag tag) onSelected;

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
      title: Text(t.name),
      trailing: IconButton(
        onPressed: () {
          favs?.contains(t.name) == false ? addFav(t) : removeFav(t);
        },
        icon: Icon(
          favs?.contains(t.name) == true ? Iconz().starFilled : Iconz().star,
        ),
      ),
    );
  }
}
