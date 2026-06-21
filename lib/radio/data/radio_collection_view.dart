import '../../l10n/app_localizations.dart';

enum RadioCollectionView {
  stations,
  tags,
  history,
  ignoredIcyTitles;

  String localize(AppLocalizations l10n) => switch (this) {
    stations => l10n.stations,
    tags => l10n.tags,
    history => l10n.history,
    ignoredIcyTitles => l10n.ignoredHearyHistoryTitlesTitle,
  };
}
