import '../../l10n/app_localizations.dart';

enum PodcastEpisodeFilter {
  title,
  description;

  String localize(AppLocalizations l10n) => switch (this) {
    title => l10n.title,
    description => l10n.description,
  };
}
