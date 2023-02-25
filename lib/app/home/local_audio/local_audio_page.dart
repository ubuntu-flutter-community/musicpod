import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:music/app/home/local_audio/local_audio_model.dart';
import 'package:provider/provider.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({super.key});

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<LocalAudioModel>();
    return Center(
      child: model.directory == null || model.directory!.isEmpty
          ? ElevatedButton(
              onPressed: () async => model.directory = await getDirectoryPath(),
              child: const Text('Pick your music collection'),
            )
          : Text(model.directory.toString()),
    );
  }
}
