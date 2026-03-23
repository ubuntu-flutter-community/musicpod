import 'dart:async';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import 'local_audio_service.dart';

@lazySingleton
class LocalAudioManager {
  LocalAudioManager({required LocalAudioService localAudioService})
    : _localAudioService = localAudioService;

  final LocalAudioService _localAudioService;

  void changeMetadata(
    Audio audio, {
    Function? onChange,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? discTotal,
    String? discNumber,
    String? trackNumber,
    String? durationMs,
    String? year,
    List<Picture>? pictures,
  }) => _localAudioService.changeMetadata(
    audio,
    onChange: onChange,
    title: title,
    artist: artist,
    album: album,
    genre: genre,
    discTotal: discTotal,
    discNumber: discNumber,
    trackNumber: trackNumber,
    durationMs: durationMs,
    year: year,
    pictures: pictures,
  );

  final allowReorder = SafeValueNotifier<bool>(false);
  void setAllowReorder(bool value) {
    if (value == allowReorder.value) return;
    allowReorder.value = value;
  }

  final useArtistGridView = SafeValueNotifier<bool>(true);
  void setUseArtistGridView(bool value) {
    if (value == useArtistGridView.value) return;
    useArtistGridView.value = value;
  }

  final showPlaylistAddAudios = SafeValueNotifier<bool>(false);
  void setShowPlaylistAddAudios(bool value) {
    if (value == showPlaylistAddAudios.value) return;
    showPlaylistAddAudios.value = value;
    if (showPlaylistAddAudios.value && audios == null) {
      initAudiosCommand.run((
        directory: null,
        forceInit: false,
        extraAudios: [],
      ));
    }
  }

  List<Audio>? get audios => _localAudioService.audios;
  List<String>? get allArtists => _localAudioService.allArtists;
  List<String>? get allGenres => _localAudioService.allGenres;
  List<String>? get allAlbumIDs => _localAudioService.allAlbumIDs;

  String? findAlbumId({required String artist, required String album}) =>
      _localAudioService.findAlbumId(artist: artist, album: album);

  List<Audio>? getCachedAlbum(String albumId) =>
      _localAudioService.getCachedAlbum(albumId);
  Future<List<Audio>?> findAlbum(
    String albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) => _localAudioService.findAlbum(albumId, audioFilter);

  String? getCachedCoverPath(String albumId) =>
      _localAudioService.getCachedCoverPath(albumId);
  Future<String?> findCoverPath(String albumId) async =>
      _localAudioService.findCoverPath(albumId);

  List<Audio>? getCachedTitlesOfArtist(String artist) =>
      _localAudioService.getCachedTitlesOfArtist(artist);
  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async => _localAudioService.findTitlesOfArtist(artist, audioFilter);

  List<String>? getCachedAlbumIDsOfGenre(String albumId) =>
      _localAudioService.getCachedAlbumIDsOfGenre(albumId);
  Future<List<String>?> findAlbumsIDOfGenre(String genre) async =>
      _localAudioService.findAlbumIDsOfGenre(genre);

  Set<Uint8List>? findLocalCovers({
    required List<Audio> audios,
    int limit = 4,
  }) => _localAudioService.findLocalCovers(audios: audios, limit: limit);

  List<Audio> findUniqueAlbumAudios(List<Audio> audios) =>
      _localAudioService.findUniqueAlbumAudios(audios);

  List<String>? findAllAlbumIDs({String? artist, bool clean = true}) =>
      _localAudioService.findAllAlbumIDs(artist: artist, clean: clean);

  late final Command<
    ({bool forceInit, String? directory, List<Audio> extraAudios}),
    ({List<Audio> audios, List<String> failedImports})?
  >
  initAudiosCommand = Command.createAsync((param) async {
    final failedImports = await _localAudioService.init(
      forceInit: param.forceInit,
      newDirectory: param.directory,
      extraAudios: param.extraAudios,
    );

    return (
      audios: _localAudioService.audios ?? [],
      failedImports: failedImports,
    );
  }, initialValue: null);
}
