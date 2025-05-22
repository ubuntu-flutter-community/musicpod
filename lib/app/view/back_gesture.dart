// Code by @whiskeyPeak

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import 'routing_manager.dart';

const double _kButtonSize = 50;
const double _kMaxExtent = 400;

class BackGesture extends StatefulWidget {
  final Widget child;

  const BackGesture({super.key, required this.child});

  @override
  State<BackGesture> createState() => _BackGestureState();
}

class _BackGestureState extends State<BackGesture>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeBackController;
  double _xPosition = 0;
  double _yPosition = 0;
  double _currentExtent = 0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _swipeBackController =
        AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        )..addListener(() {
          _xPosition -=
              (_xPosition + _kButtonSize) * _swipeBackController.value;
        });
  }

  @override
  void dispose() {
    _swipeBackController.dispose();
    super.dispose();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        _currentExtent + details.delta.dx <= _kMaxExtent) {
      _currentExtent += details.delta.dx;
      setState(() {
        _xPosition += details.delta.dx * 0.2;
      });
    }
    if (details.delta.dx < 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        _currentExtent - details.delta.dx >= -_kButtonSize) {
      _currentExtent -= -details.delta.dx;
      setState(() {
        _xPosition -= -details.delta.dx * 0.2;
      });
    }
  }

  void onPanStart(BoxConstraints constraints) {
    _swipeBackController.reset();
    _currentExtent = 0;
    _xPosition = 0 - _kButtonSize;
    _yPosition = (constraints.maxHeight - _kButtonSize) / 2;
    setState(() {
      _isVisible = true;
    });
  }

  void onPanEnd() {
    _swipeBackController.forward().whenComplete(() {
      _swipeBackController.reset();
      setState(() {
        _isVisible = false;
      });
    });
    if (_currentExtent > (_kMaxExtent / 2)) {
      di<RoutingManager>().pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: onPanUpdate,
          onPanStart: (_) => onPanStart(constraints),
          onPanEnd: (details) => onPanEnd(),
          child: Stack(
            children: <Widget>[
              widget.child,
              if (di<RoutingManager>().canPop)
                AnimatedBuilder(
                  animation: _swipeBackController,
                  builder: (context, child) {
                    return Positioned(
                      top: _yPosition,
                      left: _xPosition,
                      child: Visibility(
                        visible: _isVisible,
                        child: SizedBox(
                          width: _kButtonSize,
                          height: _kButtonSize,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: context.theme.isLight
                                  ? Colors.grey[100]
                                  : Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  _kButtonSize,
                                ),
                              ),
                            ),
                            child: Icon(Iconz.goBack),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
