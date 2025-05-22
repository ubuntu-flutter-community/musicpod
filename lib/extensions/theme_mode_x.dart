import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

extension ThemeModeX on ThemeMode {
  String localize(AppLocalizations l10n) => switch (this) {
    ThemeMode.system => l10n.system,
    ThemeMode.dark => l10n.dark,
    ThemeMode.light => l10n.light,
  };
}
