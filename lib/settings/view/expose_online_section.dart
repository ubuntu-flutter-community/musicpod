import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/theme.dart';
import '../../expose/data/last_fm_credentials.dart';
import '../../expose/manager/expose_manager.dart';
import '../../extensions/build_context_x.dart';
import '../data/shared_preferences_keys.dart';
import '../manager/settings_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class ExposeOnlineSection extends ConsumerStatefulWidget {
  const ExposeOnlineSection({super.key});

  @override
  ConsumerState<ExposeOnlineSection> createState() =>
      _ExposeOnlineSectionState();
}

class _ExposeOnlineSectionState extends ConsumerState<ExposeOnlineSection> {
  late TextEditingController _lastFmApiKeyController;
  late TextEditingController _lastFmSecretController;
  late TextEditingController _listenBrainzApiKeyController;
  final _lastFmFormKey = GlobalKey<FormState>();
  final _listenBrainzFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final lastFmApiKey = ref.read(
      settingsStringManagerProvider(SPKeys.lastFmApiKey),
    );
    final lastFmSecret = ref.read(
      settingsStringManagerProvider(SPKeys.lastFmSecret),
    );
    final listenBrainzApiKey = ref.read(
      settingsStringManagerProvider(SPKeys.listenBrainzApiKey),
    );

    _lastFmApiKeyController = TextEditingController(text: lastFmApiKey);
    _lastFmSecretController = TextEditingController(text: lastFmSecret);
    _listenBrainzApiKeyController = TextEditingController(
      text: listenBrainzApiKey,
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

    final lastFmEnabled =
        ref.watch(settingsBoolManagerProvider(SPKeys.enableLastFm)) ?? false;

    final listenBrainzEnabled =
        ref.watch(settingsBoolManagerProvider(SPKeys.enableListenBrainz)) ??
        false;

    final isLastFmAuthorized = ref.watch(exposeManagerProvider);

    return SettingsSection(
      heading: l10n.exposeOnlineHeadline,
      children: [
        SettingsListTile(
          position: ListTilePosition.first,
          title: Row(
            children: space(
              children: [
                const Icon(TablerIcons.brand_lastfm),
                if (lastFmEnabled && isLastFmAuthorized) Text(l10n.connectedTo),
                Text(l10n.exposeToLastfmTitle),
              ],
            ),
          ),
          subtitle: Column(children: [Text(l10n.exposeToLastfmSubTitle)]),
          trailing: CommonSwitch(
            value: lastFmEnabled,
            onChanged: (v) {
              ref
                  .read(
                    settingsBoolManagerProvider(SPKeys.enableLastFm).notifier,
                  )
                  .set(v);
            },
          ),
        ),
        if (lastFmEnabled) ...[
          SettingsListTile(
            position: ListTilePosition.middle,
            title: Form(
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
                      onChanged: (_) => _lastFmFormKey.currentState?.validate(),
                      onFieldSubmitted: (value) async {
                        if (_lastFmFormKey.currentState!.validate()) {
                          await ref
                              .read(
                                settingsStringManagerProvider(
                                  SPKeys.lastFmApiKey,
                                ).notifier,
                              )
                              .set(value);
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
                      onChanged: (_) => _lastFmFormKey.currentState?.validate(),
                      onFieldSubmitted: (value) async {
                        if (_lastFmFormKey.currentState!.validate()) {
                          await ref
                              .read(
                                settingsStringManagerProvider(
                                  SPKeys.lastFmSecret,
                                ).notifier,
                              )
                              .set(value);
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(exposeManagerProvider.notifier)
                          .authorizeLastFm(
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
        SettingsListTile(
          position: listenBrainzEnabled
              ? ListTilePosition.middle
              : ListTilePosition.last,
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
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(
                    SPKeys.enableListenBrainz,
                  ).notifier,
                )
                .set(v),
          ),
        ),
        if (listenBrainzEnabled) ...[
          SettingsListTile(
            position: ListTilePosition.last,
            title: Column(
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
                            if (_listenBrainzFormKey.currentState!.validate()) {
                              await ref
                                  .read(
                                    settingsStringManagerProvider(
                                      SPKeys.listenBrainzApiKey,
                                    ).notifier,
                                  )
                                  .set(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(exposeManagerProvider.notifier)
                        .initListenBrains(_listenBrainzApiKeyController.text),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
