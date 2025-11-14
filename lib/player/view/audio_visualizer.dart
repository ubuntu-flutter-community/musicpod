import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

import '../../extensions/build_context_x.dart';
import '../player_model.dart';
import '../player_service.dart';

class AudioVisualizer extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AudioVisualizer({super.key, required this.height});

  final double height;

  @override
  _AudioVisualizerState createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  late WaveformController _controller;
  StreamSubscription<Duration?>? _sub;
  final ran = Random();

  @override
  void initState() {
    super.initState();
    _controller = WaveformController();
    final playerService = di<PlayerService>();
    final player = playerService.player;
    _sub ??= player.stream.position.listen((event) {
      _controller.updateAmplitude(
        playerService.player.state.audioBitrate == 0
            ? 0
            : (ran.nextDouble()) * 0.9,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void onAudioData(List<double> audioSamples) {
    // Calculate RMS amplitude from audio samples
    final amplitude = calculateRMS(audioSamples);

    // Update the waveform (amplitude should be 0.0 to 1.0)
    _controller.updateAmplitude(amplitude);
  }

  double calculateRMS(List<double> samples) {
    double sum = 0.0;
    for (double sample in samples) {
      sum += sample * sample;
    }
    return sqrt(sum / samples.length);
  }

  @override
  Widget build(BuildContext context) {
    final color = watchPropertyValue((PlayerModel m) => m.color);
    return WaveformWidget(
      controller: _controller,
      height: widget.height,
      style: WaveformStyle(
        waveColor: color ?? context.colorScheme.primary,
        barCount: 35,
        backgroundColor: Colors.transparent,
        waveformStyle: WaveformDrawStyle.bars,
      ),
    );
  }
}
