import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../app_config.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/country_x.dart';
import '../../l10n/l10n.dart';
import 'icons.dart';
import 'theme.dart';

class CountryAutoComplete extends StatelessWidget {
  const CountryAutoComplete({
    super.key,
    this.onSelected,
    this.countries,
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
    this.suffixIcon,
    this.autofocus = false,
  });

  final void Function(Country? country)? onSelected;
  final List<Country>? countries;
  final Set<String>? favs;
  final Country? value;
  final TextStyle? textStyle;
  final void Function(Country? country) addFav;
  final void Function(Country? country) removeFav;
  final double? width;
  final double? height;
  final TextStyle? style;
  final bool isDense, filled;
  final OutlineInputBorder? border;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SizedBox(
      height: height ?? inputHeight,
      width: width,
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Autocomplete<Country>(
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
              final hintText =
                  '${context.l10n.search}: ${context.l10n.country}';
              return TextField(
                autofocus: autofocus,
                maxLines: 1,
                onTap: () {
                  textEditingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: textEditingController.value.text.length,
                  );
                },
                style: style ??
                    (AppConfig.yaruStyled ? theme.textTheme.bodyMedium : null),
                textAlignVertical:
                    AppConfig.yaruStyled ? TextAlignVertical.center : null,
                cursorWidth: AppConfig.yaruStyled ? 1 : 2.0,
                decoration: AppConfig.yaruStyled
                    ? createYaruDecoration(
                        theme: theme,
                        style: style,
                        fillColor: fillColor,
                        contentPadding: contentPadding,
                        hintText: hintText,
                        border: border,
                        suffixIcon: suffixIcon,
                      )
                    : createMaterialDecoration(
                        colorScheme: theme.colorScheme,
                        style: style,
                        isDense: isDense,
                        border: border,
                        filled: filled,
                        fillColor: fillColor,
                        contentPadding: contentPadding,
                        hintText: hintText,
                        suffixIcon: suffixIcon,
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
                              return _CountryTile(
                                onSelected: (v) => onSelected(v),
                                fallBackTextStyle: style,
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
                return countries ?? [];
              }

              return countries?.where(
                    (e) =>
                        e
                            .localize(context.l10n)
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()) ||
                        e.name
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

class _CountryTile extends StatelessWidget {
  const _CountryTile({
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
  final Country t;
  final Set<String>? favs;
  final void Function(Country? tag) addFav;
  final void Function(Country? tag) removeFav;
  final void Function(Country tag) onSelected;

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
      title: Tooltip(
        message: t.localize(context.l10n),
        child: Text(
          t.localize(context.l10n),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: IconButton(
        onPressed: () {
          favs?.contains(t.code) == false ? addFav(t) : removeFav(t);
        },
        icon: Icon(
          favs?.contains(t.code) == true ? Iconz.starFilled : Iconz.star,
        ),
      ),
    );
  }
}
