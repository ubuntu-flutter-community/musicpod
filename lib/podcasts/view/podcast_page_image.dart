import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../extensions/build_context_x.dart';
import '../manager/podcast_short_info_manager.dart';

class PodcastPageImage extends ConsumerWidget {
  const PodcastPageImage({
    super.key,
    required this.feedUrl,
    this.showFallBackOrErrorIcon = true,
  });

  final String feedUrl;
  final bool showFallBackOrErrorIcon;

  Widget _fallback(BuildContext context) => showFallBackOrErrorIcon
      ? Center(
          child: Icon(
            Iconz.podcast,
            size: 80,
            color: context.theme.hintColor,
          ),
        )
      : const SizedBox.shrink();

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(
        podcastShortInfoManagerProvider(
          feedUrl,
        ).select((s) => s.whenData((info) => info?.imageUrl)),
      )
      .when(
        data: (imageUrl) {
          final trimmed = imageUrl?.trim();
          if (trimmed == null || trimmed.isEmpty) {
            return _fallback(context);
          }

          final image = SafeNetworkImage(
            loadingWidget: _fallback(context),
            errorWidget: _fallback(context),
            url: trimmed,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.medium,
          );

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            child: image,
            onTap: () => context.dialog(
              (context) => SimpleDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: image,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => _fallback(context),
        error: (_, __) => _fallback(context),
      );
}
