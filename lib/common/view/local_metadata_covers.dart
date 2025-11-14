import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/picture_type_x.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/local_cover.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'meta_data_dialog.dart';
import 'ui_constants.dart';

class LocalMetadataCovers extends StatefulWidget {
  const LocalMetadataCovers({super.key, required this.audio});

  final Audio audio;

  @override
  State<LocalMetadataCovers> createState() => _LocalMetadataCoversState();
}

class _LocalMetadataCoversState extends State<LocalMetadataCovers> {
  AudioMetadata? data;
  @override
  void initState() {
    super.initState();
    if (widget.audio.path != null) {
      data = readMetadata(File(widget.audio.path!), getImage: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dimension = MetaDataContent.dimension;
    return Padding(
      padding: const EdgeInsets.only(bottom: kLargestSpace),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kMediumSpace),
        child: Stack(
          children: [
            data == null || data!.pictures.isEmpty
                ? widget.audio.path == null || widget.audio.albumId == null
                      ? const SizedBox.shrink()
                      : LocalCover(
                          path: widget.audio.path!,
                          albumId: widget.audio.albumId!,
                          fallback: Icon(Iconz.musicNote, size: dimension / 2),
                          width: dimension,
                          height: dimension,
                          fit: BoxFit.cover,
                        )
                : YaruCarousel(
                    height: dimension,
                    width: dimension,
                    placeIndicatorMarginTop: 0,
                    placeIndicator: false,
                    navigationControls: true,
                    controller: YaruCarouselController(viewportFraction: 1),
                    children: data!.pictures
                        .map(
                          (picture) => Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              Image.memory(
                                picture.bytes,
                                width: dimension,
                                height: dimension,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: kMediumSpace,
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: context.colorScheme.outline,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kMediumSpace,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    isDense: true,
                                    icon: Icon(Iconz.dropdown),
                                    underline: const SizedBox.shrink(),
                                    value: picture.pictureType,
                                    items: PictureType.values
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: SizedBox(
                                              width: dimension / 2,
                                              child: Tooltip(
                                                message: e.localize(
                                                  context.l10n,
                                                ),
                                                child: Text(
                                                  e.localize(context.l10n),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      di<LocalAudioModel>().changeMetadata(
                                        widget.audio,
                                        pictures: [
                                          if (data?.pictures != null)
                                            ...data!.pictures.map((e) {
                                              if (v != null &&
                                                  e.pictureType != v &&
                                                  File.fromRawPath(
                                                        e.bytes,
                                                      ).path ==
                                                      File.fromRawPath(
                                                        picture.bytes,
                                                      ).path) {
                                                return Picture(
                                                  e.bytes,
                                                  e.mimetype,
                                                  v,
                                                );
                                              } else {
                                                return e;
                                              }
                                            }),
                                        ],
                                      );
                                      data = readMetadata(
                                        File(widget.audio.path!),
                                        getImage: true,
                                      );
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
            Positioned(
              top: kMediumSpace,
              right: kMediumSpace,
              child: FloatingActionButton.small(
                child: Icon(Iconz.plus),
                onPressed: () async {
                  final paths = await di<ExternalPathService>()
                      .getPathsOfFiles();
                  di<LocalAudioModel>().changeMetadata(
                    widget.audio,
                    pictures: [
                      if (data?.pictures != null) ...data!.pictures,
                      ...paths.map(
                        (e) => Picture(
                          File(e).readAsBytesSync(),
                          lookupMimeType(e) ?? '',
                          PictureType.coverFront,
                        ),
                      ),
                    ],
                  );
                  data = readMetadata(File(widget.audio.path!), getImage: true);
                  setState(() {});
                },
              ),
            ),
            Positioned(
              top: kMediumSpace,
              left: kMediumSpace,
              child: FloatingActionButton.small(
                child: Icon(Iconz.refresh),
                onPressed: () async {
                  final paths = await di<ExternalPathService>()
                      .getPathsOfFiles();
                  di<LocalAudioModel>().changeMetadata(
                    widget.audio,
                    pictures: [
                      ...paths.map(
                        (e) => Picture(
                          File(e).readAsBytesSync(),
                          lookupMimeType(e) ?? '',
                          PictureType.illustration,
                        ),
                      ),
                    ],
                  );
                  data = readMetadata(File(widget.audio.path!), getImage: true);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
