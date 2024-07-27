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

  int _localAudioIndex = 0;
  int get localAudioindex => _localAudioIndex;
  set localAudioindex(int value) {
    if (value == _localAudioIndex) return;
    _localAudioIndex = value;
    notifyListeners();
  }

  int _radioIndex = 0;
  int get radioindex => _radioIndex;
  set radioindex(int value) {
    if (value == _radioIndex) return;
    _radioIndex = value;
    notifyListeners();
  }

  bool _manualFilter = false;
  bool get manualFilter => _manualFilter;
  void setManualFilter(bool value) {
    if (value == _manualFilter) return;
    _manualFilter = value;
    notifyListeners();
  }

  bool _allowReorder = false;
  bool get allowReorder => _allowReorder;
  void setAllowReorder(bool value) {
    if (value == _allowReorder) return;
    _allowReorder = value;
    notifyListeners();
  }
}
