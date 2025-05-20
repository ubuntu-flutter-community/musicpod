import '../../extensions/string_x.dart';
import '../../l10n/app_localizations.dart';

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
            .capitalized;
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
      case astronomyXXXPodcastIndexOnly:
        return l10n.astronomyXXXPodcastIndexOnly;
      case automotiveXXXPodcastIndexOnly:
        return l10n.automotiveXXXPodcastIndexOnly;
      case aviationXXXPodcastIndexOnly:
        return l10n.aviationXXXPodcastIndexOnly;
      case baseballXXXPodcastIndexOnly:
        return l10n.baseballXXXPodcastIndexOnly;
      case basketballXXXPodcastIndexOnly:
        return l10n.basketballXXXPodcastIndexOnly;
      case beautyXXXPodcastIndexOnly:
        return l10n.beautyXXXPodcastIndexOnly;
      case booksXXXPodcastIndexOnly:
        return l10n.booksXXXPodcastIndexOnly;
      case buddhismXXXPodcastIndexOnly:
        return l10n.buddhismXXXPodcastIndexOnly;
      case careersXXXPodcastIndexOnly:
        return l10n.careersXXXPodcastIndexOnly;
      case chemistryXXXPodcastIndexOnly:
        return l10n.chemistryXXXPodcastIndexOnly;
      case christianityXXXPodcastIndexOnly:
        return l10n.christianityXXXPodcastIndexOnly;
      case climateXXXPodcastIndexOnly:
        return l10n.climateXXXPodcastIndexOnly;
      case commentaryXXXPodcastIndexOnly:
        return l10n.commentaryXXXPodcastIndexOnly;
      case coursesXXXPodcastIndexOnly:
        return l10n.coursesXXXPodcastIndexOnly;
      case craftsXXXPodcastIndexOnly:
        return l10n.craftsXXXPodcastIndexOnly;
      case cricketXXXPodcastIndexOnly:
        return l10n.cricketXXXPodcastIndexOnly;
      case cryptocurrencyXXXPodcastIndexOnly:
        return l10n.cryptocurrencyXXXPodcastIndexOnly;
      case cultureXXXPodcastIndexOnly:
        return l10n.cultureXXXPodcastIndexOnly;
      case dailyXXXPodcastIndexOnly:
        return l10n.dailyXXXPodcastIndexOnly;
      case designXXXPodcastIndexOnly:
        return l10n.designXXXPodcastIndexOnly;
      case documentaryXXXPodcastIndexOnly:
        return l10n.documentaryXXXPodcastIndexOnly;
      case dramaXXXPodcastIndexOnly:
        return l10n.dramaXXXPodcastIndexOnly;
      case earthXXXPodcastIndexOnly:
        return l10n.earthXXXPodcastIndexOnly;
      case entertainmentXXXPodcastIndexOnly:
        return l10n.entertainmentXXXPodcastIndexOnly;
      case entrepreneurshipXXXPodcastIndexOnly:
        return l10n.entrepreneurshipXXXPodcastIndexOnly;
      case familyXXXPodcastIndexOnly:
        return l10n.familyXXXPodcastIndexOnly;
      case fantasyXXXPodcastIndexOnly:
        return l10n.fantasyXXXPodcastIndexOnly;
      case fashionXXXPodcastIndexOnly:
        return l10n.fashionXXXPodcastIndexOnly;
      case filmXXXPodcastIndexOnly:
        return l10n.filmXXXPodcastIndexOnly;
      case fitnessXXXPodcastIndexOnly:
        return l10n.fitnessXXXPodcastIndexOnly;
      case foodXXXPodcastIndexOnly:
        return l10n.foodXXXPodcastIndexOnly;
      case footballXXXPodcastIndexOnly:
        return l10n.footballXXXPodcastIndexOnly;
      case gamesXXXPodcastIndexOnly:
        return l10n.gamesXXXPodcastIndexOnly;
      case gardenXXXPodcastIndexOnly:
        return l10n.gardenXXXPodcastIndexOnly;
      case golfXXXPodcastIndexOnly:
        return l10n.golfXXXPodcastIndexOnly;
      case healthXXXPodcastIndexOnly:
        return l10n.healthXXXPodcastIndexOnly;
      case hinduismXXXPodcastIndexOnly:
        return l10n.hinduismXXXPodcastIndexOnly;
      case hobbiesXXXPodcastIndexOnly:
        return l10n.hobbiesXXXPodcastIndexOnly;
      case hockeyXXXPodcastIndexOnly:
        return l10n.hockeyXXXPodcastIndexOnly;
      case homeXXXPodcastIndexOnly:
        return l10n.homeXXXPodcastIndexOnly;
      case howToXXXPodcastIndexOnly:
        return l10n.howToXXXPodcastIndexOnly;
      case improvXXXPodcastIndexOnly:
        return l10n.improvXXXPodcastIndexOnly;
      case interviewsXXXPodcastIndexOnly:
        return l10n.interviewsXXXPodcastIndexOnly;
      case investingXXXPodcastIndexOnly:
        return l10n.investingXXXPodcastIndexOnly;
      case islamXXXPodcastIndexOnly:
        return l10n.islamXXXPodcastIndexOnly;
      case journalsXXXPodcastIndexOnly:
        return l10n.journalsXXXPodcastIndexOnly;
      case judaismXXXPodcastIndexOnly:
        return l10n.judaismXXXPodcastIndexOnly;
      case kidsXXXPodcastIndexOnly:
        return l10n.kidsXXXPodcastIndexOnly;
      case languageXXXPodcastIndexOnly:
        return l10n.languageXXXPodcastIndexOnly;
      case learningXXXPodcastIndexOnly:
        return l10n.learningXXXPodcastIndexOnly;
      case lifeXXXPodcastIndexOnly:
        return l10n.lifeXXXPodcastIndexOnly;
      case managementXXXPodcastIndexOnly:
        return l10n.managementXXXPodcastIndexOnly;
      case mangaXXXPodcastIndexOnly:
        return l10n.mangaXXXPodcastIndexOnly;
      case marketingXXXPodcastIndexOnly:
        return l10n.marketingXXXPodcastIndexOnly;
      case mathematicsXXXPodcastIndexOnly:
        return l10n.mathematicsXXXPodcastIndexOnly;
      case medicineXXXPodcastIndexOnly:
        return l10n.medicineXXXPodcastIndexOnly;
      case mentalXXXPodcastIndexOnly:
        return l10n.mentalXXXPodcastIndexOnly;
      case naturalXXXPodcastIndexOnly:
        return l10n.naturalXXXPodcastIndexOnly;
      case natureXXXPodcastIndexOnly:
        return l10n.natureXXXPodcastIndexOnly;
      case nonProfitXXXPodcastIndexOnly:
        return l10n.nonProfitXXXPodcastIndexOnly;
      case nutritionXXXPodcastIndexOnly:
        return l10n.nutritionXXXPodcastIndexOnly;
      case parentingXXXPodcastIndexOnly:
        return l10n.parentingXXXPodcastIndexOnly;
      case performingXXXPodcastIndexOnly:
        return l10n.performingXXXPodcastIndexOnly;
      case personalXXXPodcastIndexOnly:
        return l10n.personalXXXPodcastIndexOnly;
      case petsXXXPodcastIndexOnly:
        return l10n.petsXXXPodcastIndexOnly;
      case philosophyXXXPodcastIndexOnly:
        return l10n.philosophyXXXPodcastIndexOnly;
      case physicsXXXPodcastIndexOnly:
        return l10n.physicsXXXPodcastIndexOnly;
      case placesXXXPodcastIndexOnly:
        return l10n.placesXXXPodcastIndexOnly;
      case politicsXXXPodcastIndexOnly:
        return l10n.politicsXXXPodcastIndexOnly;
      case relationshipsXXXPodcastIndexOnly:
        return l10n.relationshipsXXXPodcastIndexOnly;
      case religionXXXPodcastIndexOnly:
        return l10n.religionXXXPodcastIndexOnly;
      case reviewsXXXPodcastIndexOnly:
        return l10n.reviewsXXXPodcastIndexOnly;
      case rolePlayingXXXPodcastIndexOnly:
        return l10n.rolePlayingXXXPodcastIndexOnly;
      case rugbyXXXPodcastIndexOnly:
        return l10n.rugbyXXXPodcastIndexOnly;
      case runningXXXPodcastIndexOnly:
        return l10n.runningXXXPodcastIndexOnly;
      case selfImprovementXXXPodcastIndexOnly:
        return l10n.selfImprovementXXXPodcastIndexOnly;
      case sexualityXXXPodcastIndexOnly:
        return l10n.sexualityXXXPodcastIndexOnly;
      case soccerXXXPodcastIndexOnly:
        return l10n.soccerXXXPodcastIndexOnly;
      case socialXXXPodcastIndexOnly:
        return l10n.socialXXXPodcastIndexOnly;
      case societyXXXPodcastIndexOnly:
        return l10n.societyXXXPodcastIndexOnly;
      case spiritualityXXXPodcastIndexOnly:
        return l10n.spiritualityXXXPodcastIndexOnly;
      case standUpXXXPodcastIndexOnly:
        return l10n.standUpXXXPodcastIndexOnly;
      case storiesXXXPodcastIndexOnly:
        return l10n.storiesXXXPodcastIndexOnly;
      case swimmingXXXPodcastIndexOnly:
        return l10n.swimmingXXXPodcastIndexOnly;
      case tVXXXPodcastIndexOnly:
        return l10n.tVXXXPodcastIndexOnly;
      case tabletopXXXPodcastIndexOnly:
        return l10n.tabletopXXXPodcastIndexOnly;
      case tennisXXXPodcastIndexOnly:
        return l10n.tennisXXXPodcastIndexOnly;
      case travelXXXPodcastIndexOnly:
        return l10n.travelXXXPodcastIndexOnly;
      case videoGamesXXXPodcastIndexOnly:
        return l10n.videoGamesXXXPodcastIndexOnly;
      case visualXXXPodcastIndexOnly:
        return l10n.visualXXXPodcastIndexOnly;
      case volleyballXXXPodcastIndexOnly:
        return l10n.volleyballXXXPodcastIndexOnly;
      case weatherXXXPodcastIndexOnly:
        return l10n.weatherXXXPodcastIndexOnly;
      case wildernessXXXPodcastIndexOnly:
        return l10n.wildernessXXXPodcastIndexOnly;
      case wrestlingXXXPodcastIndexOnly:
        return l10n.wrestlingXXXPodcastIndexOnly;
      default:
        return name
            .replaceAll('XXXITunesOnly', '')
            .replaceAll('XXXPodcastIndexOnly', '')
            .capitalized;
    }
  }
}
