import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/data/audio.dart';
import '../../common/page_ids.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/local_audio_view.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/podcast_page.dart';

class ManualAddDialog extends StatelessWidget {
  const ManualAddDialog({
    super.key,
    this.onlyPlaylists = false,
  });

  final bool onlyPlaylists;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              border: BorderSide.none,
              backgroundColor: Colors.transparent,
              title: Text(context.l10n.add),
            )
          : null,
      titlePadding: yaruStyled ? EdgeInsets.zero : null,
      contentPadding: const EdgeInsets.only(
        left: kLargestSpace,
        right: kLargestSpace,
        bottom: kLargestSpace,
      ),
      content: SizedBox(
        height: 220,
        width: 400,
        child: onlyPlaylists
            ? Padding(
                padding: const EdgeInsets.only(top: kLargestSpace),
                child: PlaylistEditDialogContent(
                  playlistName: context.l10n.createNewPlaylist,
                  allowCreate: true,
                ),
              )
            : Navigator(
                // ignore: deprecated_member_use
                onPopPage: (route, result) => route.didPop(result),
                key: manualAddNavigatorKey,
                initialRoute: '/chose',
                onGenerateRoute: (settings) {
                  Widget page = switch (settings.name) {
                    '/addPlaylist' => PlaylistEditDialogContent(
                        playlistName: context.l10n.createNewPlaylist,
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
                trailing: Icon(Iconz.goNext),
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

class PlaylistEditDialogContent extends StatefulWidget {
  const PlaylistEditDialogContent({
    super.key,
    this.playlistName,
    this.initialValue,
    this.audios,
    this.allowDelete = false,
    this.allowRename = false,
    this.allowCreate = false,
  });

  final List<Audio>? audios;
  final String? playlistName;
  final String? initialValue;
  final bool allowRename, allowDelete, allowCreate;

  @override
  State<PlaylistEditDialogContent> createState() =>
      _PlaylistEditDialogContentState();
}

class _PlaylistEditDialogContentState extends State<PlaylistEditDialogContent> {
  late TextEditingController _controller;
  late TextEditingController _fileController;

  List<Audio>? _audios;

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
    final libraryModel = di<LibraryModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(label: Text(context.l10n.playlist)),
            controller: _controller,
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
        const SizedBox(
          height: kLargestSpace,
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                    libraryModel.removePlaylist(widget.playlistName!);
                    di<LocalAudioModel>().localAudioindex =
                        LocalAudioView.playlists.index;
                    await libraryModel.push(
                      pageId: PageIDs.likedAudios,
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
                              await libraryModel
                                  .addPlaylist(
                                _controller.text,
                                _audios ?? widget.audios ?? [],
                              )
                                  .then((_) async {
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
        ),
        const SizedBox(
          height: kLargestSpace,
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(label: Text(context.l10n.station)),
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
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.cancel,
                ),
              ),
              ListenableBuilder(
                listenable: _nameController,
                builder: (context, _) => ListenableBuilder(
                  listenable: _urlController,
                  builder: (context, _) => ImportantButton(
                    onPressed: _urlController.text.isEmpty ||
                            _nameController.text.isEmpty
                        ? null
                        : () {
                            di<LibraryModel>()
                                .addStarredStation(_urlController.text, [
                              Audio(
                                url: _urlController.text,
                                title: _nameController.text,
                              ),
                            ]);
                            Navigator.pop(context);
                          },
                    child: Text(
                      context.l10n.add,
                    ),
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
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.cancel,
                ),
              ),
              ListenableBuilder(
                listenable: _urlController,
                builder: (context, _) => ImportantButton(
                  onPressed: _urlController.text.isEmpty
                      ? null
                      : () {
                          di<PodcastModel>().loadPodcast(
                            feedUrl: _urlController.text,
                            onFind: (podcast) => di<LibraryModel>().push(
                              builder: (_) => PodcastPage(
                                imageUrl: podcast.firstOrNull?.imageUrl,
                                preFetchedEpisodes: podcast,
                                feedUrl: _urlController.text,
                                title: podcast.firstOrNull?.album ??
                                    podcast.firstOrNull?.title ??
                                    _urlController.text,
                              ),
                              pageId: _urlController.text,
                            ),
                          );
                        },
                  child: Text(
                    context.l10n.search,
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
