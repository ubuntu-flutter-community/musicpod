import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/radio_collection_view.dart';

part 'radio_collection_view_manager.g.dart';

@Riverpod(keepAlive: true)
class RadioCollectionViewManager extends _$RadioCollectionViewManager {
  @override
  RadioCollectionView build() => RadioCollectionView.stations;

  void setRadioCollectionView(RadioCollectionView value) {
    if (value == state) return;
    state = value;
  }
}
