import 'package:safe_change_notifier/safe_change_notifier.dart';

class AppModel extends SafeChangeNotifier {
  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }
}
