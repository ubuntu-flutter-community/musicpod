import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.image,
    required this.name,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.album,
    required this.addPinnedAlbum,
    required this.showWindowControls,
  });

  final Widget image;
  final String? name;
  final bool Function(String name) isPinnedAlbum;
  final void Function(String name) removePinnedAlbum;
  final Set<Audio>? album;
  final void Function(String name, Set<Audio> audios) addPinnedAlbum;
  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      audioPageType: AudioPageType.album,
      pageLabel: context.l10n.album,
      image: image,
      controlPageButton: name == null
          ? null
          : isPinnedAlbum(name!)
              ? YaruIconButton(
                  icon: Icon(
                    YaruIcons.pin,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => removePinnedAlbum(
                    name!,
                  ),
                )
              : YaruIconButton(
                  icon: const Icon(
                    YaruIcons.pin,
                  ),
                  onPressed: album == null
                      ? null
                      : () => addPinnedAlbum(
                            name!,
                            album!,
                          ),
                ),
      showWindowControls: showWindowControls,
      deletable: false,
      audios: album,
      pageId: name!,
      editableName: false,
    );
  }
}
