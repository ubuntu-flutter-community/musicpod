import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/modals.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/country_x.dart';
import '../../extensions/platform_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../manager/search_manager.dart';

class PodcastSearchInputPrefix extends ConsumerWidget {
  const PodcastSearchInputPrefix({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(
      searchManagerProvider.select((s) => s.country),
    );
    const flagTextStyle = TextStyle(fontSize: 20, height: 1.2);
    final l10n = context.l10n;

    final usePodcastIndex =
        ref.watch(
          settingsBoolManagerProvider(SPKeys.usePodcastIndex),
        ) ??
        false;
    final tooltip = usePodcastIndex ? l10n.language : l10n.country;

    return IconButton(
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      tooltip: tooltip,
      onPressed: () => showModal(
        mode: ModalMode.platformModalMode,
        context: context,
        content: LocationFilterDialog(mode: ModalMode.platformModalMode),
      ),
      icon: Text(' ${country?.flag ?? '🚩'}', style: flagTextStyle),
    );
  }
}

class LocationFilterDialog extends StatelessWidget {
  const LocationFilterDialog({super.key, required ModalMode mode})
    : _mode = mode;

  const LocationFilterDialog.dialog({super.key}) : _mode = ModalMode.dialog;

  const LocationFilterDialog.bottomSheet({super.key})
    : _mode = ModalMode.bottomSheet;

  final ModalMode _mode;

  @override
  Widget build(BuildContext context) => switch (_mode) {
    ModalMode.dialog => AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      content: const LocationFilter(),
    ),
    ModalMode.bottomSheet => BottomSheet(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 60,
            top: kLargestSpace,
            left: kLargestSpace,
            right: kLargestSpace,
          ),
          child: Column(
            children: [
              LocationFilter(width: context.mediaQuerySize.width - 40),
            ],
          ),
        ),
      ),
      enableDrag: false,
      onClosing: () {},
    ),
  };
}

class LocationFilter extends ConsumerWidget {
  const LocationFilter({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchManager = ref.read(searchManagerProvider.notifier);
    final country = ref.watch(
      searchManagerProvider.select((s) => s.country),
    );
    final language = ref.watch(
      searchManagerProvider.select((s) => s.language),
    );
    final theWidth = width ?? 250.0;
    final height = chipHeight;

    final usePodcastIndex =
        ref.watch(
          settingsBoolManagerProvider(SPKeys.usePodcastIndex),
        ) ??
        false;
    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ??
        isLinux;
    final countryPillPadding = getCountryPillPadding(useYaruTheme);

    final favLanguageCodes =
        ref.watch(
          settingsStringListManagerProvider(SPKeys.favLanguageCodes),
        ) ??
        <String>[];

    final favCountryCodes =
        ref.watch(
          settingsStringListManagerProvider(SPKeys.favCountryCodes),
        ) ??
        <String>[];

    void setCountry(Country? country) {
      searchManager.setCountry(country);
      if (country?.code != null) {
        ref
            .read(
              settingsStringManagerProvider(
                SPKeys.lastCountryCode,
              ).notifier,
            )
            .set(country!.code);
      }
    }

    return usePodcastIndex
        ? LanguageAutoComplete(
            autofocus: true,
            contentPadding: countryPillPadding,
            filled: language != null,
            isDense: true,
            width: theWidth,
            height: height,
            value: language,
            favs: favLanguageCodes.toSet(),
            addFav: (language) {
              if (language?.isoCode == null) return;
              ref
                  .read(
                    settingsStringListManagerProvider(
                      SPKeys.favLanguageCodes,
                    ).notifier,
                  )
                  .addToStringList(language!.isoCode);
            },
            removeFav: (language) {
              if (language?.isoCode == null) return;
              ref
                  .read(
                    settingsStringListManagerProvider(
                      SPKeys.favLanguageCodes,
                    ).notifier,
                  )
                  .removeFromStringList(language!.isoCode);
            },
            onSelected: (language) {
              context.pop();
              searchManager.setLanguage(language);
              if (language?.isoCode != null) {
                ref
                    .read(
                      settingsStringManagerProvider(
                        SPKeys.lastLanguageCode,
                      ).notifier,
                    )
                    .set(language!.isoCode);
              }
              searchManager.search();
            },
          )
        : CountryAutoComplete(
            autofocus: true,
            contentPadding: countryPillPadding,
            filled: true,
            isDense: true,
            width: theWidth,
            height: height,
            countries: [
              ...[...Country.values].where(
                (e) => favCountryCodes.contains(e.code) == true,
              ),
              ...[...Country.values].where(
                (e) => favCountryCodes.contains(e.code) == false,
              ),
            ]..remove(Country.none),
            onSelected: (country) {
              context.pop();
              setCountry(country);
              searchManager.search(clear: true);
            },
            value: country,
            addFav: (v) {
              if (v?.code == null) return;
              ref
                  .read(
                    settingsStringListManagerProvider(
                      SPKeys.favCountryCodes,
                    ).notifier,
                  )
                  .addToStringList(v!.code);
            },
            removeFav: (v) {
              if (v?.code == null) return;
              ref
                  .read(
                    settingsStringListManagerProvider(
                      SPKeys.favCountryCodes,
                    ).notifier,
                  )
                  .removeFromStringList(v!.code);
            },
            favs: favCountryCodes.toSet(),
          );
  }
}
