import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/page_ids.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/local_audio_view.dart';

class EditPlaylistDialog extends StatefulWidget {
  const EditPlaylistDialog({
    super.key,
    this.playlistName,
    this.initialValue,
    this.label,
    this.audios,
    this.allowDelete = false,
    this.allowRename = false,
    this.allowCreate = false,
    this.allowExport = false,
  });

  final List<Audio>? audios;
  final String? playlistName, initialValue, label;
  final bool allowRename, allowDelete, allowCreate, allowExport;

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final l10n = context.l10n;
    return AlertDialog(
      content: SizedBox(
        height: 200,
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  label: Text(
                    widget.label ?? context.l10n.setPlaylistNameAndAddMoreLater,
                  ),
                ),
                controller: _controller,
              ),
            ),
            const SizedBox(
              height: kLargestSpace,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.l10n.cancel,
                    ),
                  ),
                  if (widget.allowExport)
                    OutlinedButton(
                      onPressed: widget.playlistName == null ||
                              widget.audios == null
                          ? null
                          : () => di<CustomContentModel>().exportPlaylistToM3u(
                                id: widget.playlistName!,
                                audios: widget.audios!,
                              ),
                      child: Text(l10n.exportPlaylistToM3UFile),
                    ),
                  if (widget.allowDelete && widget.playlistName != null)
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        libraryModel.removePlaylist(widget.playlistName!);
                        di<LocalAudioModel>().localAudioindex =
                            LocalAudioView.playlists.index;
                        await libraryModel.push(
                          pageId: PageIDs.localAudio,
                          replace: true,
                        );
                      },
                      child: Text(
                        context.l10n.deletePlaylist,
                      ),
                    ),
                  if (widget.allowRename && widget.playlistName != null)
                    ImportantButton(
                      onPressed: () {
                        di<LocalAudioModel>().localAudioindex =
                            LocalAudioView.playlists.index;
                        libraryModel
                          ..push(pageId: PageIDs.likedAudios)
                          ..updatePlaylistName(
                            widget.playlistName!,
                            _controller.text,
                          );
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        context.l10n.save,
                      ),
                    ),
                  if (widget.allowCreate)
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return ImportantButton(
                          onPressed: _controller.text.isEmpty
                              ? null
                              : () async {
                                  await libraryModel.addPlaylist(
                                    _controller.text,
                                    [],
                                  ).then((_) async {
                                    if (context.mounted) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    }
                                    await Future.delayed(
                                      const Duration(milliseconds: 300),
                                    );
                                    await libraryModel.push(
                                      pageId: _controller.text,
                                    );
                                  });
                                },
                          child: Text(
                            context.l10n.add,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
