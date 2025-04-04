import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';
import 'package:path/path.dart';
import 'package:pls/pls.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../extensions/media_file_x.dart';
import '../external_path/external_path_service.dart';

class CustomContentModel extends SafeChangeNotifier {
  CustomContentModel({required ExternalPathService externalPathService})
      : _externalPathService = externalPathService;

  final ExternalPathService _externalPathService;

  List<({List<Audio> audios, String name})> _playlists = [];
  List<({List<Audio> audios, String name})> get playlists => _playlists;
  void setPlaylists(List<({List<Audio> audios, String name})> value) {
    _playlists = value;
    notifyListeners();
  }

  void removePlaylist({
    required String name,
  }) {
    _playlists.removeWhere((e) => e.name == name);
    notifyListeners();
  }

  Future<void> addPlaylists({List<XFile>? files}) async => setPlaylists(
        [..._playlists, ...await loadPlaylists(files: files)],
      );

  Future<List<({List<Audio> audios, String name})>> loadPlaylists({
    List<XFile>? files,
  }) async {
    List<({List<Audio> audios, String name})> lists = [];

    try {
      final paths = files?.map((e) => e.path) ??
          await _externalPathService.getPathsOfFiles();
      for (var path in paths) {
        if (path.endsWith('.m3u')) {
          lists.add(
            (
              name: basename(path),
              audios: await _parseM3uPlaylist(path),
            ),
          );
        } else if (path.endsWith('.pls')) {
          lists.add(
            (
              name: basename(path),
              audios: await _parsePlsPlaylist(path),
            ),
          );
        }
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    return lists;
  }

  Future<List<Audio>> _parseM3uPlaylist(String path) async {
    final audios = <Audio>[];
    final playlist = await M3uList.loadFromFile(path);

    for (var e in playlist.items) {
      String? songName;
      String? artist;
      var split = e.title.split(' - ');
      if (split.isNotEmpty) {
        artist = split.elementAtOrNull(0);
        songName = split.elementAtOrNull(1);
      }

      if (e.link.startsWith('http')) {
        audios.add(
          Audio(
            title: songName ?? e.title,
            artist: artist,
            url: e.link,
            description: e.link,
            audioType: AudioType.radio,
          ),
        );
      } else if (e.link.isNotEmpty) {
        final file = File(e.link.replaceAll('file://', ''));
        if (file.existsSync() && file.isPlayable) {
          Audio.local(file, getImage: true);
        }
      }
    }

    return audios;
  }

  Future<List<Audio>> _parsePlsPlaylist(String path) async {
    final audios = <Audio>[];
    final playlist = PlsPlaylist.parse(File(path).readAsStringSync());

    for (var e in playlist.entries) {
      String? songName;
      String? artist;
      var split = e.title?.split(' - ');
      if (split?.isNotEmpty == true) {
        artist = split?.elementAtOrNull(0);
        songName = split?.elementAtOrNull(1);
      }

      if (e.file?.startsWith('http') == true) {
        audios.add(
          Audio(
            title: songName ?? e.title,
            artist: artist,
            url: e.file,
            description: e.file,
            audioType: AudioType.radio,
          ),
        );
      } else if (e.file?.isNotEmpty == true) {
        final file = File(e.file!);
        if (file.existsSync() && file.isPlayable) {
          audios.add(Audio.local(file, getImage: true));
        }
      }
    }

    return audios;
  }

  Future<void> exportPlaylistToM3u({
    required String id,
    required List<Audio> audios,
  }) async {
    final path = await _externalPathService.getPathOfDirectory();
    if (path == null) return;

    final m3uAsString = StringBuffer();
    m3uAsString.writeln('#EXTM3U');
    for (var audio in audios) {
      if (audio.url != null) {
        m3uAsString.writeln('#EXTINF:-1, ${audio.artist} - ${audio.title}');
        m3uAsString.writeln(audio.url);
      } else {
        m3uAsString.writeln('#EXTINF:-1, ${audio.artist} - ${audio.title}');
        m3uAsString.writeln(audio.path);
      }
    }
    File(join(path, '$id.m3u')).writeAsStringSync(m3uAsString.toString());
  }
}
