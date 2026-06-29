import 'package:flutter/material.dart';

import '../../common/view/audio_page_type.dart';

class MasterItem {
  MasterItem({
    required this.titleBuilder,
    this.subtitleBuilder,
    required this.pageBuilder,
    required this.iconBuilder,
    required this.pageId,
    required this.audioPageType,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(bool selected) iconBuilder;
  final String pageId;
  final AudioPageType audioPageType;
}
