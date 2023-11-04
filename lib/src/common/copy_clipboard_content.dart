import 'package:flutter/material.dart';
import 'package:musicpod/src/common/stream_provider_share_button.dart';

import '../l10n/l10n.dart';

class CopyClipboardContent extends StatelessWidget {
  const CopyClipboardContent({
    super.key,
    required this.text,
    this.onSearch,
  });

  final String? text;
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
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  text!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          StreamProviderRow(
            onSearch: onSearch,
            text: text,
          ),
        ],
      ),
    );
  }
}
