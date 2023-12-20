import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';

class MasterTile extends StatefulWidget {
  const MasterTile({
    super.key,
    required this.onTap,
    this.selected,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onPlay,
  });

  final bool? selected;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final void Function()? onTap;
  final void Function()? onPlay;

  @override
  State<MasterTile> createState() => _MasterTileState();
}

class _MasterTileState extends State<MasterTile> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final yaruMasterTile = YaruMasterTile(
      title: widget.title,
      onTap: widget.onTap,
      selected: widget.selected,
      leading: widget.leading,
      subtitle: widget.subtitle,
      trailing: widget.trailing,
    );

    if (widget.onPlay == null) {
      return yaruMasterTile;
    }

    return MouseRegion(
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: Stack(
        children: [
          yaruMasterTile,
          if (_hovered || widget.selected == true)
            Positioned(
              right: 25,
              top: 12,
              child: CircleAvatar(
                radius: kTinyButtonSize / 2,
                child: IconButton(
                  onPressed: widget.onPlay,
                  icon: Icon(
                    Iconz().playFilled,
                    size: kTinyButtonIconSize,
                    color: context.t.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
