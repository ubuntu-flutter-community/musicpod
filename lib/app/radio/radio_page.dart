import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/app/radio/radio_model.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  static Widget create(BuildContext context, [bool showWindowControls = true]) {
    return ChangeNotifierProvider(
      create: (_) => RadioModel()..init(),
      child: RadioPage(
        showWindowControls: showWindowControls,
      ),
    );
  }

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RadioModel>();
    final playListModel = context.watch<PlaylistModel>();
    final page = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AudioList(
        showTrack: false,
        isLiked: playListModel.isStarredStation,
        listName: context.l10n.radio,
        editableName: false,
        deletable: true,
        likeButton: const SizedBox.shrink(),
        isLikedIcon: const Icon(YaruIcons.star_filled),
        isUnLikedIcon: const Icon(YaruIcons.star),
        onLike: playListModel.addPlaylist,
        onUnLike: playListModel.removePlaylist,
        audios: model.stations ?? {},
      ),
    );

    final appBar = YaruWindowTitleBar(
      style: widget.showWindowControls
          ? YaruTitleBarStyle.normal
          : YaruTitleBarStyle.undecorated,
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : const SizedBox(
              width: 40,
            ),
      title:
          SearchField(spawnPageWithWindowControls: widget.showWindowControls),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: page,
    );
  }
}
