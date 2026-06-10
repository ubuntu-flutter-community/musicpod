import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/modals.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/country_x.dart';
import '../../settings/settings_manager.dart';
import '../search_manager.dart';

class PodcastSearchInputPrefix extends StatelessWidget with WatchItMixin {
  const PodcastSearchInputPrefix({super.key});

  @override
  Widget build(BuildContext context) {
    final country = watchValue((SearchManager m) => m.country);
    const flagTextStyle = TextStyle(fontSize: 20, height: 1.2);
    final usePodcastIndex = watchPropertyValue(
      (SettingsManager m) => m.usePodcastIndex,
    );
    final l10n = context.l10n;
    final tooltip = usePodcastIndex ? l10n.language : l10n.country;

    return IconButton(
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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

class LocationFilter extends StatelessWidget with WatchItMixin {
  const LocationFilter({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    final searchManager = di<SearchManager>();
    watchPropertyValue((SettingsManager m) => m.favoriteLanguageCodeLength);
    watchPropertyValue((SettingsManager m) => m.favoriteCountryCodeLength);
    final country = watchValue((SearchManager m) => m.country);

    void setCountry(Country? country) {
      searchManager.setCountry(country);
      if (country?.code != null) {
        di<SettingsManager>().setLastCountryCode(country!.code);
      }
    }

    final usePodcastIndex = watchPropertyValue(
      (SettingsManager m) => m.usePodcastIndex,
    );
    watchPropertyValue((SettingsManager m) => m.favoriteLanguageCodeLength);
    watchPropertyValue((SettingsManager m) => m.favoriteCountryCodeLength);
    final favLanguageCodes = watchPropertyValue(
      (SettingsManager m) => m.favoriteLanguageCode,
    );

    final language = watchValue((SearchManager m) => m.language);

    final theWidth = width ?? 250.0;
    final height = chipHeight;

    final useYaruTheme = watchPropertyValue(
      (SettingsManager m) => m.useYaruTheme,
    );
    final countryPillPadding = getCountryPillPadding(useYaruTheme);

    return usePodcastIndex
        ? LanguageAutoComplete(
            autofocus: true,
            contentPadding: getCountryPillPadding(useYaruTheme),
            filled: language != null,
            isDense: true,
            width: theWidth,
            height: height,
            value: language,
            favs: favLanguageCodes,
            addFav: (language) {
              if (language?.isoCode == null) return;
              di<SettingsManager>().addFavoriteLanguageCode(language!.isoCode);
            },
            removeFav: (language) {
              if (language?.isoCode == null) return;
              di<SettingsManager>().removeFavoriteLanguageCode(
                language!.isoCode,
              );
            },
            onSelected: (language) {
              context.pop();
              searchManager.setLanguage(language);
              if (language?.isoCode != null) {
                di<SettingsManager>().setLastLanguageCode(language!.isoCode);
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
                (e) =>
                    di<SettingsManager>().favoriteCountryCode.contains(
                      e.code,
                    ) ==
                    true,
              ),
              ...[...Country.values].where(
                (e) =>
                    di<SettingsManager>().favoriteCountryCode.contains(
                      e.code,
                    ) ==
                    false,
              ),
            ]..remove(Country.none),
            onSelected: (country) {
              context.pop();
              setCountry(country);
              searchManager.search(clear: true);
            },
            value: country,
            addFav: (v) {
              if (country?.code == null) return;
              di<SettingsManager>().addFavoriteCountryCode(v!.code);
            },
            removeFav: (v) {
              if (country?.code == null) return;
              di<SettingsManager>().removeFavoriteCountryCode(v!.code);
            },
            favs: di<SettingsManager>().favoriteCountryCode,
          );
  }
}
