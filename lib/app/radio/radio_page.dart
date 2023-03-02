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
  const RadioPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioModel()..init(),
      child: const RadioPage(),
    );
  }

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  bool _searchActive = false;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RadioModel>();
    final playListModel = context.watch<PlaylistModel>();
    final page = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AudioList(
        isLiked: playListModel.isStarredStation,
        listName: context.l10n.radio,
        editableName: false,
        deletable: true,
        showLikeButton: false,
        isLikedIcon: const Icon(YaruIcons.star_filled),
        isUnLikedIcon: const Icon(YaruIcons.star),
        onLike: playListModel.addPlaylist,
        onUnLike: playListModel.removePlaylist,
        audios: model.stations ?? {},
      ),
    );

    final appBar = YaruWindowTitleBar(
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : const SizedBox(
              width: 40,
            ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: YaruIconButton(
              isSelected: _searchActive,
              icon: const Icon(YaruIcons.search),
              onPressed: () => setState(() {
                _searchActive = !_searchActive;
              }),
            ),
          ),
        )
      ],
      title: _searchActive
          ? const SearchField()
          : Center(child: Text(context.l10n.radio)),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: page,
    );
  }
}
