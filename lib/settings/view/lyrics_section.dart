import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../lyrics/lyrics_service.dart';
import '../settings_model.dart';

class LyricsSection extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LyricsSection({super.key});

  @override
  State<LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends State<LyricsSection> {
  late TextEditingController _geniusApiKeyController;
  bool _showToken = false;

  @override
  void initState() {
    super.initState();
    _geniusApiKeyController = TextEditingController(
      text: di<SettingsModel>().lyricsGeniusAccessToken,
    );
  }

  @override
  void dispose() {
    _geniusApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lyricsGeniusAccessToken = watchPropertyValue((SettingsModel m) {
      final lyricsGeniusAccessToken = m.lyricsGeniusAccessToken;
      if (lyricsGeniusAccessToken != _geniusApiKeyController.text &&
          mounted &&
          lyricsGeniusAccessToken != null) {
        _geniusApiKeyController.text = lyricsGeniusAccessToken;
      }
      return lyricsGeniusAccessToken;
    });

    final neverAskAgainForGeniusToken = watchPropertyValue(
      (SettingsModel m) => m.neverAskAgainForGeniusToken,
    );

    return YaruSection(
      headline: const Text('Lyrics Settings'),

      margin: const EdgeInsets.all(kLargestSpace),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                context.l10n.settingsGeniusDescription,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          YaruTile(
            title: Text(context.l10n.settingsDoNotAskForGeniusTitle),
            subtitle: Text(context.l10n.settingsDoNotAskForGeniusDescription),
            trailing: CommonSwitch(
              value: neverAskAgainForGeniusToken,
              onChanged: di<SettingsModel>().setNeverAskAgainForGeniusToken,
            ),
          ),
          YaruTile(
            title: Column(
              spacing: kSmallestSpace,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Genius API Key'),
                RichText(
                  text: TextSpan(
                    style: context.textTheme.bodySmall,
                    children: [
                      TextSpan(text: context.l10n.settingsGeniusDisclaimer),
                      TextSpan(
                        text: context.l10n.tosLinkText,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              launchUrl(Uri.parse(context.l10n.tosLink)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kMediumSpace),
              ],
            ),
            subtitle: SizedBox(
              height: context.buttonHeight - 3,
              child: TextField(
                enabled: !neverAskAgainForGeniusToken,
                obscureText: !_showToken,
                controller: _geniusApiKeyController,
                decoration: InputDecoration(
                  hintText: 'Enter your Genius API Key',
                  suffixIconConstraints: BoxConstraints(
                    minHeight: context.buttonHeight,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Save API Key',
                        style: getTextFieldSuffixStyle(context, false),
                        icon: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Iconz.download,
                            color:
                                lyricsGeniusAccessToken != null &&
                                    lyricsGeniusAccessToken.isNotEmpty
                                ? context.colorScheme.success
                                : context.colorScheme.error,
                          ),
                        ),
                        onPressed: () => showFutureLoadingDialog(
                          title: context.l10n.loadingPleaseWait,
                          context: context,
                          future: () => OnlineLyricsService.refreshRegistration(
                            _geniusApiKeyController.text.trim(),
                          ),
                        ),
                      ),
                      IconButton(
                        style: getTextFieldSuffixStyle(context, true),
                        icon: Icon(_showToken ? Iconz.hide : Iconz.show),
                        onPressed: () =>
                            setState(() => _showToken = !_showToken),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
