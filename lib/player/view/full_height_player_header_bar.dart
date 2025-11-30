import 'package:flutter/material.dart';
import '../../common/view/header_bar.dart';

class FullHeightPlayerHeaderBar extends StatelessWidget {
  const FullHeightPlayerHeaderBar({super.key, required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      adaptive: false,
      includeBackButton: false,
      includeSidebarButton: false,
      title: const Text('', maxLines: 1, overflow: TextOverflow.ellipsis),
      foregroundColor: isVideo == true ? Colors.white : null,
      backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
    );
  }
}
