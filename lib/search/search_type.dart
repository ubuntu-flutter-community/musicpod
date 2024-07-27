import '../common/data/audio.dart';
import '../l10n/l10n.dart';

enum SearchType {
  localTitle,
  localArtist,
  localAlbum,
  localGenreName,
  radioName,
  radioTag,
  radioCountry,
  radioLanguage,
  podcastTitle,
  podcastGenre,
  podcastCountry,
  podcastLanguage;

  String localize(AppLocalizations l10n) => switch (this) {
        localTitle => l10n.titles,
        localArtist => l10n.artists,
        localAlbum => l10n.albums,
        localGenreName => l10n.genres,
        radioName => l10n.name,
        radioTag => l10n.tag,
        podcastTitle => l10n.title,
        podcastGenre => l10n.genres,
        radioCountry => l10n.country,
        radioLanguage => l10n.language,
        podcastCountry => l10n.country,
        podcastLanguage => l10n.language,
      };
}

Set<SearchType> searchTypesFromAudioType(AudioType audioType) {
  return SearchType.values
      .where((e) => e.name.contains(audioType.name))
      .toSet();
}
