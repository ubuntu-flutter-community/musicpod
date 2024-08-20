# Changelog

## [1.7.0](https://github.com/ubuntu-flutter-community/musicpod/compare/1.6.0...v1.7.0) (2024-08-20)


### Features

* improved patch notes dialog and single podcast refreshing ([#864](https://github.com/ubuntu-flutter-community/musicpod/issues/864)) ([02d92e9](https://github.com/ubuntu-flutter-community/musicpod/commit/02d92e943af1b69e4c772316e64320c11a748f11))
* update Italian language ([#859](https://github.com/ubuntu-flutter-community/musicpod/issues/859)) ([9019bb2](https://github.com/ubuntu-flutter-community/musicpod/commit/9019bb2cb5d519e57ce7588d9bdd54b0b831872f))


### Bug Fixes

* appimagebuilder path ([c1ec44b](https://github.com/ubuntu-flutter-community/musicpod/commit/c1ec44bfb707b750bfe0859337ca4892bb41596e))
* bottom player image for stations without image but with icyInfo ([#876](https://github.com/ubuntu-flutter-community/musicpod/issues/876)) ([ae27451](https://github.com/ubuntu-flutter-community/musicpod/commit/ae2745168760f9bc69bc902f199157fd82efd072))
* init radio model before tapping on a tag ([#862](https://github.com/ubuntu-flutter-community/musicpod/issues/862)) ([3754781](https://github.com/ubuntu-flutter-community/musicpod/commit/3754781b86cefb1720f5fc62b6ec4d02ed1c06b6))
* run build release before appimage ([62fd095](https://github.com/ubuntu-flutter-community/musicpod/commit/62fd095aa82c53d5cd7ae5e8f8bfa4b9096d37e1))
* some title of radio is html format, need to convert to human readable format ([#870](https://github.com/ubuntu-flutter-community/musicpod/issues/870)) ([4c398e1](https://github.com/ubuntu-flutter-community/musicpod/commit/4c398e1d7904d2e837cb2fc1c6160539f2bce236)), closes [#866](https://github.com/ubuntu-flutter-community/musicpod/issues/866)

## [1.7.0](https://github.com/ubuntu-flutter-community/musicpod/compare/1.6.0...v1.7.0) (2024-08-19)


### Features

* improved patch notes dialog and single podcast refreshing ([#864](https://github.com/ubuntu-flutter-community/musicpod/issues/864)) ([02d92e9](https://github.com/ubuntu-flutter-community/musicpod/commit/02d92e943af1b69e4c772316e64320c11a748f11))
* update Italian language ([#859](https://github.com/ubuntu-flutter-community/musicpod/issues/859)) ([9019bb2](https://github.com/ubuntu-flutter-community/musicpod/commit/9019bb2cb5d519e57ce7588d9bdd54b0b831872f))


### Bug Fixes

* init radio model before tapping on a tag ([#862](https://github.com/ubuntu-flutter-community/musicpod/issues/862)) ([3754781](https://github.com/ubuntu-flutter-community/musicpod/commit/3754781b86cefb1720f5fc62b6ec4d02ed1c06b6))
* some title of radio is html format, need to convert to human readable format ([#870](https://github.com/ubuntu-flutter-community/musicpod/issues/870)) ([4c398e1](https://github.com/ubuntu-flutter-community/musicpod/commit/4c398e1d7904d2e837cb2fc1c6160539f2bce236)), closes [#866](https://github.com/ubuntu-flutter-community/musicpod/issues/866)

## 1.6.0 (2024-08-16)

## What's Changed
* fix: use audio lists instead of sets for performance by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/825
* fix: remove audio list duplications by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/826
* Add animation effects to the dialog. by @dongfengweixiao in https://github.com/ubuntu-flutter-community/musicpod/pull/827
* fix: unify search page by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/828
* Fix: Default icons on the local audio list page are not displayed completely by @dongfengweixiao in https://github.com/ubuntu-flutter-community/musicpod/pull/829
* fix: fallback for badly tagged local audios icons by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/830
* fix: mitigate hobby archivists huge libs by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/831
* fix: revert animated dialog, limit image search and fix initial genre page by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/832
* fix: center empty albums view by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/833
* fix: spinning slivers by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/834
* chore: update to flutter 3.24 by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/835
* fix: init fixes and podcast genre search from page by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/837
* chore: migrate home grown settings to shared_preferences by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/838
* fix: add more chinese language specification files by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/840
* update i10n for zh by @dongfengweixiao in https://github.com/ubuntu-flutter-community/musicpod/pull/841
* fix: input styling for yaru by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/842
* feat: add reorder and replay buttons for podcasts by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/843
* Clean up the flatpak stuff by @TheShadowOfHassen in https://github.com/ubuntu-flutter-community/musicpod/pull/844
* fix: ascending podcasts by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/845
* feat: add timer and update button to podcasts by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/846
* chore: correct flutter tag for snap, test snap in CI, release 1.5.3 by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/847
* update i10n for zh by @dongfengweixiao in https://github.com/ubuntu-flutter-community/musicpod/pull/849
* fix: master tile image rebuilds by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/850
* fix: full height player image rebuild by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/851
* fix: more blur by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/852
* chore: add release action by @Feichtmeier in https://github.com/ubuntu-flutter-community/musicpod/pull/854


**Full Changelog**: https://github.com/ubuntu-flutter-community/musicpod/compare/1.5.2...v1.6.0
