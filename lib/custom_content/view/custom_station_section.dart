import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';

class CustomStationSection extends StatefulWidget {
  const CustomStationSection({super.key});

  @override
  State<CustomStationSection> createState() => _AddStationDialogState();
}

class _AddStationDialogState extends State<CustomStationSection> {
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
