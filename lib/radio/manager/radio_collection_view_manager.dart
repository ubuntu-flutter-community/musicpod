import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../data/radio_collection_view.dart';

@lazySingleton
class RadioCollectionViewManager {
  final radioCollectionView = SafeValueNotifier<RadioCollectionView>(
    RadioCollectionView.stations,
  );
  void setRadioCollectionView(RadioCollectionView value) {
    if (value == radioCollectionView.value) return;
    radioCollectionView.value = value;
  }
}
