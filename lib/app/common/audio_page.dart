import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({
    super.key,
    required this.audios,
    required this.pageName,
    this.editableName = true,
    this.audioPageType = AudioPageType.list,
  });

  final Set<Audio> audios;
  final String pageName;
  final bool editableName;
  final AudioPageType audioPageType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        title: const SearchField(),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox(
                width: 40,
              ),
      ),
      body: Column(
        children: [
          if (audioPageType == AudioPageType.albumList)
            FutureBuilder<Color?>(
              future: getColor(audios.firstOrNull),
              builder: (context, snapshot) {
                return Container(
                  height: 240,
                  color: snapshot.data ?? theme.cardColor,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (audios.firstOrNull?.metadata?.picture != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              audios.firstOrNull!.metadata!.picture!.data,
                              width: 200.0,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.album,
                              style: theme.textTheme.labelSmall,
                            ),
                            Text(
                              audios.firstOrNull!.metadata!.album ?? '',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w300,
                                fontSize: 50,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              audios.firstOrNull?.metadata?.artist ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AudioList(
                audios: audios,
                editableName: editableName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AudioPageType {
  albumList,
  list,
  grid,
  artistGrid,
}

Future<Color?> getColor(Audio? audio) async {
  if (audio == null || audio.path == null) return null;

  final image = MemoryImage(
    audio.metadata!.picture!.data,
  );
  final generator = await PaletteGenerator.fromImageProvider(image);
  return generator.dominantColor?.color.withOpacity(0.1);
}
