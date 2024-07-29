import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../l10n/l10n.dart';
import 'drop_down_arrow.dart';

class CountryPopup extends StatelessWidget {
  const CountryPopup({
    super.key,
    this.onSelected,
    this.countries,
    required this.value,
    this.textStyle,
    this.buttonStyle,
  });

  final void Function(Country country)? onSelected;
  final List<Country>? countries;
  final Country? value;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final fallBackTextStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    return YaruPopupMenuButton<Country>(
      icon: const DropDownArrow(),
      style: buttonStyle,
      onSelected: onSelected,
      initialValue: value,
      child: Text(
        '${context.l10n.country}: ${value?.name.camelToSentence.everyWordCapitalized ?? context.l10n.all}',
        style: textStyle ?? fallBackTextStyle,
      ),
      itemBuilder: (context) {
        return [
          for (final c
              in countries ?? Country.values.where((c) => c != Country.none))
            PopupMenuItem(
              value: c,
              child: Text(c.name.camelToSentence.everyWordCapitalized),
            ),
        ];
      },
    );
  }
}
