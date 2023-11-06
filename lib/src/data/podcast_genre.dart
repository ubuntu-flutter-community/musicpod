import '../../string_x.dart';

import '../l10n/l10n.dart';

enum PodcastGenre {
  all,
  arts,
  business,
  comedy,
  education,
  fiction,
  government,
  healthAndFitness,
  history,
  kidsAndFamily,
  leisure,
  music,
  news,
  religionAndSpirituality,
  science,
  societyAndCulture,
  sports,
  tvAndFilm,
  technology,
  trueCrime;

  String get id {
    switch (this) {
      case healthAndFitness:
        return 'Health & Fitness';
      case kidsAndFamily:
        return 'Kids & Family';
      case religionAndSpirituality:
        return 'Religion & Spirituality';
      case societyAndCulture:
        return 'Society & Culture';
      case tvAndFilm:
        return 'TV & Film';
      case trueCrime:
        return 'True Crime';
      default:
        return name.capitalize();
    }
  }

  String localize(AppLocalizations l10n) {
    switch (this) {
      case all:
        return l10n.all;
      case arts:
        return l10n.arts;
      case business:
        return l10n.business;
      case comedy:
        return l10n.comedy;
      case education:
        return l10n.education;
      case fiction:
        return l10n.fiction;
      case government:
        return l10n.government;
      case healthAndFitness:
        return l10n.healthAndFitness;
      case history:
        return l10n.history;
      case kidsAndFamily:
        return l10n.kidsAndFamily;
      case leisure:
        return l10n.leisure;
      case music:
        return l10n.music;
      case news:
        return l10n.news;
      case religionAndSpirituality:
        return l10n.religionAndSpirituality;
      case science:
        return l10n.science;
      case societyAndCulture:
        return l10n.societyAndCulture;
      case sports:
        return l10n.sports;
      case tvAndFilm:
        return l10n.tvAndFilm;
      case technology:
        return l10n.technology;
      case trueCrime:
        return l10n.trueCrime;
    }
  }
}
