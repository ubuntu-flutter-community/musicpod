import 'package:flutter/material.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../string_x.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../l10n/l10n.dart';

class CountryPopup extends StatelessWidget {
  const CountryPopup({
    super.key,
    this.onSelected,
    this.countries,
    required this.value,
    this.textStyle,
  });

  final void Function(Country country)? onSelected;
  final List<Country>? countries;
  final Country? value;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
    final fallBackTextStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    return YaruPopupMenuButton<Country>(
      icon: const DropDownArrow(),
      style: buttonStyle,
      onSelected: onSelected,
      initialValue: value,
      child: Text(
        '${context.l10n.country}: ${value?.name.capitalize().camelToSentence() ?? context.l10n.all}',
        style: textStyle ?? fallBackTextStyle,
      ),
      itemBuilder: (context) {
        return [
          for (final c
              in countries ?? Country.values.where((c) => c != Country.none))
            PopupMenuItem(
              value: c,
              child: Text(c.name.capitalize().camelToSentence()),
            ),
        ];
      },
    );
  }
}
