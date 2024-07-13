import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';

import '../../data.dart';
import '../../media_file_x.dart';
import '../settings/settings_service.dart';

class LocalAudioService {
  final SettingsService _settingsService;

  Set<Audio>? _audios;
  LocalAudioService({required SettingsService settingsService})
      : _settingsService = settingsService;
  Set<Audio>? get audios => _audios;
  set audios(Set<Audio>? value) {
    _updateAudios(value);
  }

  final _audiosController = StreamController<bool>.broadcast();
  Stream<bool> get audiosChanged => _audiosController.stream;
  void _updateAudios(Set<Audio>? value) {
    _audios = value;
    _audiosController.add(true);
  }

  Future<List<String>> init({@visibleForTesting String? testDir}) async {
    final result = await compute(_init, testDir ?? _settingsService.directory);
    audios = result.audios;
    return result.failedImports;
  }

  Future<void> dispose() async {
    await _audiosController.close();
  }
}

FutureOr<ImportResult> _init(String? directory) async {
  Set<Audio> newAudios = {};
  List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    for (var e in Directory(directory)
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((e) => e.isValidMedia)
        .toList()) {
      try {
        final metadata = await readMetadata(e, getImage: true);
        newAudios.add(Audio.fromMetadata(path: e.path, data: metadata));
      } catch (error) {
        failedImports.add(e.path);
      }
    }
  }

  return (audios: newAudios, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, Set<Audio> audios});
