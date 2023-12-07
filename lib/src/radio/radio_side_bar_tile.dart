import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';

class RadioSideBarTile extends StatefulWidget {
  const RadioSideBarTile({
    super.key,
    required this.station,
    required this.play,
  });

  final MapEntry<String, Set<Audio>> station;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;

  @override
  State<RadioSideBarTile> createState() => _RadioSideBarTileState();
}

class _RadioSideBarTileState extends State<RadioSideBarTile> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(widget.station.key),
          Positioned(
            right: 0,
            child: AnimatedOpacity(
              opacity: _hovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () => widget.play(newAudio: widget.station.value.first),
                child: Icon(
                  Iconz().playFilled,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
