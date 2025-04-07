import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../custom_content_model.dart';

class CustomPlaylistsSection extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const CustomPlaylistsSection({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  State<CustomPlaylistsSection> createState() => _CustomPlaylistsSectionState();
}

class _CustomPlaylistsSectionState extends State<CustomPlaylistsSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();
    watchPropertyValue((CustomContentModel m) => m.playlists.length);
    final playlists = di<CustomContentModel>().playlists;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              label: Text(l10n.setPlaylistNameAndAddMoreLater),
            ),
            controller: _controller,
          ),
        ),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.all(kMediumSpace),
              child: Text(l10n.or),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        TextButton(
          onPressed: () => di<CustomContentModel>().addPlaylists(),
          child: Text(l10n.loadFromFileOptional),
        ),
        ...playlists.map(
          (e) => ListTile(
            title: Text(e.id.replaceAll('.m3u', '').replaceAll('.pls', '')),
            subtitle: Text(
              '${e.audios.length} ${l10n.titles}',
            ),
            trailing: IconButton(
              tooltip: l10n.deletePlaylist,
              icon: Icon(
                Iconz.remove,
                semanticLabel: l10n.deletePlaylist,
              ),
              onPressed: () =>
                  di<CustomContentModel>().removePlaylist(name: e.id),
            ),
          ),
        ),
        const SizedBox(
          height: kLargestSpace,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => ImportantButton(
                  onPressed: _controller.text.isEmpty && playlists.isEmpty
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            libraryModel.addPlaylist(
                              _controller.text,
                              [],
                            ).then(
                              (_) {
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    final text = _controller.text;
                                    _controller.clear();
                                    widget.onAdd?.call();
                                    libraryModel.push(pageId: text);
                                  },
                                );
                              },
                            );
                          } else if (playlists.isNotEmpty) {
                            libraryModel.addPlaylists(playlists).then(
                                  (_) => Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      libraryModel.push(
                                        pageId: playlists.first.id,
                                      );
                                      _controller.clear();
                                      di<CustomContentModel>().setPlaylists([]);
                                      widget.onAdd?.call();
                                    },
                                  ),
                                );
                          }
                        },
                  child: Text(
                    l10n.add,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
