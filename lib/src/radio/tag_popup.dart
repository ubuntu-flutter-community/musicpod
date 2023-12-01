import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;

import '../../common.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

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
    final theme = Theme.of(context);
    final fallBackTextStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 5,
        ),
        Text(
          '${context.l10n.tag}:',
          style: fallBackTextStyle,
        ),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          width: 180,
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
                  const outlineInputBorder = OutlineInputBorder(
                    borderSide: BorderSide.none,
                  );
                  return Padding(
                    padding: EdgeInsets.only(bottom: yaruStyled ? 3 : 0),
                    child: TextFormField(
                      onTap: () {
                        textEditingController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: textEditingController.value.text.length,
                        );
                      },
                      style: fallBackTextStyle,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(maxHeight: 12),
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        border: outlineInputBorder,
                        errorBorder: outlineInputBorder,
                        enabledBorder: outlineInputBorder,
                        focusedBorder: outlineInputBorder,
                        disabledBorder: outlineInputBorder,
                        focusedErrorBorder: outlineInputBorder,
                      ),
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: (options.length * 40) > 400
                            ? 400
                            : options.length * 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Material(
                            color: theme.brightness == Brightness.light
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
                                          .addPostFrameCallback(
                                              (Duration timeStamp) {
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
        ),
      ],
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
