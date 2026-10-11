import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:yaru/yaru.dart';

import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/picture_type_x.dart';
import '../../external_path/service/external_path_service.dart';
import '../../local_audio/data/change_metadata_capsule.dart';
import '../../local_audio/manager/change_local_meta_data_manager.dart';
import '../../local_audio/view/local_cover.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'meta_data_dialog.dart';
import 'ui_constants.dart';

class LocalMetadataCovers extends ConsumerWidget {
  const LocalMetadataCovers({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const dimension = MetaDataContent.dimension;

    final draft = ref.watch(
      changeLocalMetaDataManagerProvider(audio).select((s) => s.draft),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: kLargestSpace),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kMediumSpace),
        child: Stack(
          children: [
            draft?.pictures?.isEmpty ?? true
                ? audio.path == null || audio.albumDbId == null
                      ? const SizedBox.shrink()
                      : LocalCover(
                          albumId: audio.albumDbId!,
                          fallback: Icon(Iconz.musicNote, size: dimension / 2),
                          dimension: dimension,
                        )
                : YaruCarousel(
                    height: dimension,
                    width: dimension,
                    placeIndicatorMarginTop: 0,
                    placeIndicator: false,
                    navigationControls: true,
                    controller: YaruCarouselController(viewportFraction: 1),
                    children:
                        draft?.pictures
                            ?.map(
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
                                      child: DropdownButton<PictureType>(
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
                                        onChanged: (v) => ref
                                            .read(
                                              changeLocalMetaDataManagerProvider(
                                                audio,
                                              ).notifier,
                                            )
                                            .updateDraft(
                                              ChangeMetadataCapsule(
                                                pictures: draft.pictures!.map((e) {
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
                                                }).toList(),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList() ??
                        [],
                  ),
            Positioned(
              top: kMediumSpace,
              right: kMediumSpace,
              child: FloatingActionButton.small(
                child: Icon(Iconz.plus),
                onPressed: () async {
                  final paths = await di<ExternalPathService>()
                      .getPathsOfFiles();
                  ref
                      .read(changeLocalMetaDataManagerProvider(audio).notifier)
                      .updateDraft(
                        ChangeMetadataCapsule(
                          pictures: paths
                              .map(
                                (e) => Picture(
                                  File(e).readAsBytesSync(),
                                  lookupMimeType(e) ?? '',
                                  PictureType.coverFront,
                                ),
                              )
                              .toList(),
                        ),
                      );
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
                  ref
                      .read(changeLocalMetaDataManagerProvider(audio).notifier)
                      .updateDraft(
                        ChangeMetadataCapsule(
                          pictures: [
                            ...paths.map(
                              (e) => Picture(
                                File(e).readAsBytesSync(),
                                lookupMimeType(e) ?? '',
                                PictureType.coverFront,
                              ),
                            ),
                          ],
                        ),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
