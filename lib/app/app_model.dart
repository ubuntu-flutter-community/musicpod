import 'package:safe_change_notifier/safe_change_notifier.dart';

class AppModel extends SafeChangeNotifier {
  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}
