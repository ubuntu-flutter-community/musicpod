import 'package:flutter/widgets.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class AppModel extends SafeChangeNotifier {
  AppModel()
      : _countryCode = WidgetsBinding
            .instance.platformDispatcher.locale.countryCode
            ?.toLowerCase();

  final String? _countryCode;
  String? get countryCode => _countryCode;

  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }

  bool? _fullWindowMode;
  bool? get fullWindowMode => _fullWindowMode;
  void setFullWindowMode(bool? value) {
    if (value == null || value == _fullWindowMode) return;
    _fullWindowMode = value;
    notifyListeners();
  }
}
