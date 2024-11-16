import '../common/data/audio.dart';
import '../l10n/l10n.dart';

enum SearchType {
  localTitle,
  localArtist,
  localAlbumArtist,
  localAlbum,
  localGenreName,
  localPlaylists,
  radioName,
  radioTag,
  radioCountry,
  radioLanguage,
  podcastTitle;

  String localize(AppLocalizations l10n) => switch (this) {
        localTitle => l10n.titles,
        localArtist => l10n.artists,
        localAlbumArtist => l10n.albumArtists,
        localAlbum => l10n.albums,
        localGenreName => l10n.genres,
        localPlaylists => l10n.playlists,
        radioName => l10n.name,
        radioTag => l10n.tag,
        podcastTitle => l10n.title,
        radioCountry => l10n.country,
        radioLanguage => l10n.language,
      };
}

Set<SearchType> searchTypesFromAudioType(AudioType audioType) {
  return SearchType.values
      .where((e) => e.name.contains(audioType.name))
      .toSet();
}
