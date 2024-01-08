import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../data.dart';

class AppModel extends SafeChangeNotifier {
  void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }

  bool? _fullScreen;
  bool? get fullScreen => _fullScreen;
  void setFullScreen(bool? value) {
    if (value == null || value == _fullScreen) return;
    _fullScreen = value;
    notifyListeners();
  }
}
