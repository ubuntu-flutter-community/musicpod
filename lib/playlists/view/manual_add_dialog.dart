import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../podcasts/podcast_utils.dart';

class ManualAddDialog extends StatelessWidget {
  const ManualAddDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              backgroundColor: Colors.transparent,
              title: Text(context.l10n.add),
            )
          : null,
      titlePadding: yaruStyled ? EdgeInsets.zero : null,
      content: SizedBox(
        height: 200,
        width: 400,
        child: Navigator(
          onPopPage: (route, result) => route.didPop(result),
          key: manualAddNavigatorKey,
          initialRoute: '/chose',
          onGenerateRoute: (settings) {
            Widget page = switch (settings.name) {
              '/addPlaylist' => PlaylistContent(
                  playlistName: context.l10n.createNewPlaylist,
                  libraryModel: di<LibraryModel>(),
                  allowCreate: true,
                ),
              '/addPodcast' => const AddPodcastContent(),
              '/addStation' => const AddStationContent(),
              _ => const SelectAddContent()
            };

            return PageRouteBuilder(
              barrierDismissible: true,
              pageBuilder: (_, __, ___) => page,
              reverseTransitionDuration: const Duration(seconds: 0),
              transitionDuration: const Duration(milliseconds: 0),
            );
          },
        ),
      ),
    );
  }
}

class SelectAddContent extends StatelessWidget {
  const SelectAddContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routes = <String, String>{
      '/addPlaylist': context.l10n.playlist,
      '/addStation': context.l10n.station,
      '/addPodcast': context.l10n.podcast,
    };
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
        child: YaruBorderContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(routes.length, (index) {
              final route = routes.entries.elementAt(index);
              final listTile = ListTile(
                title: Text(route.value),
                onTap: () =>
                    manualAddNavigatorKey.currentState?.pushNamed(route.key),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                trailing: Icon(Iconz().goNext),
              );

              if (index != routes.length - 1) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [listTile, const Divider()],
                );
              }

              return listTile;
            }),
          ),
        ),
      ),
    );
  }
}

class PlaylistContent extends StatefulWidget {
  const PlaylistContent({
    super.key,
    this.playlistName,
    this.initialValue,
    this.audios,
    this.allowDelete = false,
    this.allowRename = false,
    this.allowCreate = false,
    required this.libraryModel,
  });

  final LibraryModel libraryModel;
  final Set<Audio>? audios;
  final String? playlistName;
  final String? initialValue;
  final bool allowRename, allowDelete, allowCreate;

  @override
  State<PlaylistContent> createState() => _PlaylistContentState();
}

class _PlaylistContentState extends State<PlaylistContent> {
  late TextEditingController _controller;
  late TextEditingController _fileController;

  Set<Audio>? _audios;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _fileController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fileController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(label: Text(context.l10n.playlist)),
            controller: _controller,
            onChanged: (v) => setState(() => _controller.text = v),
          ),
        ),
        if (widget.allowCreate)
          TextField(
            controller: _fileController,
            decoration: InputDecoration(
              label: Text(context.l10n.loadFromFileOptional),
              suffixIcon: TextButton(
                onPressed: () async {
                  final audios =
                      await di<ExternalPathService>().loadPlaylistFromFile();
                  setState(() {
                    _audios = audios.$2;
                    _fileController.text = audios.$1 ?? '';
                  });
                },
                child: Text(context.l10n.open),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
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
              if (widget.allowDelete && widget.playlistName != null)
                OutlinedButton(
                  onPressed: () {
                    widget.libraryModel.removePlaylist(widget.playlistName!);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    context.l10n.deletePlaylist,
                  ),
                ),
              if (widget.allowRename && widget.playlistName != null)
                ImportantButton(
                  onPressed: () {
                    widget.libraryModel.updatePlaylistName(
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
                ImportantButton(
                  onPressed: _controller.text.isEmpty
                      ? null
                      : () {
                          widget.libraryModel.addPlaylist(
                            _controller.text,
                            _audios ?? widget.audios ?? {},
                          );
                          Navigator.pop(context);

                          widget.libraryModel.pushNamed(_controller.text);
                        },
                  child: Text(
                    context.l10n.add,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddStationContent extends StatefulWidget {
  const AddStationContent({super.key});

  @override
  State<AddStationContent> createState() => _AddStationDialogState();
}

class _AddStationDialogState extends State<AddStationContent> {
  late TextEditingController _urlController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: 10,
        ),
        TextField(
          autofocus: true,
          controller: _urlController,
          decoration: const InputDecoration(label: Text('Url')),
          onChanged: (v) => setState(() => _urlController.text = v),
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(label: Text(context.l10n.station)),
          onChanged: (v) => setState(() => _nameController.text = v),
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
        Align(
          alignment: Alignment.bottomRight,
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
              ImportantButton(
                onPressed:
                    _urlController.text.isEmpty || _nameController.text.isEmpty
                        ? null
                        : () {
                            di<LibraryModel>()
                                .addStarredStation(_urlController.text, {
                              Audio(
                                url: _urlController.text,
                                title: _nameController.text,
                              ),
                            });
                            Navigator.pop(context);
                          },
                child: Text(
                  context.l10n.add,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddPodcastContent extends StatefulWidget {
  const AddPodcastContent({super.key});

  @override
  State<AddPodcastContent> createState() => _AddPodcastContentState();
}

class _AddPodcastContentState extends State<AddPodcastContent> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: 10,
        ),
        TextField(
          autofocus: true,
          controller: _urlController,
          decoration: InputDecoration(label: Text(context.l10n.podcastFeedUrl)),
          onChanged: (v) => setState(() => _urlController.text = v),
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
        Align(
          alignment: Alignment.bottomRight,
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
              ImportantButton(
                onPressed: _urlController.text.isEmpty
                    ? null
                    : () {
                        searchAndPushPodcastPage(
                          context: context,
                          feedUrl: _urlController.text,
                          play: false,
                        );
                      },
                child: Text(
                  context.l10n.search,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
