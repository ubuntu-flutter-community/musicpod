import 'package:audioplayers/audioplayers.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlayerModel extends SafeChangeNotifier {
  PlayerModel() : _audioPlayer = AudioPlayer();

  final AudioPlayer? _audioPlayer;
  AudioPlayer? get audioPlayer => _audioPlayer;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  set isPlaying(bool value) {
    if (value == _isPlaying) return;
    _isPlaying = value;
    notifyListeners();
  }

  Duration _duration = Duration.zero;
  Duration get duration => _duration;
  set duration(Duration value) {
    if (value == _duration) return;
    _duration = value;
    notifyListeners();
  }

  Duration _position = Duration.zero;
  Duration get position => _position;
  set position(Duration value) {
    if (value == _position) return;
    _position = value;
    notifyListeners();
  }

  void init() {
    _audioPlayer?.onPlayerStateChanged.listen((playerState) {
      isPlaying = playerState == PlayerState.playing;
    });
    _audioPlayer?.onDurationChanged.listen((newDuration) {
      duration = newDuration;
    });
    _audioPlayer?.onPositionChanged.listen((newPosition) {
      position = newPosition;
    });
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}
