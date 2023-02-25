import 'package:safe_change_notifier/safe_change_notifier.dart';

class HomeModel extends SafeChangeNotifier {
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int value) {
    if (value == _selectedTab) return;
    _selectedTab = value;
    notifyListeners();
  }
}
