import 'package:flutter/material.dart';

import '../../theme.dart';
import '../l10n/l10n.dart';
import 'stream_provider_share_button.dart';

class CopyClipboardContent extends StatelessWidget {
  const CopyClipboardContent({
    super.key,
    required this.text,
    this.onSearch,
  });

  final String text;
  final void Function()? onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Text(
                  context.l10n.copiedToClipBoard,
                  style: TextStyle(
                    color: getSnackBarTextColor(Theme.of(context)),
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          StreamProviderRow(
            iconColor: getSnackBarTextColor(Theme.of(context)),
            onSearch: onSearch,
            text: text,
          ),
        ],
      ),
    );
  }
}
