import '../l10n/l10n.dart';

enum LocalAudioView {
  titles,
  artists,
  albums;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      titles => l10n.titles,
      artists => l10n.artists,
      albums => l10n.albums
    };
  }
}
