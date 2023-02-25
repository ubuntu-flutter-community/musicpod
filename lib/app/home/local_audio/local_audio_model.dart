import 'package:safe_change_notifier/safe_change_notifier.dart';

class LocalAudioModel extends SafeChangeNotifier {
  String? _directory;
  String? get directory => _directory;
  set directory(String? value) {
    if (value == null || value == _directory) return;
    _directory = value;
    notifyListeners();
  }

  void init() {}
}
