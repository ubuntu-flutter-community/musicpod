import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../l10n.dart';

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

    return CountryCodePicker(
      backgroundColor: theme.dialogBackgroundColor,
      dialogBackgroundColor: theme.dialogBackgroundColor,
      barrierColor: Colors.black.withOpacity(0.5),
      onChanged: (value) => onSelected?.call(
        Country.values.firstWhereOrNull(
              (e) => e.code.toLowerCase() == value.code?.toLowerCase(),
            ) ??
            Country.none,
      ),
      initialSelection: value?.code,
      searchDecoration: InputDecoration(
        prefixIcon: Icon(Iconz().search),
      ),
      emptySearchBuilder: (context) => Padding(
        padding: const EdgeInsets.only(top: 100),
        child: NoSearchResultPage(
          message: Text(
            context.l10n.noCountryFound,
            style: theme.textTheme.bodyMedium,
          ),
          icons: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedEmoji(AnimatedEmojis.xEyes),
              SizedBox(
                width: 5,
              ),
              AnimatedEmoji(AnimatedEmojis.globeShowingEuropeAfrica),
            ],
          ),
        ),
      ),
      showCountryOnly: true,
      dialogSize: const Size(500, 500),
      closeIcon: Icon(Iconz().close),
      showOnlyCountryWhenClosed: true,
      alignLeft: false,
      padding: EdgeInsets.zero,
      flagWidth: 20,
    );
  }
}
