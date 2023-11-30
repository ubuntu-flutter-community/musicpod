import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;

import '../../common.dart';
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
                  return TextFormField(
                    style: fallBackTextStyle,
                    autofocus: true,
                    decoration: const InputDecoration(
                      constraints: BoxConstraints(maxHeight: 10),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: textEditingController,
                    focusNode: focusNode,
                    onFieldSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: (options.length * 40) > 400
                            ? 400
                            : options.length * 40,
                        child: Material(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          elevation: 3,
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
                                  return ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      left: 10,
                                      right: 5,
                                    ),
                                    dense: true,
                                    titleTextStyle: fallBackTextStyle?.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    hoverColor:
                                        highlight ? theme.focusColor : null,
                                    tileColor:
                                        highlight ? theme.focusColor : null,
                                    onTap: () => onSelected(t),
                                    title: Text(t.name),
                                    trailing: IconButton(
                                      onPressed: () {
                                        favs?.contains(t.name) == false
                                            ? addFav(t)
                                            : removeFav(t);
                                        // stateSetter(() {});
                                      },
                                      icon: Icon(
                                        favs?.contains(t.name) == true
                                            ? Iconz().starFilled
                                            : Iconz().star,
                                      ),
                                    ),
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
        ),
      ],
    );
  }
}
