import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('eu'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sk'),
    Locale('sv'),
    Locale('ta'),
    Locale('tr'),
    Locale('zh'),
    Locale('zh', 'HK'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat All'**
  String get repeatAll;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @fastForward30.
  ///
  /// In en, this message translates to:
  /// **'30 seconds fast forward'**
  String get fastForward30;

  /// No description provided for @rewind10.
  ///
  /// In en, this message translates to:
  /// **'Rewind 10 seconds'**
  String get rewind10;

  /// No description provided for @fullWindow.
  ///
  /// In en, this message translates to:
  /// **'Enter full window mode'**
  String get fullWindow;

  /// No description provided for @leaveFullWindow.
  ///
  /// In en, this message translates to:
  /// **'Leave full window mode'**
  String get leaveFullWindow;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Enter full screen mode'**
  String get fullScreen;

  /// No description provided for @leaveFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Leave full screen mode'**
  String get leaveFullScreen;

  /// No description provided for @playbackRate.
  ///
  /// In en, this message translates to:
  /// **'Playback rate'**
  String get playbackRate;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @localAudio.
  ///
  /// In en, this message translates to:
  /// **'Local Audio'**
  String get localAudio;

  /// No description provided for @localAudioDescription.
  ///
  /// In en, this message translates to:
  /// **'Your music collection, stored on your computer.'**
  String get localAudioDescription;

  /// No description provided for @localAudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection needed'**
  String get localAudioSubtitle;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @radio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radio;

  /// No description provided for @podcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get podcasts;

  /// No description provided for @podcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get podcast;

  /// No description provided for @likedSongs.
  ///
  /// In en, this message translates to:
  /// **'Liked Songs'**
  String get likedSongs;

  /// No description provided for @likedSongsDescription.
  ///
  /// In en, this message translates to:
  /// **'All audio you liked. Local or from the internet.'**
  String get likedSongsDescription;

  /// No description provided for @likedSongsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Press the heart button to add more titles.'**
  String get likedSongsSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addTo.
  ///
  /// In en, this message translates to:
  /// **'Add to:'**
  String get addTo;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get deletePlaylist;

  /// No description provided for @createNewPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create new playlist'**
  String get createNewPlaylist;

  /// No description provided for @playlistDialogTitleNew.
  ///
  /// In en, this message translates to:
  /// **'Add playlist'**
  String get playlistDialogTitleNew;

  /// No description provided for @playlistDialogTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit playlist'**
  String get playlistDialogTitleEdit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndAuthorize.
  ///
  /// In en, this message translates to:
  /// **'Save and authorize'**
  String get saveAndAuthorize;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titles.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get titles;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @showArtistPage.
  ///
  /// In en, this message translates to:
  /// **'Show artist page'**
  String get showArtistPage;

  /// No description provided for @showAlbumPage.
  ///
  /// In en, this message translates to:
  /// **'Show album page'**
  String get showAlbumPage;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @albumArtist.
  ///
  /// In en, this message translates to:
  /// **'Album artist'**
  String get albumArtist;

  /// No description provided for @albumArtists.
  ///
  /// In en, this message translates to:
  /// **'Album artists'**
  String get albumArtists;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @trackNumber.
  ///
  /// In en, this message translates to:
  /// **'Track number'**
  String get trackNumber;

  /// No description provided for @diskNumber.
  ///
  /// In en, this message translates to:
  /// **'CD number'**
  String get diskNumber;

  /// No description provided for @totalDisks.
  ///
  /// In en, this message translates to:
  /// **'CDs'**
  String get totalDisks;

  /// No description provided for @searchLocalAudioHint.
  ///
  /// In en, this message translates to:
  /// **'Search local audio'**
  String get searchLocalAudioHint;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYou;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noPodcastFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry, no podcast was found with this search query.'**
  String get noPodcastFound;

  /// No description provided for @noPodcastChartsFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry, no charts available for this country or category.'**
  String get noPodcastChartsFound;

  /// No description provided for @noPodcastSubsFound.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t subscribed to any podcast yet.'**
  String get noPodcastSubsFound;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @arts.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get arts;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @comedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get comedy;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @fiction.
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get fiction;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @healthAndFitness.
  ///
  /// In en, this message translates to:
  /// **'Health & Fitness'**
  String get healthAndFitness;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @kidsAndFamily.
  ///
  /// In en, this message translates to:
  /// **'Kids & Family'**
  String get kidsAndFamily;

  /// No description provided for @leisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get leisure;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @religionAndSpirituality.
  ///
  /// In en, this message translates to:
  /// **'Religion & Spirituality'**
  String get religionAndSpirituality;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @societyAndCulture.
  ///
  /// In en, this message translates to:
  /// **'Society & Culture'**
  String get societyAndCulture;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @tvAndFilm.
  ///
  /// In en, this message translates to:
  /// **'TV & Film'**
  String get tvAndFilm;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @trueCrime.
  ///
  /// In en, this message translates to:
  /// **'True Crime'**
  String get trueCrime;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// No description provided for @offlineDescription.
  ///
  /// In en, this message translates to:
  /// **'It looks like your computer is not connected to the internet.'**
  String get offlineDescription;

  /// No description provided for @newEpisodeAvailable.
  ///
  /// In en, this message translates to:
  /// **'New episode available:'**
  String get newEpisodeAvailable;

  /// No description provided for @noStationFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry, no stations found with this search query'**
  String get noStationFound;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @noStarredStations.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t starred any stations yet.'**
  String get noStarredStations;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @station.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get station;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @failedToImport.
  ///
  /// In en, this message translates to:
  /// **'Failed to import the following files:'**
  String get failedToImport;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get clearQueue;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @decreaseSearchLimit.
  ///
  /// In en, this message translates to:
  /// **'Please decrease the search limit for'**
  String get decreaseSearchLimit;

  /// No description provided for @podcastFeedIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this podcast\'s feed is empty.'**
  String get podcastFeedIsEmpty;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @noLocalTitlesFound.
  ///
  /// In en, this message translates to:
  /// **'It looks like your local music collection is empty. Check your library location in the settings.'**
  String get noLocalTitlesFound;

  /// No description provided for @noLocalSearchFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry, no local music found for this search query.'**
  String get noLocalSearchFound;

  /// No description provided for @buyMusicOnline.
  ///
  /// In en, this message translates to:
  /// **'Maybe here you\'ll find music that you\'d like to buy:'**
  String get buyMusicOnline;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @findUsOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'Find us on GitHub'**
  String get findUsOnGitHub;

  /// No description provided for @musicPodSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Music, Radio and Podcast Player'**
  String get musicPodSubTitle;

  /// No description provided for @pickMusicCollection.
  ///
  /// In en, this message translates to:
  /// **'Pick your music collection'**
  String get pickMusicCollection;

  /// No description provided for @newEpisode.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newEpisode;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @queueConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to enqueue {length} medias?'**
  String queueConfirmMessage(String length);

  /// No description provided for @emptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty.'**
  String get emptyPlaylist;

  /// No description provided for @copiedToClipBoard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard:'**
  String get copiedToClipBoard;

  /// No description provided for @copyToClipBoard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipBoard;

  /// No description provided for @insertIntoQueue.
  ///
  /// In en, this message translates to:
  /// **'Insert into queue'**
  String get insertIntoQueue;

  /// No description provided for @insertedIntoQueue.
  ///
  /// In en, this message translates to:
  /// **'Inserted to queue: {name}'**
  String insertedIntoQueue(String name);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @localAudioCacheSuggestion.
  ///
  /// In en, this message translates to:
  /// **'You have {length} local audio files. Do you want to create a cache to improve start-up time?'**
  String localAudioCacheSuggestion(String length);

  /// No description provided for @noThankYou.
  ///
  /// In en, this message translates to:
  /// **'No, thank you.'**
  String get noThankYou;

  /// No description provided for @recreateLocalAudioCache.
  ///
  /// In en, this message translates to:
  /// **'Recreate local audio cache'**
  String get recreateLocalAudioCache;

  /// No description provided for @useALocalAudioCache.
  ///
  /// In en, this message translates to:
  /// **'Use local audio cache'**
  String get useALocalAudioCache;

  /// No description provided for @newEpisodes.
  ///
  /// In en, this message translates to:
  /// **'New Episodes'**
  String get newEpisodes;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get addToCollection;

  /// No description provided for @removeFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Remove from collection'**
  String get removeFromCollection;

  /// No description provided for @loadingPodcastFeed.
  ///
  /// In en, this message translates to:
  /// **'Loading podcast feed...'**
  String get loadingPodcastFeed;

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started: {name}'**
  String downloadStarted(String name);

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled: {name}'**
  String downloadCancelled(String name);

  /// No description provided for @downloadFinished.
  ///
  /// In en, this message translates to:
  /// **'Download finished: {name}'**
  String downloadFinished(String name);

  /// No description provided for @markAllEpisodesAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark all episodes as done'**
  String get markAllEpisodesAsDone;

  /// No description provided for @markEpisodeAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark episode as done'**
  String get markEpisodeAsDone;

  /// No description provided for @hideCompletedEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Hide completed episodes'**
  String get hideCompletedEpisodes;

  /// No description provided for @showCompletedEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Show completed episodes'**
  String get showCompletedEpisodes;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings'**
  String get resetAllSettings;

  /// No description provided for @resetAllSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure to reset all settings, your podcast subscriptions, your podcast progress, your starred stations and your pinned albums?  The app will be closed after and you need to re-open it.'**
  String get resetAllSettingsConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @isMaybeLowBandwidthDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'No WIFI/Ethernet'**
  String get isMaybeLowBandwidthDialogTitle;

  /// No description provided for @isMaybeLowBandwidthDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You are not connected to WIFI or Ethernet. Do you want to enable data safe mode?'**
  String get isMaybeLowBandwidthDialogBody;

  /// No description provided for @isBackInWifiDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Back in WIFI/Ethernet'**
  String get isBackInWifiDialogTitle;

  /// No description provided for @isBackInWifiDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You are connected to WIFI or Ethernet. Do you want to disable data safe mode?'**
  String get isBackInWifiDialogBody;

  /// No description provided for @enableDataSafeModeSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Data safe mode'**
  String get enableDataSafeModeSettingTitle;

  /// No description provided for @dataSafeModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Mobile Connection: Data safe mode enabled.'**
  String get dataSafeModeEnabled;

  /// No description provided for @dataSafeModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Wifi/Ethernet: Data safe mode disabled.'**
  String get dataSafeModeDisabled;

  /// No description provided for @enableDataSafeModeSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'When active the player will not try to download artwork of titles send from radio stations.'**
  String get enableDataSafeModeSettingDescription;

  /// No description provided for @stopToNotifyAboutDataSafeMode.
  ///
  /// In en, this message translates to:
  /// **'Stop to notify me'**
  String get stopToNotifyAboutDataSafeMode;

  /// No description provided for @notifyMeAboutDataSafeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Data safe mode notifications'**
  String get notifyMeAboutDataSafeModeTitle;

  /// No description provided for @notifyMeAboutDataSafeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify me about data safe mode'**
  String get notifyMeAboutDataSafeModeDescription;

  /// No description provided for @resourceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Device resources'**
  String get resourceSectionTitle;

  /// No description provided for @downloadsOnly.
  ///
  /// In en, this message translates to:
  /// **'Downloads only'**
  String get downloadsOnly;

  /// No description provided for @downloadsDirectory.
  ///
  /// In en, this message translates to:
  /// **'Location of your downloads'**
  String get downloadsDirectory;

  /// No description provided for @downloadsDirectoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Make sure MusicPod can access this directory!'**
  String get downloadsDirectoryDescription;

  /// No description provided for @downloadsChangeWarning.
  ///
  /// In en, this message translates to:
  /// **'Changing the downloads directory deletes all current downloads. Do you want to proceed?'**
  String get downloadsChangeWarning;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @noRadioServerFound.
  ///
  /// In en, this message translates to:
  /// **'No radio server found'**
  String get noRadioServerFound;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get connectedTo;

  /// No description provided for @connectedToDiscord.
  ///
  /// In en, this message translates to:
  /// **'Connected to Discord'**
  String get connectedToDiscord;

  /// No description provided for @disconnectedFrom.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from'**
  String get disconnectedFrom;

  /// No description provided for @disconnectedFromDiscord.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from Discord'**
  String get disconnectedFromDiscord;

  /// No description provided for @tryReconnect.
  ///
  /// In en, this message translates to:
  /// **'Try reconnect'**
  String get tryReconnect;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to'**
  String get addedTo;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @removeFrom.
  ///
  /// In en, this message translates to:
  /// **'Remove from'**
  String get removeFrom;

  /// No description provided for @noCountryFound.
  ///
  /// In en, this message translates to:
  /// **'No country can be found with this name. You can also use phone prefixes such as +49'**
  String get noCountryFound;

  /// No description provided for @noStarredTags.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t star any tags yet'**
  String get noStarredTags;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// No description provided for @contributors.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @useMoreAnimationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use more animations'**
  String get useMoreAnimationsTitle;

  /// No description provided for @useMoreAnimationsDescription.
  ///
  /// In en, this message translates to:
  /// **'This will slightly increase the CPU usage, which might be undesired on older hardware.'**
  String get useMoreAnimationsDescription;

  /// No description provided for @showPositionDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Show position / duration in bottom player'**
  String get showPositionDurationTitle;

  /// No description provided for @showPositionDurationDescription.
  ///
  /// In en, this message translates to:
  /// **'It is otherwise always shown on track hover and in the full screen player.'**
  String get showPositionDurationDescription;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @dependencies.
  ///
  /// In en, this message translates to:
  /// **'Dependencies'**
  String get dependencies;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @podcastProvider.
  ///
  /// In en, this message translates to:
  /// **'Podcast Provider'**
  String get podcastProvider;

  /// No description provided for @iTunes.
  ///
  /// In en, this message translates to:
  /// **'iTunes'**
  String get iTunes;

  /// No description provided for @podcastIndex.
  ///
  /// In en, this message translates to:
  /// **'Podcast Index'**
  String get podcastIndex;

  /// No description provided for @usePodcastIndex.
  ///
  /// In en, this message translates to:
  /// **'Use Podcast Index instead of iTunes'**
  String get usePodcastIndex;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @requiresAppRestart.
  ///
  /// In en, this message translates to:
  /// **'Requires app restart'**
  String get requiresAppRestart;

  /// No description provided for @musicCollectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Music collection location'**
  String get musicCollectionLocation;

  /// No description provided for @astronomyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Astronomy'**
  String get astronomyXXXPodcastIndexOnly;

  /// No description provided for @automotiveXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get automotiveXXXPodcastIndexOnly;

  /// No description provided for @aviationXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Aviation'**
  String get aviationXXXPodcastIndexOnly;

  /// No description provided for @baseballXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Baseball'**
  String get baseballXXXPodcastIndexOnly;

  /// No description provided for @basketballXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get basketballXXXPodcastIndexOnly;

  /// No description provided for @beautyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beautyXXXPodcastIndexOnly;

  /// No description provided for @booksXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksXXXPodcastIndexOnly;

  /// No description provided for @buddhismXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Buddhism'**
  String get buddhismXXXPodcastIndexOnly;

  /// No description provided for @careersXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Careers'**
  String get careersXXXPodcastIndexOnly;

  /// No description provided for @chemistryXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get chemistryXXXPodcastIndexOnly;

  /// No description provided for @christianityXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Christianity'**
  String get christianityXXXPodcastIndexOnly;

  /// No description provided for @climateXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get climateXXXPodcastIndexOnly;

  /// No description provided for @commentaryXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get commentaryXXXPodcastIndexOnly;

  /// No description provided for @coursesXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesXXXPodcastIndexOnly;

  /// No description provided for @craftsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Crafts'**
  String get craftsXXXPodcastIndexOnly;

  /// No description provided for @cricketXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Cricket'**
  String get cricketXXXPodcastIndexOnly;

  /// No description provided for @cryptocurrencyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Cryptocurrency'**
  String get cryptocurrencyXXXPodcastIndexOnly;

  /// No description provided for @cultureXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get cultureXXXPodcastIndexOnly;

  /// No description provided for @dailyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyXXXPodcastIndexOnly;

  /// No description provided for @designXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get designXXXPodcastIndexOnly;

  /// No description provided for @documentaryXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get documentaryXXXPodcastIndexOnly;

  /// No description provided for @dramaXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get dramaXXXPodcastIndexOnly;

  /// No description provided for @earthXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get earthXXXPodcastIndexOnly;

  /// No description provided for @entertainmentXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainmentXXXPodcastIndexOnly;

  /// No description provided for @entrepreneurshipXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneurship'**
  String get entrepreneurshipXXXPodcastIndexOnly;

  /// No description provided for @familyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyXXXPodcastIndexOnly;

  /// No description provided for @fantasyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get fantasyXXXPodcastIndexOnly;

  /// No description provided for @fashionXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get fashionXXXPodcastIndexOnly;

  /// No description provided for @filmXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Film'**
  String get filmXXXPodcastIndexOnly;

  /// No description provided for @fitnessXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitnessXXXPodcastIndexOnly;

  /// No description provided for @foodXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodXXXPodcastIndexOnly;

  /// No description provided for @footballXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get footballXXXPodcastIndexOnly;

  /// No description provided for @gamesXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesXXXPodcastIndexOnly;

  /// No description provided for @gardenXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get gardenXXXPodcastIndexOnly;

  /// No description provided for @golfXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get golfXXXPodcastIndexOnly;

  /// No description provided for @healthXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthXXXPodcastIndexOnly;

  /// No description provided for @hinduismXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Hinduism'**
  String get hinduismXXXPodcastIndexOnly;

  /// No description provided for @hobbiesXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get hobbiesXXXPodcastIndexOnly;

  /// No description provided for @hockeyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Hockey'**
  String get hockeyXXXPodcastIndexOnly;

  /// No description provided for @homeXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeXXXPodcastIndexOnly;

  /// No description provided for @howToXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'How To'**
  String get howToXXXPodcastIndexOnly;

  /// No description provided for @improvXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Improv'**
  String get improvXXXPodcastIndexOnly;

  /// No description provided for @interviewsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get interviewsXXXPodcastIndexOnly;

  /// No description provided for @investingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Investing'**
  String get investingXXXPodcastIndexOnly;

  /// No description provided for @islamXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get islamXXXPodcastIndexOnly;

  /// No description provided for @journalsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get journalsXXXPodcastIndexOnly;

  /// No description provided for @judaismXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Judaism'**
  String get judaismXXXPodcastIndexOnly;

  /// No description provided for @kidsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kidsXXXPodcastIndexOnly;

  /// No description provided for @languageXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageXXXPodcastIndexOnly;

  /// No description provided for @learningXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learningXXXPodcastIndexOnly;

  /// No description provided for @lifeXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Life'**
  String get lifeXXXPodcastIndexOnly;

  /// No description provided for @managementXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementXXXPodcastIndexOnly;

  /// No description provided for @mangaXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get mangaXXXPodcastIndexOnly;

  /// No description provided for @marketingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketingXXXPodcastIndexOnly;

  /// No description provided for @mathematicsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathematicsXXXPodcastIndexOnly;

  /// No description provided for @medicineXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicineXXXPodcastIndexOnly;

  /// No description provided for @mentalXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Mental'**
  String get mentalXXXPodcastIndexOnly;

  /// No description provided for @naturalXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get naturalXXXPodcastIndexOnly;

  /// No description provided for @natureXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get natureXXXPodcastIndexOnly;

  /// No description provided for @nonProfitXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Non Profit'**
  String get nonProfitXXXPodcastIndexOnly;

  /// No description provided for @nutritionXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionXXXPodcastIndexOnly;

  /// No description provided for @parentingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Parenting'**
  String get parentingXXXPodcastIndexOnly;

  /// No description provided for @performingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Performing'**
  String get performingXXXPodcastIndexOnly;

  /// No description provided for @personalXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalXXXPodcastIndexOnly;

  /// No description provided for @petsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get petsXXXPodcastIndexOnly;

  /// No description provided for @philosophyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Philosophy'**
  String get philosophyXXXPodcastIndexOnly;

  /// No description provided for @physicsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get physicsXXXPodcastIndexOnly;

  /// No description provided for @placesXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get placesXXXPodcastIndexOnly;

  /// No description provided for @politicsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get politicsXXXPodcastIndexOnly;

  /// No description provided for @relationshipsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get relationshipsXXXPodcastIndexOnly;

  /// No description provided for @religionXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religionXXXPodcastIndexOnly;

  /// No description provided for @reviewsXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsXXXPodcastIndexOnly;

  /// No description provided for @rolePlayingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Role Playing'**
  String get rolePlayingXXXPodcastIndexOnly;

  /// No description provided for @rugbyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Rugby'**
  String get rugbyXXXPodcastIndexOnly;

  /// No description provided for @runningXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runningXXXPodcastIndexOnly;

  /// No description provided for @selfImprovementXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Self Improvement'**
  String get selfImprovementXXXPodcastIndexOnly;

  /// No description provided for @sexualityXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Sexuality'**
  String get sexualityXXXPodcastIndexOnly;

  /// No description provided for @soccerXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Soccer'**
  String get soccerXXXPodcastIndexOnly;

  /// No description provided for @socialXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialXXXPodcastIndexOnly;

  /// No description provided for @societyXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get societyXXXPodcastIndexOnly;

  /// No description provided for @spiritualityXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Spirituality'**
  String get spiritualityXXXPodcastIndexOnly;

  /// No description provided for @standUpXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'StandUp'**
  String get standUpXXXPodcastIndexOnly;

  /// No description provided for @storiesXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get storiesXXXPodcastIndexOnly;

  /// No description provided for @swimmingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimmingXXXPodcastIndexOnly;

  /// No description provided for @tVXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get tVXXXPodcastIndexOnly;

  /// No description provided for @tabletopXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Tabletop'**
  String get tabletopXXXPodcastIndexOnly;

  /// No description provided for @tennisXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get tennisXXXPodcastIndexOnly;

  /// No description provided for @travelXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travelXXXPodcastIndexOnly;

  /// No description provided for @videoGamesXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Video Games'**
  String get videoGamesXXXPodcastIndexOnly;

  /// No description provided for @visualXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get visualXXXPodcastIndexOnly;

  /// No description provided for @volleyballXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get volleyballXXXPodcastIndexOnly;

  /// No description provided for @weatherXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherXXXPodcastIndexOnly;

  /// No description provided for @wildernessXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Wilderness'**
  String get wildernessXXXPodcastIndexOnly;

  /// No description provided for @wrestlingXXXPodcastIndexOnly.
  ///
  /// In en, this message translates to:
  /// **'Wrestling'**
  String get wrestlingXXXPodcastIndexOnly;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @showMetaData.
  ///
  /// In en, this message translates to:
  /// **'Show metadata'**
  String get showMetaData;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @writeMetadata.
  ///
  /// In en, this message translates to:
  /// **'Write metadata'**
  String get writeMetadata;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @pinAlbum.
  ///
  /// In en, this message translates to:
  /// **'Pin album to sidebar'**
  String get pinAlbum;

  /// No description provided for @unPinAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unpin album from sidebar'**
  String get unPinAlbum;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @hearingHistory.
  ///
  /// In en, this message translates to:
  /// **'Hearing history'**
  String get hearingHistory;

  /// No description provided for @emptyHearingHistory.
  ///
  /// In en, this message translates to:
  /// **'You did not listen to radio in this app session yet'**
  String get emptyHearingHistory;

  /// No description provided for @searchForRadioStationsWithGenreName.
  ///
  /// In en, this message translates to:
  /// **'Search for radio stations with this genre'**
  String get searchForRadioStationsWithGenreName;

  /// No description provided for @clearPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete all media from the playlist'**
  String get clearPlaylist;

  /// No description provided for @editPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Edit playlist'**
  String get editPlaylist;

  /// No description provided for @stationUrl.
  ///
  /// In en, this message translates to:
  /// **'Station Url'**
  String get stationUrl;

  /// No description provided for @podcastFeedUrl.
  ///
  /// In en, this message translates to:
  /// **'Podcast feed url'**
  String get podcastFeedUrl;

  /// No description provided for @stationName.
  ///
  /// In en, this message translates to:
  /// **'Station name'**
  String get stationName;

  /// No description provided for @podcastName.
  ///
  /// In en, this message translates to:
  /// **'Podcast name'**
  String get podcastName;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'Url'**
  String get url;

  /// No description provided for @loadFromFileOptional.
  ///
  /// In en, this message translates to:
  /// **'Load from file (optional)'**
  String get loadFromFileOptional;

  /// No description provided for @exportPinnedAlbumsToM3UFiles.
  ///
  /// In en, this message translates to:
  /// **'Export pinned albums to M3U files'**
  String get exportPinnedAlbumsToM3UFiles;

  /// No description provided for @exportPinnedAlbumToM3UFile.
  ///
  /// In en, this message translates to:
  /// **'Export pinned albums to M3U file'**
  String get exportPinnedAlbumToM3UFile;

  /// No description provided for @exportPlaylistToM3UFile.
  ///
  /// In en, this message translates to:
  /// **'Export playlist to M3U'**
  String get exportPlaylistToM3UFile;

  /// No description provided for @exportPlaylistsAndAlbumsToM3UFiles.
  ///
  /// In en, this message translates to:
  /// **'Export playlists and albums to M3U files'**
  String get exportPlaylistsAndAlbumsToM3UFiles;

  /// No description provided for @exportPodcastsToOpmlFile.
  ///
  /// In en, this message translates to:
  /// **'Export podcasts to OPML file'**
  String get exportPodcastsToOpmlFile;

  /// No description provided for @importPodcastsFromOpmlFile.
  ///
  /// In en, this message translates to:
  /// **'Import podcasts from OPML file'**
  String get importPodcastsFromOpmlFile;

  /// No description provided for @exportStarredStationsToOpmlFile.
  ///
  /// In en, this message translates to:
  /// **'Export starred stations to OPML file'**
  String get exportStarredStationsToOpmlFile;

  /// No description provided for @importStarredStationsFromOpmlFile.
  ///
  /// In en, this message translates to:
  /// **'Import starred stations from OPML file'**
  String get importStarredStationsFromOpmlFile;

  /// No description provided for @removeAllStarredStations.
  ///
  /// In en, this message translates to:
  /// **'Remove all starred stations'**
  String get removeAllStarredStations;

  /// No description provided for @removeAllStarredStationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all starred stations?'**
  String get removeAllStarredStationsConfirm;

  /// No description provided for @removeAllStarredStationsDescription.
  ///
  /// In en, this message translates to:
  /// **'This will remove all your starred stations.'**
  String get removeAllStarredStationsDescription;

  /// No description provided for @removeAllPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Remove all podcasts'**
  String get removeAllPodcasts;

  /// No description provided for @removeAllPodcastsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all podcasts?'**
  String get removeAllPodcastsConfirm;

  /// No description provided for @removeAllPodcastsDescription.
  ///
  /// In en, this message translates to:
  /// **'This will remove all your podcast subscriptions and progress.'**
  String get removeAllPodcastsDescription;

  /// No description provided for @customContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add custom content'**
  String get customContentTitle;

  /// No description provided for @customContentDescription.
  ///
  /// In en, this message translates to:
  /// **'If you do not want to use the radiobrowser or podcast search feature you can add your own content here, or you can add empty playlists or import playlists from M3U and PLS files.'**
  String get customContentDescription;

  /// No description provided for @setPlaylistNameAndAddMoreLater.
  ///
  /// In en, this message translates to:
  /// **'Set playlist name and add more titles later'**
  String get setPlaylistNameAndAddMoreLater;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @searchOnline.
  ///
  /// In en, this message translates to:
  /// **'Search online'**
  String get searchOnline;

  /// No description provided for @shareThisEpisode.
  ///
  /// In en, this message translates to:
  /// **'Share this episode'**
  String get shareThisEpisode;

  /// No description provided for @downloadEpisode.
  ///
  /// In en, this message translates to:
  /// **'Download episode'**
  String get downloadEpisode;

  /// No description provided for @removeDownloadEpisode.
  ///
  /// In en, this message translates to:
  /// **'Remove episode download'**
  String get removeDownloadEpisode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @radioTagDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'This station sends a lot of tags.'**
  String get radioTagDisclaimerTitle;

  /// No description provided for @radioTagDisclaimerSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Sometimes stations send tags that do not match music genres. MusicPod is not responsible for the content!'**
  String get radioTagDisclaimerSubTitle;

  /// No description provided for @podcastFeedLoadingTimeout.
  ///
  /// In en, this message translates to:
  /// **'Loading the podcast feed takes longer than usual...'**
  String get podcastFeedLoadingTimeout;

  /// No description provided for @gitHubClientConnectError.
  ///
  /// In en, this message translates to:
  /// **'Could not load online version from GitHub.'**
  String get gitHubClientConnectError;

  /// No description provided for @replayEpisode.
  ///
  /// In en, this message translates to:
  /// **'Replay episode'**
  String get replayEpisode;

  /// No description provided for @replayAllEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Replay all episodes'**
  String get replayAllEpisodes;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to check for updates for {length} podcasts?'**
  String checkForUpdatesConfirm(Object length);

  /// No description provided for @playbackWillStopIn.
  ///
  /// In en, this message translates to:
  /// **'Playback will stop in: {duration} ({timeOfDay})'**
  String playbackWillStopIn(Object duration, Object timeOfDay);

  /// No description provided for @schedulePlaybackStopTimer.
  ///
  /// In en, this message translates to:
  /// **'Schedule a time to stop playback'**
  String get schedulePlaybackStopTimer;

  /// No description provided for @alwaysAsk.
  ///
  /// In en, this message translates to:
  /// **'Always ask'**
  String get alwaysAsk;

  /// No description provided for @hideToTray.
  ///
  /// In en, this message translates to:
  /// **'Hide to tray'**
  String get hideToTray;

  /// No description provided for @closeBtnAction.
  ///
  /// In en, this message translates to:
  /// **'Close Button Action'**
  String get closeBtnAction;

  /// No description provided for @whenCloseBtnClicked.
  ///
  /// In en, this message translates to:
  /// **'When close button is clicked'**
  String get whenCloseBtnClicked;

  /// No description provided for @closeApp.
  ///
  /// In en, this message translates to:
  /// **'Close Application'**
  String get closeApp;

  /// No description provided for @closeMusicPod.
  ///
  /// In en, this message translates to:
  /// **'Close MusicPod?'**
  String get closeMusicPod;

  /// No description provided for @confirmCloseOrHideTip.
  ///
  /// In en, this message translates to:
  /// **'Please confirm if you need to close the application or hide it'**
  String get confirmCloseOrHideTip;

  /// No description provided for @doNotAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not ask again'**
  String get doNotAskAgain;

  /// No description provided for @skipToLivStream.
  ///
  /// In en, this message translates to:
  /// **'Skip to live stream'**
  String get skipToLivStream;

  /// No description provided for @searchSimilarStation.
  ///
  /// In en, this message translates to:
  /// **'Search similar station'**
  String get searchSimilarStation;

  /// No description provided for @onlineArtError.
  ///
  /// In en, this message translates to:
  /// **'Online art lookup is currently not available'**
  String get onlineArtError;

  /// No description provided for @clicks.
  ///
  /// In en, this message translates to:
  /// **'clicks'**
  String get clicks;

  /// No description provided for @theClick.
  ///
  /// In en, this message translates to:
  /// **'click'**
  String get theClick;

  /// No description provided for @toClick.
  ///
  /// In en, this message translates to:
  /// **'click'**
  String get toClick;

  /// No description provided for @exposeOnlineHeadline.
  ///
  /// In en, this message translates to:
  /// **'Expose your listening activity online'**
  String get exposeOnlineHeadline;

  /// No description provided for @exposeToDiscordTitle.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get exposeToDiscordTitle;

  /// No description provided for @exposeToDiscordSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The artist and title of the song/station/podcast you are currently listening to are shared.'**
  String get exposeToDiscordSubTitle;

  /// No description provided for @exposeToLastfmTitle.
  ///
  /// In en, this message translates to:
  /// **'Last.fm'**
  String get exposeToLastfmTitle;

  /// No description provided for @exposeToLastfmSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The artist and title of the song/station/podcast you are currently listening to are shared.'**
  String get exposeToLastfmSubTitle;

  /// No description provided for @lastfmApiKey.
  ///
  /// In en, this message translates to:
  /// **'Last.fm API key'**
  String get lastfmApiKey;

  /// No description provided for @lastfmSecret.
  ///
  /// In en, this message translates to:
  /// **'Last.fm secret'**
  String get lastfmSecret;

  /// No description provided for @lastfmApiKeyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an API key'**
  String get lastfmApiKeyEmpty;

  /// No description provided for @lastfmSecretEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the shared secret'**
  String get lastfmSecretEmpty;

  /// No description provided for @exposeToListenBrainzTitle.
  ///
  /// In en, this message translates to:
  /// **'ListenBrainz'**
  String get exposeToListenBrainzTitle;

  /// No description provided for @exposeToListenBrainzSubTitle.
  ///
  /// In en, this message translates to:
  /// **'The artist and title of the song/station/podcast you are currently listening to are shared.'**
  String get exposeToListenBrainzSubTitle;

  /// No description provided for @listenBrainzApiKey.
  ///
  /// In en, this message translates to:
  /// **'ListenBrainz API key'**
  String get listenBrainzApiKey;

  /// No description provided for @listenBrainzApiKeyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an API key'**
  String get listenBrainzApiKeyEmpty;

  /// No description provided for @featureDisabledOnPlatform.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently disabled for this operating system.'**
  String get featureDisabledOnPlatform;

  /// No description provided for @regionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get regionNone;

  /// No description provided for @regionAfghanistan.
  ///
  /// In en, this message translates to:
  /// **'Afghanistan'**
  String get regionAfghanistan;

  /// No description provided for @regionAlandislands.
  ///
  /// In en, this message translates to:
  /// **'Alandislands'**
  String get regionAlandislands;

  /// No description provided for @regionAlbania.
  ///
  /// In en, this message translates to:
  /// **'Albania'**
  String get regionAlbania;

  /// No description provided for @regionAlgeria.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get regionAlgeria;

  /// No description provided for @regionAmericansamoa.
  ///
  /// In en, this message translates to:
  /// **'Americansamoa'**
  String get regionAmericansamoa;

  /// No description provided for @regionAndorra.
  ///
  /// In en, this message translates to:
  /// **'Andorra'**
  String get regionAndorra;

  /// No description provided for @regionAngolia.
  ///
  /// In en, this message translates to:
  /// **'Angolia'**
  String get regionAngolia;

  /// No description provided for @regionAnguilla.
  ///
  /// In en, this message translates to:
  /// **'Anguilla'**
  String get regionAnguilla;

  /// No description provided for @regionAntarctica.
  ///
  /// In en, this message translates to:
  /// **'Antarctica'**
  String get regionAntarctica;

  /// No description provided for @regionAntiguaandbarbuda.
  ///
  /// In en, this message translates to:
  /// **'Antiguaandbarbuda'**
  String get regionAntiguaandbarbuda;

  /// No description provided for @regionArgentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get regionArgentina;

  /// No description provided for @regionArmenia.
  ///
  /// In en, this message translates to:
  /// **'Armenia'**
  String get regionArmenia;

  /// No description provided for @regionAruba.
  ///
  /// In en, this message translates to:
  /// **'Aruba'**
  String get regionAruba;

  /// No description provided for @regionAustralia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get regionAustralia;

  /// No description provided for @regionAustria.
  ///
  /// In en, this message translates to:
  /// **'Austria'**
  String get regionAustria;

  /// No description provided for @regionAzerbaijan.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijan'**
  String get regionAzerbaijan;

  /// No description provided for @regionBahamas.
  ///
  /// In en, this message translates to:
  /// **'Bahamas'**
  String get regionBahamas;

  /// No description provided for @regionBahrain.
  ///
  /// In en, this message translates to:
  /// **'Bahrain'**
  String get regionBahrain;

  /// No description provided for @regionBangladesh.
  ///
  /// In en, this message translates to:
  /// **'Bangladesh'**
  String get regionBangladesh;

  /// No description provided for @regionBarbados.
  ///
  /// In en, this message translates to:
  /// **'Barbados'**
  String get regionBarbados;

  /// No description provided for @regionBelarus.
  ///
  /// In en, this message translates to:
  /// **'Belarus'**
  String get regionBelarus;

  /// No description provided for @regionBelgium.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get regionBelgium;

  /// No description provided for @regionBelize.
  ///
  /// In en, this message translates to:
  /// **'Belize'**
  String get regionBelize;

  /// No description provided for @regionBenin.
  ///
  /// In en, this message translates to:
  /// **'Benin'**
  String get regionBenin;

  /// No description provided for @regionBermuda.
  ///
  /// In en, this message translates to:
  /// **'Bermuda'**
  String get regionBermuda;

  /// No description provided for @regionBhutan.
  ///
  /// In en, this message translates to:
  /// **'Bhutan'**
  String get regionBhutan;

  /// No description provided for @regionBolivia.
  ///
  /// In en, this message translates to:
  /// **'Bolivia'**
  String get regionBolivia;

  /// No description provided for @regionBonaire.
  ///
  /// In en, this message translates to:
  /// **'Bonaire'**
  String get regionBonaire;

  /// No description provided for @regionBosniaandherzegovina.
  ///
  /// In en, this message translates to:
  /// **'Bosnia and Herzegovina'**
  String get regionBosniaandherzegovina;

  /// No description provided for @regionBotswana.
  ///
  /// In en, this message translates to:
  /// **'Botswana'**
  String get regionBotswana;

  /// No description provided for @regionBouvetisland.
  ///
  /// In en, this message translates to:
  /// **'Bouvet Island'**
  String get regionBouvetisland;

  /// No description provided for @regionBrazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get regionBrazil;

  /// No description provided for @regionBritishindianoceanterrirory.
  ///
  /// In en, this message translates to:
  /// **'British Indian Ocean Territory'**
  String get regionBritishindianoceanterrirory;

  /// No description provided for @regionBritishvirginislands.
  ///
  /// In en, this message translates to:
  /// **'British Virgin Islands'**
  String get regionBritishvirginislands;

  /// No description provided for @regionBruneidarussalam.
  ///
  /// In en, this message translates to:
  /// **'Brunei Darussalam'**
  String get regionBruneidarussalam;

  /// No description provided for @regionBulgaria.
  ///
  /// In en, this message translates to:
  /// **'Bulgaria'**
  String get regionBulgaria;

  /// No description provided for @regionBurkinafaso.
  ///
  /// In en, this message translates to:
  /// **'Burkina Faso'**
  String get regionBurkinafaso;

  /// No description provided for @regionBurundi.
  ///
  /// In en, this message translates to:
  /// **'Burundi'**
  String get regionBurundi;

  /// No description provided for @regionCaboverde.
  ///
  /// In en, this message translates to:
  /// **'Caboverde'**
  String get regionCaboverde;

  /// No description provided for @regionCambodia.
  ///
  /// In en, this message translates to:
  /// **'Cambodia'**
  String get regionCambodia;

  /// No description provided for @regionCameroon.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get regionCameroon;

  /// No description provided for @regionCanada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get regionCanada;

  /// No description provided for @regionCaymanislands.
  ///
  /// In en, this message translates to:
  /// **'Cayman Islands'**
  String get regionCaymanislands;

  /// No description provided for @regionCentralafricanrepublic.
  ///
  /// In en, this message translates to:
  /// **'Central African Republic'**
  String get regionCentralafricanrepublic;

  /// No description provided for @regionChad.
  ///
  /// In en, this message translates to:
  /// **'Chad'**
  String get regionChad;

  /// No description provided for @regionChile.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get regionChile;

  /// No description provided for @regionChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get regionChina;

  /// No description provided for @regionChristmasisland.
  ///
  /// In en, this message translates to:
  /// **'Christmas Island'**
  String get regionChristmasisland;

  /// No description provided for @regionCocosislands.
  ///
  /// In en, this message translates to:
  /// **'Coco Islands'**
  String get regionCocosislands;

  /// No description provided for @regionColombia.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get regionColombia;

  /// No description provided for @regionComoros.
  ///
  /// In en, this message translates to:
  /// **'Comoros'**
  String get regionComoros;

  /// No description provided for @regionCongo.
  ///
  /// In en, this message translates to:
  /// **'Congo'**
  String get regionCongo;

  /// No description provided for @regionCongodemocraticrepublicof.
  ///
  /// In en, this message translates to:
  /// **'Democratic Republic of the Congo'**
  String get regionCongodemocraticrepublicof;

  /// No description provided for @regionCookislands.
  ///
  /// In en, this message translates to:
  /// **'Cook Islands'**
  String get regionCookislands;

  /// No description provided for @regionCostarica.
  ///
  /// In en, this message translates to:
  /// **'Costarica'**
  String get regionCostarica;

  /// No description provided for @regionCotedivoire.
  ///
  /// In en, this message translates to:
  /// **'Coted Ivoire'**
  String get regionCotedivoire;

  /// No description provided for @regionCroatia.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get regionCroatia;

  /// No description provided for @regionCuba.
  ///
  /// In en, this message translates to:
  /// **'Cuba'**
  String get regionCuba;

  /// No description provided for @regionCuracao.
  ///
  /// In en, this message translates to:
  /// **'Curacao'**
  String get regionCuracao;

  /// No description provided for @regionCyprus.
  ///
  /// In en, this message translates to:
  /// **'Cyprus'**
  String get regionCyprus;

  /// No description provided for @regionCzechia.
  ///
  /// In en, this message translates to:
  /// **'Czechia'**
  String get regionCzechia;

  /// No description provided for @regionDenmark.
  ///
  /// In en, this message translates to:
  /// **'Denmark'**
  String get regionDenmark;

  /// No description provided for @regionDjibouti.
  ///
  /// In en, this message translates to:
  /// **'Djibouti'**
  String get regionDjibouti;

  /// No description provided for @regionDominica.
  ///
  /// In en, this message translates to:
  /// **'Dominica'**
  String get regionDominica;

  /// No description provided for @regionDominicanrepublic.
  ///
  /// In en, this message translates to:
  /// **'Dominican Republic'**
  String get regionDominicanrepublic;

  /// No description provided for @regionEcuador.
  ///
  /// In en, this message translates to:
  /// **'Ecuador'**
  String get regionEcuador;

  /// No description provided for @regionEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get regionEgypt;

  /// No description provided for @regionElsalvador.
  ///
  /// In en, this message translates to:
  /// **'El Salvador'**
  String get regionElsalvador;

  /// No description provided for @regionEquatorialguinea.
  ///
  /// In en, this message translates to:
  /// **'Equatorial Guinea'**
  String get regionEquatorialguinea;

  /// No description provided for @regionEritrea.
  ///
  /// In en, this message translates to:
  /// **'Eritrea'**
  String get regionEritrea;

  /// No description provided for @regionEstonia.
  ///
  /// In en, this message translates to:
  /// **'Estonia'**
  String get regionEstonia;

  /// No description provided for @regionEthiopia.
  ///
  /// In en, this message translates to:
  /// **'Ethiopia'**
  String get regionEthiopia;

  /// No description provided for @regionFalklandislands.
  ///
  /// In en, this message translates to:
  /// **'Falkland Islands'**
  String get regionFalklandislands;

  /// No description provided for @regionFaroeislands.
  ///
  /// In en, this message translates to:
  /// **'Faroe Islands'**
  String get regionFaroeislands;

  /// No description provided for @regionFiji.
  ///
  /// In en, this message translates to:
  /// **'Fiji'**
  String get regionFiji;

  /// No description provided for @regionFinland.
  ///
  /// In en, this message translates to:
  /// **'Finland'**
  String get regionFinland;

  /// No description provided for @regionFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get regionFrance;

  /// No description provided for @regionFrenchguiana.
  ///
  /// In en, this message translates to:
  /// **'French Guiana'**
  String get regionFrenchguiana;

  /// No description provided for @regionFrenchpolynesia.
  ///
  /// In en, this message translates to:
  /// **'French Polynesia'**
  String get regionFrenchpolynesia;

  /// No description provided for @regionFrenchsouthernterritories.
  ///
  /// In en, this message translates to:
  /// **'French Southern Territories'**
  String get regionFrenchsouthernterritories;

  /// No description provided for @regionGabon.
  ///
  /// In en, this message translates to:
  /// **'Gabon'**
  String get regionGabon;

  /// No description provided for @regionGambia.
  ///
  /// In en, this message translates to:
  /// **'Gambia'**
  String get regionGambia;

  /// No description provided for @regionGeorgia.
  ///
  /// In en, this message translates to:
  /// **'Georgia'**
  String get regionGeorgia;

  /// No description provided for @regionGermany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get regionGermany;

  /// No description provided for @regionGhana.
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get regionGhana;

  /// No description provided for @regionGibraltar.
  ///
  /// In en, this message translates to:
  /// **'Gibraltar'**
  String get regionGibraltar;

  /// No description provided for @regionGreece.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get regionGreece;

  /// No description provided for @regionGreenland.
  ///
  /// In en, this message translates to:
  /// **'Greenland'**
  String get regionGreenland;

  /// No description provided for @regionGrenada.
  ///
  /// In en, this message translates to:
  /// **'Grenada'**
  String get regionGrenada;

  /// No description provided for @regionGuadeloupe.
  ///
  /// In en, this message translates to:
  /// **'Guadeloupe'**
  String get regionGuadeloupe;

  /// No description provided for @regionGuam.
  ///
  /// In en, this message translates to:
  /// **'Guam'**
  String get regionGuam;

  /// No description provided for @regionGuatemala.
  ///
  /// In en, this message translates to:
  /// **'Guatemala'**
  String get regionGuatemala;

  /// No description provided for @regionGuernsey.
  ///
  /// In en, this message translates to:
  /// **'Guernsey'**
  String get regionGuernsey;

  /// No description provided for @regionGuinea.
  ///
  /// In en, this message translates to:
  /// **'Guinea'**
  String get regionGuinea;

  /// No description provided for @regionGuineabissau.
  ///
  /// In en, this message translates to:
  /// **'Guinea-Bissau'**
  String get regionGuineabissau;

  /// No description provided for @regionGuyana.
  ///
  /// In en, this message translates to:
  /// **'Guyana'**
  String get regionGuyana;

  /// No description provided for @regionHaiti.
  ///
  /// In en, this message translates to:
  /// **'Hait'**
  String get regionHaiti;

  /// No description provided for @regionHeardislandandmcdonaldislands.
  ///
  /// In en, this message translates to:
  /// **'Heard Island and McDonald Islands'**
  String get regionHeardislandandmcdonaldislands;

  /// No description provided for @regionHonduras.
  ///
  /// In en, this message translates to:
  /// **'Honduras'**
  String get regionHonduras;

  /// No description provided for @regionHongkong.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong'**
  String get regionHongkong;

  /// No description provided for @regionHungary.
  ///
  /// In en, this message translates to:
  /// **'Hungary'**
  String get regionHungary;

  /// No description provided for @regionIceland.
  ///
  /// In en, this message translates to:
  /// **'Iceland'**
  String get regionIceland;

  /// No description provided for @regionIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get regionIndia;

  /// No description provided for @regionIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get regionIndonesia;

  /// No description provided for @regionIran.
  ///
  /// In en, this message translates to:
  /// **'Iran'**
  String get regionIran;

  /// No description provided for @regionIraq.
  ///
  /// In en, this message translates to:
  /// **'Iraq'**
  String get regionIraq;

  /// No description provided for @regionIreland.
  ///
  /// In en, this message translates to:
  /// **'Ireland'**
  String get regionIreland;

  /// No description provided for @regionIsleofman.
  ///
  /// In en, this message translates to:
  /// **'Isle of Man'**
  String get regionIsleofman;

  /// No description provided for @regionIsrael.
  ///
  /// In en, this message translates to:
  /// **'Israel'**
  String get regionIsrael;

  /// No description provided for @regionItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get regionItaly;

  /// No description provided for @regionJamaica.
  ///
  /// In en, this message translates to:
  /// **'Jamaica'**
  String get regionJamaica;

  /// No description provided for @regionJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get regionJapan;

  /// No description provided for @regionJersey.
  ///
  /// In en, this message translates to:
  /// **'Jersey'**
  String get regionJersey;

  /// No description provided for @regionJordan.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get regionJordan;

  /// No description provided for @regionKazakhstan.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstan'**
  String get regionKazakhstan;

  /// No description provided for @regionKenya.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get regionKenya;

  /// No description provided for @regionKiribati.
  ///
  /// In en, this message translates to:
  /// **'Kiribati'**
  String get regionKiribati;

  /// No description provided for @regionKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get regionKuwait;

  /// No description provided for @regionKyrgyzstan.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyzstan'**
  String get regionKyrgyzstan;

  /// No description provided for @regionLaos.
  ///
  /// In en, this message translates to:
  /// **'Laos'**
  String get regionLaos;

  /// No description provided for @regionLatvia.
  ///
  /// In en, this message translates to:
  /// **'Latvia'**
  String get regionLatvia;

  /// No description provided for @regionLebanon.
  ///
  /// In en, this message translates to:
  /// **'Lebanon'**
  String get regionLebanon;

  /// No description provided for @regionLesotho.
  ///
  /// In en, this message translates to:
  /// **'Lesotho'**
  String get regionLesotho;

  /// No description provided for @regionLiberia.
  ///
  /// In en, this message translates to:
  /// **'Liberia'**
  String get regionLiberia;

  /// No description provided for @regionLibya.
  ///
  /// In en, this message translates to:
  /// **'Libya'**
  String get regionLibya;

  /// No description provided for @regionLiechtenstein.
  ///
  /// In en, this message translates to:
  /// **'Liettenstein'**
  String get regionLiechtenstein;

  /// No description provided for @regionLithuania.
  ///
  /// In en, this message translates to:
  /// **'Lithuania'**
  String get regionLithuania;

  /// No description provided for @regionLuxembourg.
  ///
  /// In en, this message translates to:
  /// **'Luxembourg'**
  String get regionLuxembourg;

  /// No description provided for @regionMacao.
  ///
  /// In en, this message translates to:
  /// **'Macao'**
  String get regionMacao;

  /// No description provided for @regionMacedonia.
  ///
  /// In en, this message translates to:
  /// **'Macedonia'**
  String get regionMacedonia;

  /// No description provided for @regionMadagascar.
  ///
  /// In en, this message translates to:
  /// **'Madagascar'**
  String get regionMadagascar;

  /// No description provided for @regionMalawi.
  ///
  /// In en, this message translates to:
  /// **'Malawi'**
  String get regionMalawi;

  /// No description provided for @regionMalaysia.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get regionMalaysia;

  /// No description provided for @regionMaldives.
  ///
  /// In en, this message translates to:
  /// **'Maldives'**
  String get regionMaldives;

  /// No description provided for @regionMali.
  ///
  /// In en, this message translates to:
  /// **'Mali'**
  String get regionMali;

  /// No description provided for @regionMalta.
  ///
  /// In en, this message translates to:
  /// **'Malta'**
  String get regionMalta;

  /// No description provided for @regionMarshallislands.
  ///
  /// In en, this message translates to:
  /// **'Marshall Islands'**
  String get regionMarshallislands;

  /// No description provided for @regionMartinique.
  ///
  /// In en, this message translates to:
  /// **'Martinique'**
  String get regionMartinique;

  /// No description provided for @regionMauritania.
  ///
  /// In en, this message translates to:
  /// **'Mauritania'**
  String get regionMauritania;

  /// No description provided for @regionMauritius.
  ///
  /// In en, this message translates to:
  /// **'Mauritius'**
  String get regionMauritius;

  /// No description provided for @regionMayotte.
  ///
  /// In en, this message translates to:
  /// **'Mayotte'**
  String get regionMayotte;

  /// No description provided for @regionMexico.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get regionMexico;

  /// No description provided for @regionMicronesia.
  ///
  /// In en, this message translates to:
  /// **'Micronesia'**
  String get regionMicronesia;

  /// No description provided for @regionMoldova.
  ///
  /// In en, this message translates to:
  /// **'Moldova'**
  String get regionMoldova;

  /// No description provided for @regionMonaco.
  ///
  /// In en, this message translates to:
  /// **'Monaco'**
  String get regionMonaco;

  /// No description provided for @regionMongolia.
  ///
  /// In en, this message translates to:
  /// **'Mongolia'**
  String get regionMongolia;

  /// No description provided for @regionMontenegro.
  ///
  /// In en, this message translates to:
  /// **'Montenegro'**
  String get regionMontenegro;

  /// No description provided for @regionMontserrat.
  ///
  /// In en, this message translates to:
  /// **'Montserrat'**
  String get regionMontserrat;

  /// No description provided for @regionMorocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get regionMorocco;

  /// No description provided for @regionMozambique.
  ///
  /// In en, this message translates to:
  /// **'Mozambique'**
  String get regionMozambique;

  /// No description provided for @regionMyanmar.
  ///
  /// In en, this message translates to:
  /// **'Myanmar'**
  String get regionMyanmar;

  /// No description provided for @regionNamibia.
  ///
  /// In en, this message translates to:
  /// **'Namibia'**
  String get regionNamibia;

  /// No description provided for @regionNauru.
  ///
  /// In en, this message translates to:
  /// **'Nauru'**
  String get regionNauru;

  /// No description provided for @regionNepal.
  ///
  /// In en, this message translates to:
  /// **'Nepal'**
  String get regionNepal;

  /// No description provided for @regionNetherlands.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get regionNetherlands;

  /// No description provided for @regionNewcaledonia.
  ///
  /// In en, this message translates to:
  /// **'Newcaledonia'**
  String get regionNewcaledonia;

  /// No description provided for @regionNewzealand.
  ///
  /// In en, this message translates to:
  /// **'Newzealand'**
  String get regionNewzealand;

  /// No description provided for @regionNicaragua.
  ///
  /// In en, this message translates to:
  /// **'Nicaragua'**
  String get regionNicaragua;

  /// No description provided for @regionNiger.
  ///
  /// In en, this message translates to:
  /// **'Niger'**
  String get regionNiger;

  /// No description provided for @regionNigeria.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get regionNigeria;

  /// No description provided for @regionNiue.
  ///
  /// In en, this message translates to:
  /// **'Niue'**
  String get regionNiue;

  /// No description provided for @regionNorfolkisland.
  ///
  /// In en, this message translates to:
  /// **'Norfolkisland'**
  String get regionNorfolkisland;

  /// No description provided for @regionNorthkorea.
  ///
  /// In en, this message translates to:
  /// **'Northkorea'**
  String get regionNorthkorea;

  /// No description provided for @regionNorthernmarianaislands.
  ///
  /// In en, this message translates to:
  /// **'Northernmarianaislands'**
  String get regionNorthernmarianaislands;

  /// No description provided for @regionNorway.
  ///
  /// In en, this message translates to:
  /// **'Norway'**
  String get regionNorway;

  /// No description provided for @regionOman.
  ///
  /// In en, this message translates to:
  /// **'Oman'**
  String get regionOman;

  /// No description provided for @regionPakistan.
  ///
  /// In en, this message translates to:
  /// **'Pakistan'**
  String get regionPakistan;

  /// No description provided for @regionPalau.
  ///
  /// In en, this message translates to:
  /// **'Palau'**
  String get regionPalau;

  /// No description provided for @regionPalestine.
  ///
  /// In en, this message translates to:
  /// **'Palestine'**
  String get regionPalestine;

  /// No description provided for @regionPanama.
  ///
  /// In en, this message translates to:
  /// **'Panama'**
  String get regionPanama;

  /// No description provided for @regionPapuanewguinea.
  ///
  /// In en, this message translates to:
  /// **'Papuanewguinea'**
  String get regionPapuanewguinea;

  /// No description provided for @regionParaguay.
  ///
  /// In en, this message translates to:
  /// **'Paraguay'**
  String get regionParaguay;

  /// No description provided for @regionPeru.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get regionPeru;

  /// No description provided for @regionPhilippines.
  ///
  /// In en, this message translates to:
  /// **'Philippines'**
  String get regionPhilippines;

  /// No description provided for @regionPitcairn.
  ///
  /// In en, this message translates to:
  /// **'Pitcairn'**
  String get regionPitcairn;

  /// No description provided for @regionPoland.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get regionPoland;

  /// No description provided for @regionPortugal.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get regionPortugal;

  /// No description provided for @regionPuertorico.
  ///
  /// In en, this message translates to:
  /// **'Puerto Rico'**
  String get regionPuertorico;

  /// No description provided for @regionQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get regionQatar;

  /// No description provided for @regionReunion.
  ///
  /// In en, this message translates to:
  /// **'Reunion'**
  String get regionReunion;

  /// No description provided for @regionRomania.
  ///
  /// In en, this message translates to:
  /// **'Romania'**
  String get regionRomania;

  /// No description provided for @regionRussianfederation.
  ///
  /// In en, this message translates to:
  /// **'Russianfederation'**
  String get regionRussianfederation;

  /// No description provided for @regionRwanda.
  ///
  /// In en, this message translates to:
  /// **'Rwanda'**
  String get regionRwanda;

  /// No description provided for @regionSaintbarthelemy.
  ///
  /// In en, this message translates to:
  /// **'Saintbarthelemy'**
  String get regionSaintbarthelemy;

  /// No description provided for @regionSainthelena.
  ///
  /// In en, this message translates to:
  /// **'Sainthelena'**
  String get regionSainthelena;

  /// No description provided for @regionSaintkittsandnevis.
  ///
  /// In en, this message translates to:
  /// **'Saintkittsandnevis'**
  String get regionSaintkittsandnevis;

  /// No description provided for @regionSaintlucia.
  ///
  /// In en, this message translates to:
  /// **'Saintlucia'**
  String get regionSaintlucia;

  /// No description provided for @regionSaintmartin.
  ///
  /// In en, this message translates to:
  /// **'Saintmartin'**
  String get regionSaintmartin;

  /// No description provided for @regionSaintpierreandmiquelon.
  ///
  /// In en, this message translates to:
  /// **'Saintpierreandmiquelon'**
  String get regionSaintpierreandmiquelon;

  /// No description provided for @regionSaintvincentandthegrenadines.
  ///
  /// In en, this message translates to:
  /// **'Saintvincentandthegrenadines'**
  String get regionSaintvincentandthegrenadines;

  /// No description provided for @regionSamoa.
  ///
  /// In en, this message translates to:
  /// **'Samoa'**
  String get regionSamoa;

  /// No description provided for @regionSanmarino.
  ///
  /// In en, this message translates to:
  /// **'San Marino'**
  String get regionSanmarino;

  /// No description provided for @regionSaotomeandprincipe.
  ///
  /// In en, this message translates to:
  /// **'São Tomé and Príncipe'**
  String get regionSaotomeandprincipe;

  /// No description provided for @regionSaudiarabia.
  ///
  /// In en, this message translates to:
  /// **'Saudiarabia'**
  String get regionSaudiarabia;

  /// No description provided for @regionSenegal.
  ///
  /// In en, this message translates to:
  /// **'Senegal'**
  String get regionSenegal;

  /// No description provided for @regionSerbia.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get regionSerbia;

  /// No description provided for @regionSeychelles.
  ///
  /// In en, this message translates to:
  /// **'Seychelles'**
  String get regionSeychelles;

  /// No description provided for @regionSierraleone.
  ///
  /// In en, this message translates to:
  /// **'Sierraleone'**
  String get regionSierraleone;

  /// No description provided for @regionSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get regionSingapore;

  /// No description provided for @regionSintmaarten.
  ///
  /// In en, this message translates to:
  /// **'Sint Maarten'**
  String get regionSintmaarten;

  /// No description provided for @regionSlovakia.
  ///
  /// In en, this message translates to:
  /// **'Slovakia'**
  String get regionSlovakia;

  /// No description provided for @regionSlovenia.
  ///
  /// In en, this message translates to:
  /// **'Slovenia'**
  String get regionSlovenia;

  /// No description provided for @regionSolomonislands.
  ///
  /// In en, this message translates to:
  /// **'Solomon Islands'**
  String get regionSolomonislands;

  /// No description provided for @regionSomalia.
  ///
  /// In en, this message translates to:
  /// **'Somalia'**
  String get regionSomalia;

  /// No description provided for @regionSouthafrica.
  ///
  /// In en, this message translates to:
  /// **'South Africa'**
  String get regionSouthafrica;

  /// No description provided for @regionSouthgeorgiaandthesouthsandwichislands.
  ///
  /// In en, this message translates to:
  /// **'South Georgia and the South Sandwich Islands'**
  String get regionSouthgeorgiaandthesouthsandwichislands;

  /// No description provided for @regionSouthkorea.
  ///
  /// In en, this message translates to:
  /// **'Southen Korea'**
  String get regionSouthkorea;

  /// No description provided for @regionSouthsudan.
  ///
  /// In en, this message translates to:
  /// **'South Sudan'**
  String get regionSouthsudan;

  /// No description provided for @regionSpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get regionSpain;

  /// No description provided for @regionSrilanka.
  ///
  /// In en, this message translates to:
  /// **'Srilanka'**
  String get regionSrilanka;

  /// No description provided for @regionSudan.
  ///
  /// In en, this message translates to:
  /// **'Sudan'**
  String get regionSudan;

  /// No description provided for @regionSuriname.
  ///
  /// In en, this message translates to:
  /// **'Suriname'**
  String get regionSuriname;

  /// No description provided for @regionSvalbardandjanmayen.
  ///
  /// In en, this message translates to:
  /// **'Svalbard and Jan Mayen'**
  String get regionSvalbardandjanmayen;

  /// No description provided for @regionSwaziland.
  ///
  /// In en, this message translates to:
  /// **'Swaziland'**
  String get regionSwaziland;

  /// No description provided for @regionSweden.
  ///
  /// In en, this message translates to:
  /// **'Sweden'**
  String get regionSweden;

  /// No description provided for @regionSwitzerland.
  ///
  /// In en, this message translates to:
  /// **'Switerland'**
  String get regionSwitzerland;

  /// No description provided for @regionSyrianarabrepublic.
  ///
  /// In en, this message translates to:
  /// **'Syrian Arab Republic'**
  String get regionSyrianarabrepublic;

  /// No description provided for @regionTaiwan.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get regionTaiwan;

  /// No description provided for @regionTajikistan.
  ///
  /// In en, this message translates to:
  /// **'Tajikistan'**
  String get regionTajikistan;

  /// No description provided for @regionTanzania.
  ///
  /// In en, this message translates to:
  /// **'Tanzania'**
  String get regionTanzania;

  /// No description provided for @regionThailand.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get regionThailand;

  /// No description provided for @regionTimorleste.
  ///
  /// In en, this message translates to:
  /// **'Timor-Leste'**
  String get regionTimorleste;

  /// No description provided for @regionTogo.
  ///
  /// In en, this message translates to:
  /// **'Togo'**
  String get regionTogo;

  /// No description provided for @regionTokelau.
  ///
  /// In en, this message translates to:
  /// **'Tokelau'**
  String get regionTokelau;

  /// No description provided for @regionTonga.
  ///
  /// In en, this message translates to:
  /// **'Tonga'**
  String get regionTonga;

  /// No description provided for @regionTrinidadandtobago.
  ///
  /// In en, this message translates to:
  /// **'Trinidad and Tobago'**
  String get regionTrinidadandtobago;

  /// No description provided for @regionTunisia.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get regionTunisia;

  /// No description provided for @regionTurkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get regionTurkey;

  /// No description provided for @regionTurkmenistan.
  ///
  /// In en, this message translates to:
  /// **'Turkmenistan'**
  String get regionTurkmenistan;

  /// No description provided for @regionTurksandcaicosislands.
  ///
  /// In en, this message translates to:
  /// **'Turks and Caicos Islands'**
  String get regionTurksandcaicosislands;

  /// No description provided for @regionTuvalu.
  ///
  /// In en, this message translates to:
  /// **'Tuvalu'**
  String get regionTuvalu;

  /// No description provided for @regionUganda.
  ///
  /// In en, this message translates to:
  /// **'Uganda'**
  String get regionUganda;

  /// No description provided for @regionUkraine.
  ///
  /// In en, this message translates to:
  /// **'Ukraine'**
  String get regionUkraine;

  /// No description provided for @regionUnitedarabemirates.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get regionUnitedarabemirates;

  /// No description provided for @regionUnitedkingdom.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get regionUnitedkingdom;

  /// No description provided for @regionUnitedstates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get regionUnitedstates;

  /// No description provided for @regionUnitedstatesminoroutlyingislands.
  ///
  /// In en, this message translates to:
  /// **'United States Minor Outlying Islands'**
  String get regionUnitedstatesminoroutlyingislands;

  /// No description provided for @regionUruguay.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get regionUruguay;

  /// No description provided for @regionUsvirginislands.
  ///
  /// In en, this message translates to:
  /// **'Usvirgin Islands'**
  String get regionUsvirginislands;

  /// No description provided for @regionUzbekistan.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistan'**
  String get regionUzbekistan;

  /// No description provided for @regionVanuatu.
  ///
  /// In en, this message translates to:
  /// **'Vanuatu'**
  String get regionVanuatu;

  /// No description provided for @regionVaticancity.
  ///
  /// In en, this message translates to:
  /// **'Vatican City'**
  String get regionVaticancity;

  /// No description provided for @regionVenezuela.
  ///
  /// In en, this message translates to:
  /// **'Venezuela'**
  String get regionVenezuela;

  /// No description provided for @regionVietnam.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get regionVietnam;

  /// No description provided for @regionWallisandfutuna.
  ///
  /// In en, this message translates to:
  /// **'Wallis And Futuna'**
  String get regionWallisandfutuna;

  /// No description provided for @regionWesternsahara.
  ///
  /// In en, this message translates to:
  /// **'Western Sahara'**
  String get regionWesternsahara;

  /// No description provided for @regionYemen.
  ///
  /// In en, this message translates to:
  /// **'Yemen'**
  String get regionYemen;

  /// No description provided for @regionZambia.
  ///
  /// In en, this message translates to:
  /// **'Zambia'**
  String get regionZambia;

  /// No description provided for @regionZimbabwe.
  ///
  /// In en, this message translates to:
  /// **'Zimbabwe'**
  String get regionZimbabwe;

  /// No description provided for @failedToReadMetadata.
  ///
  /// In en, this message translates to:
  /// **'Failed to read metadata for the following media files:'**
  String get failedToReadMetadata;

  /// No description provided for @failedToReadMetadataDescription.
  ///
  /// In en, this message translates to:
  /// **'The metadata of this file could not be read. This is usually caused by a missing codec or a corrupted file.'**
  String get failedToReadMetadataDescription;

  /// No description provided for @breakingChangesPleaseBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Breaking changes: Please backup!'**
  String get breakingChangesPleaseBackupTitle;

  /// No description provided for @breakingChangesPleaseBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'The next version of MusicPod will have breaking changes. Please backup your playlists, podcast subscriptions and pinned albums before updating.'**
  String get breakingChangesPleaseBackupDescription;

  /// No description provided for @breakingChangesPleaseBackupConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I have backed up my:'**
  String get breakingChangesPleaseBackupConfirmation;

  /// No description provided for @pinnedAlbumsAndPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Pinned albums and playlists'**
  String get pinnedAlbumsAndPlaylists;

  /// No description provided for @starredStations.
  ///
  /// In en, this message translates to:
  /// **'Starred stations'**
  String get starredStations;

  /// No description provided for @podcastSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Podcast subscriptions'**
  String get podcastSubscriptions;

  /// No description provided for @pinnedAlbums.
  ///
  /// In en, this message translates to:
  /// **'Pinned albums'**
  String get pinnedAlbums;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @exportYourData.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get exportYourData;

  /// No description provided for @exportYourDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your podcast subscriptions, starred stations and pinned albums.'**
  String get exportYourDataDescription;

  /// No description provided for @localAudioWatchDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Local audio directory was modified'**
  String get localAudioWatchDialogTitle;

  /// No description provided for @localAudioWatchDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reload the local audio directory?'**
  String get localAudioWatchDialogDescription;

  /// No description provided for @external.
  ///
  /// In en, this message translates to:
  /// **'external'**
  String get external;

  /// No description provided for @externalPlaylist.
  ///
  /// In en, this message translates to:
  /// **'External playlist'**
  String get externalPlaylist;

  /// No description provided for @pictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get pictures;

  /// No description provided for @localPictureTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get localPictureTypeOther;

  /// No description provided for @localPictureTypeFileIcon32x32.
  ///
  /// In en, this message translates to:
  /// **'Icon 32x32'**
  String get localPictureTypeFileIcon32x32;

  /// No description provided for @localPictureTypeOtherFileIcon.
  ///
  /// In en, this message translates to:
  /// **'Other file icon'**
  String get localPictureTypeOtherFileIcon;

  /// No description provided for @localPictureTypeCoverFront.
  ///
  /// In en, this message translates to:
  /// **'Cover front'**
  String get localPictureTypeCoverFront;

  /// No description provided for @localPictureTypeCoverBack.
  ///
  /// In en, this message translates to:
  /// **'Cover back'**
  String get localPictureTypeCoverBack;

  /// No description provided for @localPictureTypeLeafletPage.
  ///
  /// In en, this message translates to:
  /// **'Leaflet page'**
  String get localPictureTypeLeafletPage;

  /// No description provided for @localPictureTypeMediaLabelCD.
  ///
  /// In en, this message translates to:
  /// **'Media label CD'**
  String get localPictureTypeMediaLabelCD;

  /// No description provided for @localPictureTypeLeadArtist.
  ///
  /// In en, this message translates to:
  /// **'Lead artist'**
  String get localPictureTypeLeadArtist;

  /// No description provided for @localPictureTypeArtistPerformer.
  ///
  /// In en, this message translates to:
  /// **'Artist/Performer'**
  String get localPictureTypeArtistPerformer;

  /// No description provided for @localPictureTypeConductor.
  ///
  /// In en, this message translates to:
  /// **'Conductor'**
  String get localPictureTypeConductor;

  /// No description provided for @localPictureTypeBandOrchestra.
  ///
  /// In en, this message translates to:
  /// **'Band/Orchestra'**
  String get localPictureTypeBandOrchestra;

  /// No description provided for @localPictureTypeComposer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get localPictureTypeComposer;

  /// No description provided for @localPictureTypeLyricistTextWriter.
  ///
  /// In en, this message translates to:
  /// **'Lyricist/Text writer'**
  String get localPictureTypeLyricistTextWriter;

  /// No description provided for @localPictureTypeRecordingLocation.
  ///
  /// In en, this message translates to:
  /// **'Recording location'**
  String get localPictureTypeRecordingLocation;

  /// No description provided for @localPictureTypeDuringRecording.
  ///
  /// In en, this message translates to:
  /// **'During recording'**
  String get localPictureTypeDuringRecording;

  /// No description provided for @localPictureTypeDuringPerformance.
  ///
  /// In en, this message translates to:
  /// **'During performance'**
  String get localPictureTypeDuringPerformance;

  /// No description provided for @localPictureTypeMovieVideoScreenCapture.
  ///
  /// In en, this message translates to:
  /// **'Movie/Video screen capture'**
  String get localPictureTypeMovieVideoScreenCapture;

  /// No description provided for @localPictureTypeBrightColouredFish.
  ///
  /// In en, this message translates to:
  /// **'Bright coloured fish'**
  String get localPictureTypeBrightColouredFish;

  /// No description provided for @localPictureTypeIllustration.
  ///
  /// In en, this message translates to:
  /// **'Illustration'**
  String get localPictureTypeIllustration;

  /// No description provided for @localPictureTypebandArtistLogotype.
  ///
  /// In en, this message translates to:
  /// **'Band/Artist logotype'**
  String get localPictureTypebandArtistLogotype;

  /// No description provided for @localPictureTypepublisherStudioLogotype.
  ///
  /// In en, this message translates to:
  /// **'Publisher/Studio logotype'**
  String get localPictureTypepublisherStudioLogotype;

  /// No description provided for @cantPinEmptyAlbum.
  ///
  /// In en, this message translates to:
  /// **'You can\'t pin albums without empty album metadata!'**
  String get cantPinEmptyAlbum;

  /// No description provided for @cantUnpinEmptyAlbum.
  ///
  /// In en, this message translates to:
  /// **'You can\'t unpin albums without empty album metadata!'**
  String get cantUnpinEmptyAlbum;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @albumNotFound.
  ///
  /// In en, this message translates to:
  /// **'This album does not exist or you have removed the external playlist (M3U/PLS file) where it has been loaded from.'**
  String get albumNotFound;

  /// No description provided for @stationNotFound.
  ///
  /// In en, this message translates to:
  /// **'This station does not exist or it has been removed from the radiobrowser server.'**
  String get stationNotFound;

  /// No description provided for @onlyLocalAudioForPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Only local audio is supported for playlist imports! Please search for them in the radio feature and add them with the star button to your library!'**
  String get onlyLocalAudioForPlaylists;

  /// No description provided for @customStationWarning.
  ///
  /// In en, this message translates to:
  /// **'The provided URL must exist on the radiobrowser server, otherwise it will not be added to you library! Ideally search for them in the radio feature and add them with the star button to your library!'**
  String get customStationWarning;

  /// No description provided for @disc.
  ///
  /// In en, this message translates to:
  /// **'Disc'**
  String get disc;

  /// No description provided for @groupAlbumsOnlyByAlbumName.
  ///
  /// In en, this message translates to:
  /// **'Group albums only by album name'**
  String get groupAlbumsOnlyByAlbumName;

  /// No description provided for @groupAlbumsOnlyByAlbumNameDescription.
  ///
  /// In en, this message translates to:
  /// **'This will group albums only by album name and not by artist name + album name, which assumes that the album name is unique inside your library!'**
  String get groupAlbumsOnlyByAlbumNameDescription;

  /// No description provided for @useYaruThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Yaru theme'**
  String get useYaruThemeTitle;

  /// No description provided for @useYaruThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'This will use the Yaru theme for the application. This is the default theme for Ubuntu.'**
  String get useYaruThemeDescription;

  /// No description provided for @customThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Custom theme color'**
  String get customThemeColor;

  /// No description provided for @useCustomThemeColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Use custom accent color'**
  String get useCustomThemeColorTitle;

  /// No description provided for @useCustomThemeColorDescription.
  ///
  /// In en, this message translates to:
  /// **'This will let you chose a custom accent color for the current theme.'**
  String get useCustomThemeColorDescription;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get selectColor;

  /// No description provided for @selectColorShade.
  ///
  /// In en, this message translates to:
  /// **'Select color shade'**
  String get selectColorShade;

  /// No description provided for @selectColorAndItsShades.
  ///
  /// In en, this message translates to:
  /// **'Select color and its shades'**
  String get selectColorAndItsShades;

  /// No description provided for @selectIconThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select icon theme'**
  String get selectIconThemeTitle;

  /// No description provided for @selectIconThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Chose an icon theme for the application. The default theme depends on your operating system. This reloads the application!'**
  String get selectIconThemeDescription;

  /// No description provided for @saveWindowSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Save window size'**
  String get saveWindowSizeTitle;

  /// No description provided for @saveWindowSizeDescription.
  ///
  /// In en, this message translates to:
  /// **'This will save the window size and position of the application.'**
  String get saveWindowSizeDescription;

  /// No description provided for @downloadsOfLatestRelease.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {latestRelease} times outside of snapstore and flathub'**
  String downloadsOfLatestRelease(String latestRelease);

  /// No description provided for @useBlurredPlayerBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Use blurred player background'**
  String get useBlurredPlayerBackgroundTitle;

  /// No description provided for @useBlurredPlayerBackgroundDescription.
  ///
  /// In en, this message translates to:
  /// **'This will blur the background of the player. This might lead to lower performance on some devices.'**
  String get useBlurredPlayerBackgroundDescription;

  /// No description provided for @loadingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Loading, please wait ...'**
  String get loadingPleaseWait;

  /// No description provided for @importingPodcastsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Importing your podcasts, please wait ...'**
  String get importingPodcastsPleaseWait;

  /// No description provided for @exportingPodcastsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Exporting your podcasts, please wait ...'**
  String get exportingPodcastsPleaseWait;

  /// No description provided for @importingStationsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Importing your stations, please wait ...'**
  String get importingStationsPleaseWait;

  /// No description provided for @exportingStationsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Exporting your stations, please wait ...'**
  String get exportingStationsPleaseWait;

  /// No description provided for @importingPlaylistsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Importing your playlists, please wait ...'**
  String get importingPlaylistsPleaseWait;

  /// No description provided for @exportingPlaylistsPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Exporting your playlists, please wait ...'**
  String get exportingPlaylistsPleaseWait;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @keywords.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get keywords;

  /// No description provided for @newEpisodesAvailableFor.
  ///
  /// In en, this message translates to:
  /// **'New episodes available for {length} podcasts'**
  String newEpisodesAvailableFor(int length);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'cs',
    'da',
    'de',
    'en',
    'es',
    'et',
    'eu',
    'fr',
    'it',
    'nl',
    'pl',
    'pt',
    'ru',
    'sk',
    'sv',
    'ta',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'HK':
            return AppLocalizationsZhHk();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'eu':
      return AppLocalizationsEu();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
