import 'package:ubuntu_service/ubuntu_service.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';
import '../../library.dart';
import 'package:flutter/material.dart';

class AddToPlaylistSnackBar extends StatelessWidget {
  const AddToPlaylistSnackBar({
    super.key,
    required this.libraryModel,
    required this.id,
  });

  final LibraryModel libraryModel;
  final String id;

  @override
  Widget build(BuildContext context) {
    final index = libraryModel.getIndexOfPlaylist(id);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${context.l10n.addedTo} ${id == kLikedAudiosPageId ? context.l10n.likedSongs : id}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (index != null)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ImportantButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                getService<AppStateService>().setAppIndex(index);
              },
              child: Text(context.l10n.open),
            ),
          ),
      ],
    );
  }
}
