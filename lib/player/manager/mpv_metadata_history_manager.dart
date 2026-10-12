import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/mpv_meta_data.dart';

part 'mpv_metadata_history_manager.g.dart';

@Riverpod(keepAlive: true)
class MpvMetadataHistoryManager extends _$MpvMetadataHistoryManager {
  @override
  Map<String, MpvMetaData> build() => const {};

  void add({
    required String icyTitle,
    required MpvMetaData mpvMetaData,
  }) {
    if (!state.containsKey(icyTitle)) {
      state = {
        ...state,
        icyTitle: mpvMetaData,
      };
    }
  }

  void remove(String icyTitle) {
    if (state.containsKey(icyTitle)) {
      final newMap = {...state}..remove(icyTitle);
      state = newMap;
    }
  }

  MpvMetaData? getMetadata(String? icyTitle) =>
      icyTitle == null ? null : state[icyTitle];

  Iterable<MapEntry<String, MpvMetaData>> filteredHistory({
    required String? filter,
  }) => state.entries.where(
    (e) => filter == null
        ? true
        : e.value.icyName.contains(filter) || filter.contains(e.value.icyName),
  );

  String getHistoryList({String? filter}) =>
      filteredHistory(
        filter: filter,
      ).map((e) => '${e.value.icyTitle}\n').toList().reversed.join();
}
