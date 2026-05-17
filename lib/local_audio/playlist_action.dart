import '../common/data/audio.dart';

enum PlaylistAction {
  create,
  delete,
  replaceWith,
  addTo,
  removeFrom,
  updateName,
  moveWithin,
}

class PlaylistChange {
  PlaylistChange({
    required this.id,
    this.audios,
    required this.action,
    this.external = false,
    this.oldIndex,
    this.newIndex,
    this.newName,
  });

  final String id;
  final List<Audio>? audios;
  final PlaylistAction action;
  final int? oldIndex;
  final int? newIndex;
  final String? newName;
  final bool external;
}
