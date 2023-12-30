import '../../common.dart';
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
    final playlist = libraryModel.getPlaylistById(id);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${context.l10n.addedTo} $id',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (playlist != null)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ImportantButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                libraryModel.setIndex(libraryModel.getIndexOfPlaylist(id));
              },
              child: Text(context.l10n.open),
            ),
          ),
      ],
    );
  }
}
