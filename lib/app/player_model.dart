import 'package:audioplayers/audioplayers.dart';
import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlayerModel extends SafeChangeNotifier {
  PlayerModel() : _audioPlayer = AudioPlayer();

  Audio? _audio;
  Audio? get audio => _audio;
  set audio(Audio? value) {
    if (value == _audio) return;
    _audio = value;
    notifyListeners();
  }

  final AudioPlayer _audioPlayer;

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

  Future<void> play() async {
    if (audio == null) return;

    if (audio!.audioType == AudioType.radio) {
      await _audioPlayer.play(UrlSource(audio!.resourceUrl!));
    }
  }

  Future<void> pause() async {
    if (audio == null) return;

    await _audioPlayer.pause();
  }

  Future<void> seek() async {
    await _audioPlayer.seek(position);
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  void init() {
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      isPlaying = playerState == PlayerState.playing;
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (audio?.audioType != AudioType.radio) {
        duration = newDuration;
      }
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (audio?.audioType != AudioType.radio) {
        position = newPosition;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
