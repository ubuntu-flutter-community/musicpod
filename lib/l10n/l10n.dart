import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

final List<Locale> supportedLocales = {
  const Locale('en'), // make sure 'en' comes first (#216)
  ...List.of(AppLocalizations.supportedLocales)..remove(const Locale('en')),
}.toList();

extension LocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
