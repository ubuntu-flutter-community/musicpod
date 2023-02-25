import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({super.key});

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async => await getDirectoryPath(),
        child: const Text('Pick your music collection'),
      ),
    );
  }
}
