import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/radio_service.dart';
import '../../search/search_model.dart';

class CustomStationSection extends StatefulWidget {
  const CustomStationSection({super.key});

  @override
  State<CustomStationSection> createState() => _AddStationDialogState();
}

class _AddStationDialogState extends State<CustomStationSection> {
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
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextField(
          autofocus: true,
          controller: _urlController,
          decoration: const InputDecoration(label: Text('Url')),
        ),
        const SizedBox(
          height: kLargestSpace,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: kLargestSpace),
          child: YaruInfoBox(
            yaruInfoType: YaruInfoType.warning,
            trailing: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kYaruButtonRadius),
                ),
                foregroundColor: YaruInfoType.warning.getColor(context),
              ),
              onPressed: () {
                di<SearchModel>().setAudioType(AudioType.radio);
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
              },
              child: Text(l10n.search),
            ),
            subtitle: Text(
              l10n.customStationWarning,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ListenableBuilder(
                listenable: _urlController,
                builder: (context, _) => ListenableBuilder(
                  listenable: _urlController,
                  builder: (context, _) => ElevatedButton(
                    onPressed: _urlController.text.isEmpty ||
                            !_urlController.text.startsWith('http')
                        ? null
                        : () {
                            di<RadioService>()
                                .getStationByUrl(_urlController.text)
                                .then(
                              (v) {
                                if (v?.stationUUID == null) {
                                  if (context.mounted) {
                                    showSnackBar(
                                      context: context,
                                      content: Text(
                                        context.l10n.noStationFound,
                                      ),
                                    );
                                  }

                                  return;
                                } else {
                                  di<LibraryModel>()
                                      .addStarredStation(v!.stationUUID);
                                }
                              },
                            );
                          },
                    child: Text(
                      context.l10n.search,
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
