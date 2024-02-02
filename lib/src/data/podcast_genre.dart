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
  healthAndFitnessXXXITunesOnly,
  history,
  kidsAndFamilyXXXITunesOnly,
  leisure,
  music,
  news,
  religionAndSpiritualityXXXITunesOnly,
  science,
  societyAndCultureXXXITunesOnly,
  sports,
  tvAndFilmXXXITunesOnly,
  technology,
  trueCrime,
  afterShows,
  alternative,
  animals,
  animation,

  astronomyXXXPodcastIndexOnly,
  automotiveXXXPodcastIndexOnly,
  aviationXXXPodcastIndexOnly,
  baseballXXXPodcastIndexOnly,
  basketballXXXPodcastIndexOnly,
  beautyXXXPodcastIndexOnly,
  booksXXXPodcastIndexOnly,
  buddhismXXXPodcastIndexOnly,
  careersXXXPodcastIndexOnly,
  chemistryXXXPodcastIndexOnly,
  christianityXXXPodcastIndexOnly,
  climateXXXPodcastIndexOnly,
  commentaryXXXPodcastIndexOnly,
  coursesXXXPodcastIndexOnly,
  craftsXXXPodcastIndexOnly,
  cricketXXXPodcastIndexOnly,
  cryptocurrencyXXXPodcastIndexOnly,
  cultureXXXPodcastIndexOnly,
  dailyXXXPodcastIndexOnly,
  designXXXPodcastIndexOnly,
  documentaryXXXPodcastIndexOnly,
  dramaXXXPodcastIndexOnly,
  earthXXXPodcastIndexOnly,
  entertainmentXXXPodcastIndexOnly,
  entrepreneurshipXXXPodcastIndexOnly,
  familyXXXPodcastIndexOnly,
  fantasyXXXPodcastIndexOnly,
  fashionXXXPodcastIndexOnly,
  filmXXXPodcastIndexOnly,
  fitnessXXXPodcastIndexOnly,
  foodXXXPodcastIndexOnly,
  footballXXXPodcastIndexOnly,
  gamesXXXPodcastIndexOnly,
  gardenXXXPodcastIndexOnly,
  golfXXXPodcastIndexOnly,
  healthXXXPodcastIndexOnly,
  hinduismXXXPodcastIndexOnly,
  hobbiesXXXPodcastIndexOnly,
  hockeyXXXPodcastIndexOnly,
  homeXXXPodcastIndexOnly,
  howToXXXPodcastIndexOnly,
  improvXXXPodcastIndexOnly,
  interviewsXXXPodcastIndexOnly,
  investingXXXPodcastIndexOnly,
  islamXXXPodcastIndexOnly,
  journalsXXXPodcastIndexOnly,
  judaismXXXPodcastIndexOnly,
  kidsXXXPodcastIndexOnly,
  languageXXXPodcastIndexOnly,
  learningXXXPodcastIndexOnly,
  lifeXXXPodcastIndexOnly,
  managementXXXPodcastIndexOnly,
  mangaXXXPodcastIndexOnly,
  marketingXXXPodcastIndexOnly,
  mathematicsXXXPodcastIndexOnly,
  medicineXXXPodcastIndexOnly,
  mentalXXXPodcastIndexOnly,
  naturalXXXPodcastIndexOnly,
  natureXXXPodcastIndexOnly,
  nonProfitXXXPodcastIndexOnly,
  nutritionXXXPodcastIndexOnly,
  parentingXXXPodcastIndexOnly,
  performingXXXPodcastIndexOnly,
  personalXXXPodcastIndexOnly,
  petsXXXPodcastIndexOnly,
  philosophyXXXPodcastIndexOnly,
  physicsXXXPodcastIndexOnly,
  placesXXXPodcastIndexOnly,
  politicsXXXPodcastIndexOnly,
  relationshipsXXXPodcastIndexOnly,
  religionXXXPodcastIndexOnly,
  reviewsXXXPodcastIndexOnly,
  rolePlayingXXXPodcastIndexOnly,
  rugbyXXXPodcastIndexOnly,
  runningXXXPodcastIndexOnly,
  selfImprovementXXXPodcastIndexOnly,
  sexualityXXXPodcastIndexOnly,
  soccerXXXPodcastIndexOnly,
  socialXXXPodcastIndexOnly,
  societyXXXPodcastIndexOnly,
  spiritualityXXXPodcastIndexOnly,
  standUpXXXPodcastIndexOnly,
  storiesXXXPodcastIndexOnly,
  swimmingXXXPodcastIndexOnly,
  tVXXXPodcastIndexOnly,
  tabletopXXXPodcastIndexOnly,
  tennisXXXPodcastIndexOnly,
  travelXXXPodcastIndexOnly,
  videoGamesXXXPodcastIndexOnly,
  visualXXXPodcastIndexOnly,
  volleyballXXXPodcastIndexOnly,
  weatherXXXPodcastIndexOnly,
  wildernessXXXPodcastIndexOnly,
  wrestlingXXXPodcastIndexOnly;

  String get id {
    switch (this) {
      case healthAndFitnessXXXITunesOnly:
        return 'Health & Fitness';
      case kidsAndFamilyXXXITunesOnly:
        return 'Kids & Family';
      case religionAndSpiritualityXXXITunesOnly:
        return 'Religion & Spirituality';
      case societyAndCultureXXXITunesOnly:
        return 'Society & Culture';
      case tvAndFilmXXXITunesOnly:
        return 'TV & Film';
      case trueCrime:
        return 'True Crime';
      default:
        return name
            .replaceAll('XXXITunesOnly', '')
            .replaceAll('XXXPodcastIndexOnly', '')
            .capitalize();
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
      case healthAndFitnessXXXITunesOnly:
        return l10n.healthAndFitness;
      case history:
        return l10n.history;
      case kidsAndFamilyXXXITunesOnly:
        return l10n.kidsAndFamily;
      case leisure:
        return l10n.leisure;
      case music:
        return l10n.music;
      case news:
        return l10n.news;
      case religionAndSpiritualityXXXITunesOnly:
        return l10n.religionAndSpirituality;
      case science:
        return l10n.science;
      case societyAndCultureXXXITunesOnly:
        return l10n.societyAndCulture;
      case sports:
        return l10n.sports;
      case tvAndFilmXXXITunesOnly:
        return l10n.tvAndFilm;
      case technology:
        return l10n.technology;
      case trueCrime:
        return l10n.trueCrime;
      // TODO: localize podcast index genre names
      default:
        return name
            .replaceAll('XXXITunesOnly', '')
            .replaceAll('XXXPodcastIndexOnly', '')
            .capitalize();
    }
  }
}
