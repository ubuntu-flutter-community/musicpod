import '../../l10n/app_localizations.dart';

enum OnlineLyricsSource {
  lrcLib;

  String localize(AppLocalizations l10n) => switch (this) {
    OnlineLyricsSource.lrcLib => l10n.onlineLyricsSourceLrcLib,
  };

  OnlineLyricsSource fromString(String s) => switch (s.toLowerCase()) {
    'lrclib' => OnlineLyricsSource.lrcLib,
    _ => throw ArgumentError('Unknown online lyrics source: $s'),
  };
}
