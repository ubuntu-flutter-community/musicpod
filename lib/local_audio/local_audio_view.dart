import '../l10n/app_localizations.dart';

enum LocalAudioView {
  titles,
  artists,
  // albumArtists,
  albums,
  genres,
  playlists;

  String localize(AppLocalizations l10n) => switch (this) {
        titles => l10n.titles,
        artists => l10n.artists,
        // albumArtists => l10n.albumArtists,
        albums => l10n.albums,
        genres => l10n.genres,
        playlists => l10n.playlists,
      };
}
