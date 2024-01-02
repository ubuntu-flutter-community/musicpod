import '../../build_context_x.dart';
import '../../data.dart';
import '../../theme_data_x.dart';
import 'full_height_player_image.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

class BlurredFullHeightPlayerImage extends StatelessWidget {
  const BlurredFullHeightPlayerImage({
    super.key,
    required this.size,
    required this.audio,
    required this.isOnline,
  });

  final Size size;
  final Audio? audio;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    return Opacity(
      opacity: theme.isLight ? 0.8 : 0.9,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Blur(
          blur: 20,
          colorOpacity: theme.isLight ? 0.6 : 0.7,
          blurColor:
              theme.isLight ? Colors.white : theme.scaffoldBackgroundColor,
          child: FullHeightPlayerImage(
            borderRadius: BorderRadius.zero,
            audio: audio,
            fit: BoxFit.cover,
            height: size.height,
            width: size.width,
            isOnline: isOnline,
          ),
        ),
      ),
    );
  }
}
