import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/widgets.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../lyrics/lyrics_service.dart';
import '../settings_model.dart';

// TODO: localize
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
        'accordance with Genius\'s terms of service.\n\n';

    const tosLink = 'https://genius.com/static/terms';

    const tosLinkText = 'Read Genius\'s Terms of Service';

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
                'To fetch lyrics from Genius, you need to provide a Genius API Key.\n'
                'You can obtain an API key by creating an account on Genius and\n'
                'registering an application to get your access token.',
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          YaruTile(
            title: const Text(
              'Do not use Genius or ask for Genius API Key again',
            ),
            subtitle: const Text(
              'This prevents the app from prompting for the Genius API key in the future and makes the lyrics feature fully rely on local LRC files or LRC strings embedded in audio metadata.',
            ),
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
                                ? Colors.green
                                : Colors.red,
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
