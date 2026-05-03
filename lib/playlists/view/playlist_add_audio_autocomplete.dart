import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../settings/settings_model.dart';

class PlaylistAddAudioAutoCompleteOrShrink extends StatelessWidget
    with WatchItMixin {
  const PlaylistAddAudioAutoCompleteOrShrink({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final show = watchValue((LocalAudioManager m) => m.showPlaylistAddAudios);

    return AnimatedContainer(
      width: 400,
      duration: const Duration(milliseconds: 300),
      child: !show
          ? const SizedBox.shrink()
          : PlaylistAddAudioAutoComplete(pageId: pageId),
    );
  }
}

class PlaylistAddAudioAutoComplete extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const PlaylistAddAudioAutoComplete({
    super.key,
    required this.pageId,
    this.textStyle,
  });

  final String pageId;
  final TextStyle? textStyle;

  @override
  State<PlaylistAddAudioAutoComplete> createState() =>
      _PlaylistAddAudioAutoCompleteState();
}

class _PlaylistAddAudioAutoCompleteState
    extends State<PlaylistAddAudioAutoComplete> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final fallBackTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    final allAudiosResults = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.results,
    );
    final allAudios = allAudiosResults.data?.audios ?? [];
    final isRunning = allAudiosResults.isRunning;
    final error = allAudiosResults.error;
    final playlist = watchPropertyValue(
      (LocalAudioManager m) => m.getPlaylistById(widget.pageId) ?? [],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: kMediumSpace),
      child: SizedBox(
        width: 400,
        height: 50,
        child: isRunning
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: kMediumSpace),
                  child: LinearProgress(),
                ),
              )
            : error != null
            ? Center(child: Text(error.toString()))
            : Autocomplete<Audio>(
                focusNode: _focusNode,
                textEditingController: _controller,
                displayStringForOption: (option) =>
                    '${option.artist} - ${option.title}',
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      final hintText =
                          '${context.l10n.search}: ${context.l10n.localAudio}';
                      return TextField(
                        controller: textEditingController,
                        autofocus: true,
                        maxLines: 1,
                        onTap: () {
                          textEditingController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset:
                                textEditingController.value.text.length,
                          );
                        },
                        style: useYaruTheme ? theme.textTheme.bodyMedium : null,
                        strutStyle: useYaruTheme
                            ? const StrutStyle(leading: 0.2)
                            : null,
                        textAlignVertical: useYaruTheme
                            ? TextAlignVertical.center
                            : null,
                        cursorWidth: useYaruTheme ? 1 : 2.0,
                        decoration: useYaruTheme
                            ? createYaruDecoration(
                                theme: theme,
                                hintText: hintText,
                              )
                            : createMaterialDecoration(
                                colorScheme: colorScheme,
                                hintText: hintText,
                              ),

                        focusNode: focusNode,
                        onSubmitted: (String value) {
                          setState(() {});
                          onFieldSubmitted();
                          textEditingController.clear();
                          focusNode.requestFocus();
                        },
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 400,
                      height: (options.length * 50) > 400
                          ? 400
                          : options.length * 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Material(
                          color: theme.isLight
                              ? colorScheme.surface
                              : colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                          ),
                          elevation: 1,
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              return Builder(
                                builder: (BuildContext context) {
                                  final bool highlight =
                                      AutocompleteHighlightedOption.of(
                                        context,
                                      ) ==
                                      index;
                                  if (highlight) {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((
                                          Duration timeStamp,
                                        ) {
                                          Scrollable.ensureVisible(
                                            context,
                                            alignment: 0.5,
                                          );
                                        });
                                  }
                                  final t = options.elementAt(index);
                                  return _AudioTile(
                                    onSelected: (v) {
                                      setState(() {});
                                      onSelected(v);
                                      _controller.clear();
                                      _focusNode.requestFocus();
                                    },
                                    fallBackTextStyle: fallBackTextStyle,
                                    highlight: highlight,
                                    theme: theme,
                                    t: t,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                optionsBuilder: (textEditingValue) {
                  final options = allAudios
                      .whereNot(
                        (oneOfAll) => playlist.any(
                          (playlistElement) => playlistElement == oneOfAll,
                        ),
                      )
                      .toList();

                  if (textEditingValue.text.isEmpty) {
                    return options;
                  }
                  return options.where(
                    (a) => '${a.artist} ${a.title}'.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (option) => di<LocalAudioManager>()
                    .addAudiosToPlaylist(id: widget.pageId, audios: [option]),
              ),
      ),
    );
  }
}

class _AudioTile extends StatelessWidget {
  const _AudioTile({
    required this.fallBackTextStyle,
    required this.highlight,
    required this.theme,
    required this.t,
    required this.onSelected,
  });

  final TextStyle? fallBackTextStyle;
  final bool highlight;
  final ThemeData theme;
  final Audio t;
  final void Function(Audio tag) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 10, right: 5),
      titleTextStyle: fallBackTextStyle?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      hoverColor: highlight ? theme.focusColor : null,
      tileColor: highlight ? theme.focusColor : null,
      onTap: () => onSelected(t),
      title: Text('${t.artist} - ${t.title}'),
    );
  }
}
