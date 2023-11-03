import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

final List<Locale> supportedLocales = {
  const Locale('en'), // make sure 'en' comes first (#216)
  ...List.of(AppLocalizations.supportedLocales)..remove(const Locale('en')),
}.toList();

extension LocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
