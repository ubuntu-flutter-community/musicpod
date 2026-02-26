import 'package:collection/collection.dart';

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
  trueCrime,
  afterShows,
  alternative,
  animals,
  animation,

  astronomy,
  automotive,
  aviation,
  baseball,
  basketball,
  beauty,
  books,
  buddhism,
  careers,
  chemistry,
  christianity,
  climate,
  commentary,
  courses,
  crafts,
  cricket,
  cryptocurrency,
  culture,
  daily,
  design,
  documentary,
  drama,
  earth,
  entertainment,
  entrepreneurship,
  family,
  fantasy,
  fashion,
  film,
  fitness,
  food,
  football,
  games,
  garden,
  golf,
  health,
  hinduism,
  hobbies,
  hockey,
  home,
  howTo,
  improv,
  interviews,
  investing,
  islam,
  journals,
  judaism,
  kids,
  language,
  learning,
  life,
  management,
  manga,
  marketing,
  mathematics,
  medicine,
  mental,
  natural,
  nature,
  nonProfit,
  nutrition,
  parenting,
  performing,
  personal,
  pets,
  philosophy,
  physics,
  places,
  politics,
  relationships,
  religion,
  reviews,
  rolePlaying,
  rugby,
  running,
  selfImprovement,
  sexuality,
  soccer,
  social,
  society,
  spirituality,
  standUp,
  stories,
  swimming,
  tV,
  tabletop,
  tennis,
  travel,
  videoGames,
  visual,
  volleyball,
  weather,
  wilderness,
  wrestling;

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
        return name
            .replaceAll('', '')
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
      case astronomy:
        return l10n.astronomyXXXPodcastIndexOnly;
      case automotive:
        return l10n.automotiveXXXPodcastIndexOnly;
      case aviation:
        return l10n.aviationXXXPodcastIndexOnly;
      case baseball:
        return l10n.baseballXXXPodcastIndexOnly;
      case basketball:
        return l10n.basketballXXXPodcastIndexOnly;
      case beauty:
        return l10n.beautyXXXPodcastIndexOnly;
      case books:
        return l10n.booksXXXPodcastIndexOnly;
      case buddhism:
        return l10n.buddhismXXXPodcastIndexOnly;
      case careers:
        return l10n.careersXXXPodcastIndexOnly;
      case chemistry:
        return l10n.chemistryXXXPodcastIndexOnly;
      case christianity:
        return l10n.christianityXXXPodcastIndexOnly;
      case climate:
        return l10n.climateXXXPodcastIndexOnly;
      case commentary:
        return l10n.commentaryXXXPodcastIndexOnly;
      case courses:
        return l10n.coursesXXXPodcastIndexOnly;
      case crafts:
        return l10n.craftsXXXPodcastIndexOnly;
      case cricket:
        return l10n.cricketXXXPodcastIndexOnly;
      case cryptocurrency:
        return l10n.cryptocurrencyXXXPodcastIndexOnly;
      case culture:
        return l10n.cultureXXXPodcastIndexOnly;
      case daily:
        return l10n.dailyXXXPodcastIndexOnly;
      case design:
        return l10n.designXXXPodcastIndexOnly;
      case documentary:
        return l10n.documentaryXXXPodcastIndexOnly;
      case drama:
        return l10n.dramaXXXPodcastIndexOnly;
      case earth:
        return l10n.earthXXXPodcastIndexOnly;
      case entertainment:
        return l10n.entertainmentXXXPodcastIndexOnly;
      case entrepreneurship:
        return l10n.entrepreneurshipXXXPodcastIndexOnly;
      case family:
        return l10n.familyXXXPodcastIndexOnly;
      case fantasy:
        return l10n.fantasyXXXPodcastIndexOnly;
      case fashion:
        return l10n.fashionXXXPodcastIndexOnly;
      case film:
        return l10n.filmXXXPodcastIndexOnly;
      case fitness:
        return l10n.fitnessXXXPodcastIndexOnly;
      case food:
        return l10n.foodXXXPodcastIndexOnly;
      case football:
        return l10n.footballXXXPodcastIndexOnly;
      case games:
        return l10n.gamesXXXPodcastIndexOnly;
      case garden:
        return l10n.gardenXXXPodcastIndexOnly;
      case golf:
        return l10n.golfXXXPodcastIndexOnly;
      case health:
        return l10n.healthXXXPodcastIndexOnly;
      case hinduism:
        return l10n.hinduismXXXPodcastIndexOnly;
      case hobbies:
        return l10n.hobbiesXXXPodcastIndexOnly;
      case hockey:
        return l10n.hockeyXXXPodcastIndexOnly;
      case home:
        return l10n.homeXXXPodcastIndexOnly;
      case howTo:
        return l10n.howToXXXPodcastIndexOnly;
      case improv:
        return l10n.improvXXXPodcastIndexOnly;
      case interviews:
        return l10n.interviewsXXXPodcastIndexOnly;
      case investing:
        return l10n.investingXXXPodcastIndexOnly;
      case islam:
        return l10n.islamXXXPodcastIndexOnly;
      case journals:
        return l10n.journalsXXXPodcastIndexOnly;
      case judaism:
        return l10n.judaismXXXPodcastIndexOnly;
      case kids:
        return l10n.kidsXXXPodcastIndexOnly;
      case language:
        return l10n.languageXXXPodcastIndexOnly;
      case learning:
        return l10n.learningXXXPodcastIndexOnly;
      case life:
        return l10n.lifeXXXPodcastIndexOnly;
      case management:
        return l10n.managementXXXPodcastIndexOnly;
      case manga:
        return l10n.mangaXXXPodcastIndexOnly;
      case marketing:
        return l10n.marketingXXXPodcastIndexOnly;
      case mathematics:
        return l10n.mathematicsXXXPodcastIndexOnly;
      case medicine:
        return l10n.medicineXXXPodcastIndexOnly;
      case mental:
        return l10n.mentalXXXPodcastIndexOnly;
      case natural:
        return l10n.naturalXXXPodcastIndexOnly;
      case nature:
        return l10n.natureXXXPodcastIndexOnly;
      case nonProfit:
        return l10n.nonProfitXXXPodcastIndexOnly;
      case nutrition:
        return l10n.nutritionXXXPodcastIndexOnly;
      case parenting:
        return l10n.parentingXXXPodcastIndexOnly;
      case performing:
        return l10n.performingXXXPodcastIndexOnly;
      case personal:
        return l10n.personalXXXPodcastIndexOnly;
      case pets:
        return l10n.petsXXXPodcastIndexOnly;
      case philosophy:
        return l10n.philosophyXXXPodcastIndexOnly;
      case physics:
        return l10n.physicsXXXPodcastIndexOnly;
      case places:
        return l10n.placesXXXPodcastIndexOnly;
      case politics:
        return l10n.politicsXXXPodcastIndexOnly;
      case relationships:
        return l10n.relationshipsXXXPodcastIndexOnly;
      case religion:
        return l10n.religionXXXPodcastIndexOnly;
      case reviews:
        return l10n.reviewsXXXPodcastIndexOnly;
      case rolePlaying:
        return l10n.rolePlayingXXXPodcastIndexOnly;
      case rugby:
        return l10n.rugbyXXXPodcastIndexOnly;
      case running:
        return l10n.runningXXXPodcastIndexOnly;
      case selfImprovement:
        return l10n.selfImprovementXXXPodcastIndexOnly;
      case sexuality:
        return l10n.sexualityXXXPodcastIndexOnly;
      case soccer:
        return l10n.soccerXXXPodcastIndexOnly;
      case social:
        return l10n.socialXXXPodcastIndexOnly;
      case society:
        return l10n.societyXXXPodcastIndexOnly;
      case spirituality:
        return l10n.spiritualityXXXPodcastIndexOnly;
      case standUp:
        return l10n.standUpXXXPodcastIndexOnly;
      case stories:
        return l10n.storiesXXXPodcastIndexOnly;
      case swimming:
        return l10n.swimmingXXXPodcastIndexOnly;
      case tV:
        return l10n.tVXXXPodcastIndexOnly;
      case tabletop:
        return l10n.tabletopXXXPodcastIndexOnly;
      case tennis:
        return l10n.tennisXXXPodcastIndexOnly;
      case travel:
        return l10n.travelXXXPodcastIndexOnly;
      case videoGames:
        return l10n.videoGamesXXXPodcastIndexOnly;
      case visual:
        return l10n.visualXXXPodcastIndexOnly;
      case volleyball:
        return l10n.volleyballXXXPodcastIndexOnly;
      case weather:
        return l10n.weatherXXXPodcastIndexOnly;
      case wilderness:
        return l10n.wildernessXXXPodcastIndexOnly;
      case wrestling:
        return l10n.wrestlingXXXPodcastIndexOnly;
      default:
        return name.capitalized;
    }
  }

  static PodcastGenre fromString(String id) {
    try {
      return PodcastGenre.values.firstWhereOrNull(
            (genre) => id.toLowerCase().contains(genre.id.toLowerCase()),
          ) ??
          PodcastGenre.all;
    } catch (e) {
      return PodcastGenre.all;
    }
  }
}
