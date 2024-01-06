import 'package:collection/collection.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../build_context_x.dart';
import '../../common.dart';

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
      barrierColor: Colors.transparent,
      onChanged: (value) => onSelected?.call(
        Country.values.firstWhereOrNull(
              (e) => e.code.toLowerCase() == value.code?.toLowerCase(),
            ) ??
            Country.none,
      ),
      initialSelection: value?.code,
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
