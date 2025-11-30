import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/widgets.dart';

import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
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

    const disclaimer =
        'MusicPod, its contributors, and the\n'
        'Genius API are not responsible for any misuse of the API key.\n'
        'By providing your API key, you agree to use it responsibly and in\n'
        'accordance with Genius\'s terms of service.\n';

    const tosLink = 'https://genius.com/static/terms';

    const tosLinkText = 'Read Genius\'s Terms of Service';

    return YaruSection(
      // TODO: localize
      headline: const Text('Lyrics Settings'),
      margin: const EdgeInsets.all(kLargestSpace),
      child: Column(
        children: [
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
                      const TextSpan(text: disclaimer),
                      TextSpan(
                        text: tosLinkText,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(Uri.parse(tosLink)),
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
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        onPressed: () => showFutureLoadingDialog(
                          context: context,
                          future: () async {
                            final token = _geniusApiKeyController.text;
                            OnlineLyricsService.refreshRegistration(
                              geniusAccessToken: token,
                              localLyricsService: di<LocalLyricsService>(),
                            );
                            await di<SettingsModel>()
                                .setLyricsGeniusAccessToken(token);
                          },
                        ),
                      ),
                      IconButton(
                        style: getTextFieldSuffixStyle(context, true),
                        icon: Icon(_showToken ? Iconz.hide : Iconz.show),
                        onPressed: () {
                          setState(() {
                            _showToken = !_showToken;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (kDebugMode)
            YaruTile(
              title: ElevatedButton(
                onPressed: () =>
                    di<SettingsModel>().setNeverAskAgainForGeniusToken(false),
                child: const Text('Debug: Reset "Never Ask Again" Flag'),
              ),
            ),
        ],
      ),
    );
  }
}
