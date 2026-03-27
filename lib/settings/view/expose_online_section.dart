import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../expose/data/last_fm_credentials.dart';
import '../../expose/expose_manager.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';

class ExposeOnlineSection extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const ExposeOnlineSection({super.key});

  @override
  State<ExposeOnlineSection> createState() => _ExposeOnlineSectionState();
}

class _ExposeOnlineSectionState extends State<ExposeOnlineSection> {
  late TextEditingController _lastFmApiKeyController;
  late TextEditingController _lastFmSecretController;
  late TextEditingController _listenBrainzApiKeyController;
  final _lastFmFormKey = GlobalKey<FormState>();
  final _listenBrainzFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final model = di<SettingsModel>();
    _lastFmApiKeyController = TextEditingController(text: model.lastFmApiKey);
    _lastFmSecretController = TextEditingController(text: model.lastFmSecret);
    _listenBrainzApiKeyController = TextEditingController(
      text: model.listenBrainzApiKey,
    );
  }

  @override
  void dispose() {
    _lastFmApiKeyController.dispose();
    _lastFmSecretController.dispose();
    _listenBrainzApiKeyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final lastFmEnabled = watchPropertyValue(
      (SettingsModel m) => m.enableLastFmScrobbling,
    );

    final listenBrainzEnabled = watchPropertyValue(
      (SettingsModel m) => m.enableListenBrainzScrobbling,
    );

    return YaruSection(
      headline: Text(l10n.exposeOnlineHeadline),
      margin: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      child: Column(
        children: [
          YaruTile(
            title: Row(
              children: space(
                children: [
                  const Icon(TablerIcons.brand_lastfm),
                  if (lastFmEnabled &&
                      watchValue((ExposeManager m) => m.isLastFmAuthorized))
                    Text(l10n.connectedTo),
                  Text(l10n.exposeToLastfmTitle),
                ],
              ),
            ),
            subtitle: Column(children: [Text(l10n.exposeToLastfmSubTitle)]),
            trailing: CommonSwitch(
              value: lastFmEnabled,
              onChanged: (v) {
                di<SettingsModel>().setEnableLastFmScrobbling(v);
              },
            ),
          ),
          if (lastFmEnabled) ...[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _lastFmFormKey,
                onChanged: _lastFmFormKey.currentState?.validate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: space(
                    heightGap: 10,
                    children: [
                      TextFormField(
                        obscureText: true,
                        controller: _lastFmApiKeyController,
                        decoration: InputDecoration(
                          hintText: l10n.lastfmApiKey,
                          label: Text(l10n.lastfmApiKey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.lastfmApiKeyEmpty;
                          }
                          return null;
                        },
                        onChanged: (_) =>
                            _lastFmFormKey.currentState?.validate(),
                        onFieldSubmitted: (value) async {
                          if (_lastFmFormKey.currentState!.validate()) {
                            di<SettingsModel>().setLastFmApiKey(value);
                          }
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        controller: _lastFmSecretController,
                        decoration: InputDecoration(
                          hintText: l10n.lastfmSecret,
                          label: Text(l10n.lastfmSecret),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.lastfmSecretEmpty;
                          }
                          return null;
                        },
                        onChanged: (_) =>
                            _lastFmFormKey.currentState?.validate(),
                        onFieldSubmitted: (value) async {
                          if (_lastFmFormKey.currentState!.validate()) {
                            di<SettingsModel>().setLastFmSecret(value);
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            di<ExposeManager>().authorizeLastFmCommand.run(
                              LastFmCredentials(
                                apiKey: _lastFmApiKeyController.text,
                                apiSecret: _lastFmSecretController.text,
                              ),
                            ),
                        child: Text(l10n.saveAndAuthorize),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          YaruTile(
            title: Row(
              children: space(
                children: [
                  const ImageIcon(
                    AssetImage('assets/images/listenbrainz-icon.png'),
                  ),
                  Text(l10n.exposeToListenBrainzTitle),
                ],
              ),
            ),
            subtitle: Text(l10n.exposeToListenBrainzSubTitle),
            trailing: CommonSwitch(
              value: listenBrainzEnabled,
              onChanged: di<SettingsModel>().setEnableListenBrainzScrobbling,
            ),
          ),
          if (listenBrainzEnabled) ...[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: space(
                  heightGap: 10,
                  children: [
                    Form(
                      key: _listenBrainzFormKey,
                      onChanged: _listenBrainzFormKey.currentState?.validate,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _listenBrainzApiKeyController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: l10n.listenBrainzApiKey,
                              label: Text(l10n.listenBrainzApiKey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.listenBrainzApiKeyEmpty;
                              }
                              return null;
                            },
                            onChanged: (_) =>
                                _listenBrainzFormKey.currentState?.validate(),
                            onFieldSubmitted: (value) async {
                              if (_listenBrainzFormKey.currentState!
                                  .validate()) {
                                di<SettingsModel>().setListenBrainzApiKey(
                                  value,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => di<ExposeManager>()
                          .initListenBrainsCommand
                          .run(_listenBrainzApiKeyController.text),
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
