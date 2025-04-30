import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';
import 'package:opml/opml.dart';
import 'package:path/path.dart';
import 'package:pls/pls.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../extensions/media_file_x.dart';
import '../external_path/external_path_service.dart';
import '../library/library_service.dart';
import '../local_audio/local_audio_service.dart';
import '../podcasts/podcast_service.dart';

class CustomContentModel extends SafeChangeNotifier {
  CustomContentModel({
    required ExternalPathService externalPathService,
    required LibraryService libraryService,
    required LocalAudioService localAudioService,
    required PodcastService podcastService,
  })  : _externalPathService = externalPathService,
        _libraryService = libraryService,
        _podcastService = podcastService,
        _localAudioService = localAudioService;

  final ExternalPathService _externalPathService;
  final LibraryService _libraryService;
  final PodcastService _podcastService;
  final LocalAudioService _localAudioService;

  List<({List<Audio> audios, String id})> _playlists = [];
  List<({List<Audio> audios, String id})> get playlists => _playlists;
  void setPlaylists(List<({List<Audio> audios, String id})> value) {
    _playlists = value;
    notifyListeners();
  }

  void removePlaylist({
    required String name,
  }) {
    _playlists.removeWhere((e) => e.id == name);
    notifyListeners();
  }

  Future<void> addPlaylists({List<XFile>? files}) async => setPlaylists(
        [..._playlists, ...await loadPlaylists(files: files)],
      );

  Future<List<({List<Audio> audios, String id})>> loadPlaylists({
    List<XFile>? files,
  }) async {
    List<({List<Audio> audios, String id})> lists = [];

    try {
      final paths = files?.map((e) => e.path) ??
          await _externalPathService.getPathsOfFiles();
      for (var path in paths) {
        if (path.endsWith('.m3u')) {
          lists.add(
            (
              id: basename(path),
              audios: await compute(_parseM3uPlaylist, path),
            ),
          );
        } else if (path.endsWith('.pls')) {
          lists.add(
            (
              id: basename(path),
              audios: await compute(_parsePlsPlaylist, path),
            ),
          );
        }
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    return lists;
  }

  Future<void> exportPlaylistToM3u({
    required String id,
    required List<Audio> audios,
  }) async {
    final path = await _externalPathService.getPathOfDirectory();
    if (path == null) return;
    _exportPlaylistToM3u(audios: audios, basePath: path, id: id);
  }

  bool get isExportingPlaylistsAndPinnedAlbumsToM3UsNeeded =>
      _libraryService.playlistIDs.isNotEmpty ||
      _libraryService.favoriteAlbums.isNotEmpty;
  Future<bool> exportPlaylistsAndPinnedAlbumsToM3Us() async {
    final albums = <({String id, List<Audio> audios})>[];
    for (var e in _libraryService.favoriteAlbums) {
      albums.add(
        (id: e, audios: await _localAudioService.findAlbum(e) ?? []),
      );
    }

    final List<({String id, List<Audio> audios})> list = [
      ..._libraryService.playlistIDs.map(
        (e) => (id: e, audios: _libraryService.getPlaylistById(e) ?? []),
      ),
      ...albums,
    ];

    final path = await _externalPathService.getPathOfDirectory();
    if (path == null) return false;

    for (var e in list) {
      _exportPlaylistToM3u(audios: e.audios, basePath: path, id: e.id);
    }
    return true;
  }

  void _exportPlaylistToM3u({
    required List<Audio> audios,
    required String basePath,
    required String id,
  }) {
    final m3uAsString = StringBuffer();
    m3uAsString.writeln('#EXTM3U');
    for (var audio in audios.where((e) => e.isLocal)) {
      if (audio.url != null) {
        m3uAsString.writeln('#EXTINF:-1, ${audio.artist} - ${audio.title}');
        m3uAsString.writeln(audio.url);
      } else {
        m3uAsString.writeln('#EXTINF:-1, ${audio.artist} - ${audio.title}');
        m3uAsString.writeln(audio.path);
      }
    }
    File(join(basePath, '$id.m3u')).writeAsStringSync(m3uAsString.toString());
  }

  bool _processing = false;
  bool get processing => _processing;
  void setProcessing(bool value) {
    if (_processing == value) return;
    _processing = value;
    notifyListeners();
  }

  Future<void> importPodcastsFromOpmlFile() async {
    if (_processing) return;
    setProcessing(true);
    final path = await _externalPathService.getPathOfFile();

    if (path == null) {
      setProcessing(false);
      return;
    }
    final file = File(path);
    if (!file.existsSync()) return;
    final xml = file.readAsStringSync();
    final doc = OpmlDocument.parse(xml);

    for (var category in doc.body.where((e) => e.children != null)) {
      final children = category.children!.where((e) => e.xmlUrl != null);
      final podcasts = <(String feedUrl, List<Audio> audios)>[];
      for (var feed in children) {
        final audios =
            await _podcastService.findEpisodes(feedUrl: feed.xmlUrl!);
        if (audios.isNotEmpty) {
          podcasts.add((feed.xmlUrl!, audios));
        }
      }
      if (podcasts.isNotEmpty) {
        _libraryService.addPodcasts(podcasts);
      }
    }
    setProcessing(false);
  }

  Future<bool> exportPodcastsToOpmlFile() async {
    if (_processing) return false;
    setProcessing(true);
    final location = await _externalPathService.getPathOfDirectory();
    if (location == null) {
      setProcessing(false);
      return false;
    }

    final file = File('$location/podcasts.opml');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final head = OpmlHeadBuilder().title('Podcasts').build();
    final body = <OpmlOutline>[];
    final category = OpmlOutlineBuilder();

    for (var podcast in _libraryService.podcasts.entries) {
      category.addChild(
        OpmlOutlineBuilder()
            .type('rss')
            .title(podcast.value.firstOrNull?.album ?? '')
            .text(podcast.value.firstOrNull?.artist ?? '')
            .xmlUrl(podcast.key)
            .build(),
      );
    }

    body.add(category.type('rss').title('Podcasts').text('Podcasts').build());

    final opml = OpmlDocument(
      head: head,
      body: body,
    );
    final xml = opml.toXmlString(pretty: true);
    file.writeAsStringSync(xml);
    setProcessing(false);
    return true;
  }

  Future<bool> exportStarredStationsToOpmlFile() async {
    if (_processing) return false;
    setProcessing(true);
    final location = await _externalPathService.getPathOfDirectory();
    if (location == null) {
      setProcessing(false);
      return false;
    }

    final file = File('$location/starred_stations.opml');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final head = OpmlHeadBuilder().title('Starred Stations').build();
    final body = <OpmlOutline>[];
    final category = OpmlOutlineBuilder();

    for (var station in _libraryService.starredStations) {
      category.addChild(
        OpmlOutlineBuilder().text(station).build(),
      );
    }

    body.add(
      category.title('Starred Stations').text('Starred Stations').build(),
    );

    final opml = OpmlDocument(
      head: head,
      body: body,
    );
    final xml = opml.toXmlString(pretty: true);
    file.writeAsStringSync(xml);
    setProcessing(false);
    return true;
  }

  Future<void> importStarredStationsFromOpmlFile() async {
    if (_processing) return;
    setProcessing(true);
    final path = await _externalPathService.getPathOfFile();

    if (path == null) {
      setProcessing(false);
      return;
    }
    final file = File(path);
    if (!file.existsSync()) return;
    final xml = file.readAsStringSync();
    final doc = OpmlDocument.parse(xml);

    for (var category in doc.body.where((e) => e.children != null)) {
      final children = category.children!.where((e) => e.text != null);
      final starredStations = <String>[];
      for (var feed in children) {
        starredStations.add(feed.text!);
      }
      if (starredStations.isNotEmpty) {
        _libraryService.addStarredStations(starredStations);
      }
    }
    setProcessing(false);
  }

  String? _playlistName;
  String? get playlistName => _playlistName;
  void setPlaylistName(String? value) {
    if (_playlistName == value) return;
    _playlistName = value;
    notifyListeners();
  }

  void reset() {
    _playlists = [];
    _playlistName = null;
    _processing = false;
    notifyListeners();
  }
}

Future<List<Audio>> _parseM3uPlaylist(String path) async {
  final audios = <Audio>[];
  final playlist = await compute(M3uList.loadFromFile, path);

  for (var e in playlist.items) {
    if (e.link.startsWith('http')) {
      audios.add(
        Audio(
          title: e.title,
          url: e.link,
          description: e.link,
          audioType: AudioType.radio,
        ),
      );
    } else if (e.link.isNotEmpty) {
      final file = File(e.link.replaceAll('file://', ''));
      if (file.existsSync() && file.isPlayable) {
        audios.add(Audio.local(file));
      }
    }
  }

  return audios;
}

Future<List<Audio>> _parsePlsPlaylist(String path) async {
  final audios = <Audio>[];
  final playlist = PlsPlaylist.parse(File(path).readAsStringSync());

  for (var e in playlist.entries) {
    if (e.file?.startsWith('http') == true) {
      audios.add(
        Audio(
          title: e.title,
          url: e.file,
          description: e.file,
          audioType: AudioType.radio,
        ),
      );
    } else if (e.file?.isNotEmpty == true) {
      final file = File(e.file!);
      if (file.existsSync() && file.isPlayable) {
        audios.add(Audio.local(file));
      }
    }
  }

  return audios;
}
