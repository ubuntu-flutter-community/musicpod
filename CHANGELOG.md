# Changelog

## [2.0.1](https://github.com/ubuntu-flutter-community/musicpod/compare/v2.0.0...v2.0.1) (2024-10-20)


### Bug Fixes

* replace remaining station url ids with uuid, fix discord error spam ([#965](https://github.com/ubuntu-flutter-community/musicpod/issues/965)) ([04a0b5c](https://github.com/ubuntu-flutter-community/musicpod/commit/04a0b5cfdc1514910045aaa6312fb7fe6e463259))

## [2.0.0](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.12.0...v2.0.0) (2024-10-20)


### ⚠ BREAKING CHANGES

* rework stations to be identified by uuid, display search in a list ([#930](https://github.com/ubuntu-flutter-community/musicpod/issues/930))

### Features

* add discord rich presence ([#945](https://github.com/ubuntu-flutter-community/musicpod/issues/945)) ([de23cf3](https://github.com/ubuntu-flutter-community/musicpod/commit/de23cf34f4f5443985b9b303c327ae6d4b2e29ad))
* add discord toggle in settings, disable for linux ([#947](https://github.com/ubuntu-flutter-community/musicpod/issues/947)) ([6aa080e](https://github.com/ubuntu-flutter-community/musicpod/commit/6aa080e54d86c33f8bf21c487f960448e8ea3a90)), closes [#946](https://github.com/ubuntu-flutter-community/musicpod/issues/946)
* display online art errors in the player images, improved radio search ([#943](https://github.com/ubuntu-flutter-community/musicpod/issues/943)) ([42d61ee](https://github.com/ubuntu-flutter-community/musicpod/commit/42d61ee951eb4d1500a9a02946750fa66155397a))
* improve discord on/off toggling ([#960](https://github.com/ubuntu-flutter-community/musicpod/issues/960)) ([4fd2980](https://github.com/ubuntu-flutter-community/musicpod/commit/4fd2980e9c721e94fce950985e0add723e6d8e28))
* let users select the downloads directory ([#953](https://github.com/ubuntu-flutter-community/musicpod/issues/953)) ([9d8063f](https://github.com/ubuntu-flutter-community/musicpod/commit/9d8063f055b6030a0fd5f42ac6961e85bf01c97b)), closes [#928](https://github.com/ubuntu-flutter-community/musicpod/issues/928)
* **radio:** add return to livestream & play similar station buttons ([#938](https://github.com/ubuntu-flutter-community/musicpod/issues/938)) ([1d2ba5e](https://github.com/ubuntu-flutter-community/musicpod/commit/1d2ba5ee4ac467c222977fce4fa5c6df3baa53dc)), closes [#937](https://github.com/ubuntu-flutter-community/musicpod/issues/937)
* rework stations to be identified by uuid, display search in a list ([#930](https://github.com/ubuntu-flutter-community/musicpod/issues/930)) ([8c3bb05](https://github.com/ubuntu-flutter-community/musicpod/commit/8c3bb05c8baf6a790adc9b9efa7fd126cf00d168))
* update app_es.arb ([#940](https://github.com/ubuntu-flutter-community/musicpod/issues/940)) ([91b35ed](https://github.com/ubuntu-flutter-community/musicpod/commit/91b35ed9d43f905a8cb0d3a0cfd07dbcb2997a10))
* update episodes when a podcast page is loaded ([#959](https://github.com/ubuntu-flutter-community/musicpod/issues/959)) ([f925201](https://github.com/ubuntu-flutter-community/musicpod/commit/f925201d6179af04952ec79032efbc93b25b062b))
* update Italian language ([#950](https://github.com/ubuntu-flutter-community/musicpod/issues/950)) ([807f49a](https://github.com/ubuntu-flutter-community/musicpod/commit/807f49a3398a250abb181010847dca1592ef5eb5))
* update Italian language ([#956](https://github.com/ubuntu-flutter-community/musicpod/issues/956)) ([66c1cd8](https://github.com/ubuntu-flutter-community/musicpod/commit/66c1cd864e09cd7c5998906f9c803cb44dda4a0b))
* update slovak translations ([#951](https://github.com/ubuntu-flutter-community/musicpod/issues/951)) ([e605df1](https://github.com/ubuntu-flutter-community/musicpod/commit/e605df11302a36f7dc5801be5b52389f983f232c))


### Bug Fixes

* do not retry connect to discord, update deps ([#962](https://github.com/ubuntu-flutter-community/musicpod/issues/962)) ([2387977](https://github.com/ubuntu-flutter-community/musicpod/commit/23879776719f3dcba3f0f7b5b537ee739ec9b4ed))
* fallback to wifi if connectivity errors, for example if there is no network manager on linux ([#952](https://github.com/ubuntu-flutter-community/musicpod/issues/952)) ([498f32e](https://github.com/ubuntu-flutter-community/musicpod/commit/498f32e5d3c52cfc460a3b23d0541bf63c705f70)), closes [#949](https://github.com/ubuntu-flutter-community/musicpod/issues/949)
* linux failed import snackbar ([#954](https://github.com/ubuntu-flutter-community/musicpod/issues/954)) ([1ce62b1](https://github.com/ubuntu-flutter-community/musicpod/commit/1ce62b124bd35368e8200cefff0ce06e0f0898b0)), closes [#934](https://github.com/ubuntu-flutter-community/musicpod/issues/934)
* onError callback ([#936](https://github.com/ubuntu-flutter-community/musicpod/issues/936)) ([3790021](https://github.com/ubuntu-flutter-community/musicpod/commit/379002123263186147b778eb4a0bbc550fdac8c0)), closes [#934](https://github.com/ubuntu-flutter-community/musicpod/issues/934)
* The presence of a lost+found folder makes musicpod unable to load the users music library ([#935](https://github.com/ubuntu-flutter-community/musicpod/issues/935)) ([66bca61](https://github.com/ubuntu-flutter-community/musicpod/commit/66bca61ea7081602f562e49342a0a8804191fa72)), closes [#934](https://github.com/ubuntu-flutter-community/musicpod/issues/934)
* turn of discord off switch for linux ([be1b198](https://github.com/ubuntu-flutter-community/musicpod/commit/be1b19849ed1a15038d62aa84ab6b0c3a3043197))
* update frb_plugins dependency ([#955](https://github.com/ubuntu-flutter-community/musicpod/issues/955)) ([eb291af](https://github.com/ubuntu-flutter-community/musicpod/commit/eb291af837a8e37ff102535e8c20710fec5f1789)), closes [#946](https://github.com/ubuntu-flutter-community/musicpod/issues/946)
* use MediaQuery.sizeOf instead .of ([#944](https://github.com/ubuntu-flutter-community/musicpod/issues/944)) ([f1a11c5](https://github.com/ubuntu-flutter-community/musicpod/commit/f1a11c5b22d4c40d3996041b866729d5d6046469))

## [1.12.0](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.11.0...v1.12.0) (2024-09-20)


### Features

* add extra speeds ([#922](https://github.com/ubuntu-flutter-community/musicpod/issues/922)) ([11b3ddb](https://github.com/ubuntu-flutter-community/musicpod/commit/11b3ddb9dd6ea42d9e9900e66c9577389a6cc943))
* load more podcasts on scroll, update deps ([#920](https://github.com/ubuntu-flutter-community/musicpod/issues/920)) ([741d090](https://github.com/ubuntu-flutter-community/musicpod/commit/741d0905c87c9a262c2362388e38893369574c20))
* show more stations on scroll ([#927](https://github.com/ubuntu-flutter-community/musicpod/issues/927)) ([23044c3](https://github.com/ubuntu-flutter-community/musicpod/commit/23044c313f85e9d574a92f43a5dfee589e10486a)), closes [#926](https://github.com/ubuntu-flutter-community/musicpod/issues/926)


### Bug Fixes

* update yaru to follow 22.10+ accents ([#925](https://github.com/ubuntu-flutter-community/musicpod/issues/925)) ([75a7b70](https://github.com/ubuntu-flutter-community/musicpod/commit/75a7b70d21dfdf6aa3c7d326c5d49dc2582dcb6e))

## [1.11.0](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.10.1...v1.11.0) (2024-09-08)


### Features

* new icon ([#910](https://github.com/ubuntu-flutter-community/musicpod/issues/910)) ([a2f69ba](https://github.com/ubuntu-flutter-community/musicpod/commit/a2f69ba61652e6244f8aa6997aa7c6c219e0e053))


### Bug Fixes

* add new icon for windows and macos ([#914](https://github.com/ubuntu-flutter-community/musicpod/issues/914)) ([94a5c81](https://github.com/ubuntu-flutter-community/musicpod/commit/94a5c818d6d5737b2d0c68054027d084f0776472))
* new icon for flatpackers ([#912](https://github.com/ubuntu-flutter-community/musicpod/issues/912)) ([06cf7d3](https://github.com/ubuntu-flutter-community/musicpod/commit/06cf7d3452345a0ad9148a1f747912885ecdb7ae))
* playlist reordering and update credits with @TheShadowOfHassen and [@ubuntujaggers](https://github.com/ubuntujaggers) ([#913](https://github.com/ubuntu-flutter-community/musicpod/issues/913)) ([50399d3](https://github.com/ubuntu-flutter-community/musicpod/commit/50399d360dd9b021529ab66427e6443ed15412a7))

## [1.10.1](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.10.0...v1.10.1) (2024-08-31)


### Bug Fixes

* desktop dark theme ([#907](https://github.com/ubuntu-flutter-community/musicpod/issues/907)) ([975828f](https://github.com/ubuntu-flutter-community/musicpod/commit/975828f7d4336eed65178ff130b907b258a82343))

## [1.10.0](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.9.1...v1.10.0) (2024-08-31)


### Features

* improve android styling and sizes ([#902](https://github.com/ubuntu-flutter-community/musicpod/issues/902)) ([87d0147](https://github.com/ubuntu-flutter-community/musicpod/commit/87d0147ad213a33899ac774655e3e6ac926a2b1c))


### Bug Fixes

* align control panel sizes and padding, correctly load remoteimageurl ([#905](https://github.com/ubuntu-flutter-community/musicpod/issues/905)) ([549f352](https://github.com/ubuntu-flutter-community/musicpod/commit/549f35235f970e225e5bea2828a88f8d998a479d))
* android downloads and local collection path + design adjustments ([#904](https://github.com/ubuntu-flutter-community/musicpod/issues/904)) ([3ac49fb](https://github.com/ubuntu-flutter-community/musicpod/commit/3ac49fb0c90296e4d998e8c8d12fb4390bfc1f85))
* **Android:** round icons, darker dark theme, improved podcast tiles ([#906](https://github.com/ubuntu-flutter-community/musicpod/issues/906)) ([282685a](https://github.com/ubuntu-flutter-community/musicpod/commit/282685a8f37bd8f0e6b912b6a8527f8cc0b1f781))
* icy image double loading ([#903](https://github.com/ubuntu-flutter-community/musicpod/issues/903)) ([df7b394](https://github.com/ubuntu-flutter-community/musicpod/commit/df7b3948d0a033d79d5c98d026da81bb7ce12d2e))
* yaru.dart colors regression ([#900](https://github.com/ubuntu-flutter-community/musicpod/issues/900)) ([1b4efb3](https://github.com/ubuntu-flutter-community/musicpod/commit/1b4efb306fb05883708e09a0ace9e9610859bf81))

## [1.9.1](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.9.0...v1.9.1) (2024-08-25)


### Bug Fixes

* Must search by name before searching by tag, country, or language ([#897](https://github.com/ubuntu-flutter-community/musicpod/issues/897)) ([7459008](https://github.com/ubuntu-flutter-community/musicpod/commit/7459008d466d9126466a5220bcec110b9b161ad0)), closes [#896](https://github.com/ubuntu-flutter-community/musicpod/issues/896)

## [1.9.0](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.8.1...v1.9.0) (2024-08-25)


### Features

* **app:** add system tray functionality ([#824](https://github.com/ubuntu-flutter-community/musicpod/issues/824)) ([857bdef](https://github.com/ubuntu-flutter-community/musicpod/commit/857bdefa7ef103d87d39110dbae8989866399b90))
* display localized names for regions. ([#885](https://github.com/ubuntu-flutter-community/musicpod/issues/885)) ([9cba0ac](https://github.com/ubuntu-flutter-community/musicpod/commit/9cba0ac72837f68d253b1fe1d9749e2da7332884))
* show queue or radiohistory when the player is big enough ([#888](https://github.com/ubuntu-flutter-community/musicpod/issues/888)) ([fd2d6da](https://github.com/ubuntu-flutter-community/musicpod/commit/fd2d6da57f35cd6112ab37859a67d8f3f3ef3d56))


### Bug Fixes

* add app indicator deps to snap build-packages ([#890](https://github.com/ubuntu-flutter-community/musicpod/issues/890)) ([cd6b7ba](https://github.com/ubuntu-flutter-community/musicpod/commit/cd6b7bac1227d5bf4a586b5f596f6332b3a1dba1))
* icy image key and podfile lock ([#895](https://github.com/ubuntu-flutter-community/musicpod/issues/895)) ([3323883](https://github.com/ubuntu-flutter-community/musicpod/commit/3323883f4aedfffae50036cc6f158fe1556c4f2f))
* improved audio tile, correct unstarred icon, update yaru ([#887](https://github.com/ubuntu-flutter-community/musicpod/issues/887)) ([8a6ecaf](https://github.com/ubuntu-flutter-community/musicpod/commit/8a6ecaff8c4a99f8e73b6842c10fa2f37d5b7283))
* linux tray icon ([#886](https://github.com/ubuntu-flutter-community/musicpod/issues/886)) ([2eb0090](https://github.com/ubuntu-flutter-community/musicpod/commit/2eb0090aa26984b320c99797d97bc73d0e2d60f0)), closes [#793](https://github.com/ubuntu-flutter-community/musicpod/issues/793)
* reduce radio history repaint and minimize streams ([#892](https://github.com/ubuntu-flutter-community/musicpod/issues/892)) ([b70b275](https://github.com/ubuntu-flutter-community/musicpod/commit/b70b275e4494b8ccaa5e834972da54df2b6e58b0))
* remove broken tray ([#893](https://github.com/ubuntu-flutter-community/musicpod/issues/893)) ([b06aa1f](https://github.com/ubuntu-flutter-community/musicpod/commit/b06aa1f706732d138fc8c22b0f06393be5f81943))
* show radio searching page when searchQuery is null ([#891](https://github.com/ubuntu-flutter-community/musicpod/issues/891)) ([f1292a1](https://github.com/ubuntu-flutter-community/musicpod/commit/f1292a1d9b464da97396229b361171abe48c552d))

## [1.8.1](https://github.com/ubuntu-flutter-community/musicpod/compare/v1.8.0...v1.8.1) (2024-08-20)


### Bug Fixes

* constrain podcast html descriptions ([#879](https://github.com/ubuntu-flutter-community/musicpod/issues/879)) ([17b3533](https://github.com/ubuntu-flutter-community/musicpod/commit/17b3533261a4154b6c04b26694ac003e9ff67303))

## [1.8.0](https://github.com/ubuntu-flutter-community/musicpod/compare/1.6.0...v1.8.0) (2024-08-20)


### Features

* improved patch notes dialog and single podcast refreshing ([#864](https://github.com/ubuntu-flutter-community/musicpod/issues/864)) ([02d92e9](https://github.com/ubuntu-flutter-community/musicpod/commit/02d92e943af1b69e4c772316e64320c11a748f11))
* update Italian language ([#859](https://github.com/ubuntu-flutter-community/musicpod/issues/859)) ([9019bb2](https://github.com/ubuntu-flutter-community/musicpod/commit/9019bb2cb5d519e57ce7588d9bdd54b0b831872f))


### Bug Fixes

* appimagebuilder path ([c1ec44b](https://github.com/ubuntu-flutter-community/musicpod/commit/c1ec44bfb707b750bfe0859337ca4892bb41596e))
* bottom player image for stations without image but with icyInfo ([#876](https://github.com/ubuntu-flutter-community/musicpod/issues/876)) ([ae27451](https://github.com/ubuntu-flutter-community/musicpod/commit/ae2745168760f9bc69bc902f199157fd82efd072))
* init radio model before tapping on a tag ([#862](https://github.com/ubuntu-flutter-community/musicpod/issues/862)) ([3754781](https://github.com/ubuntu-flutter-community/musicpod/commit/3754781b86cefb1720f5fc62b6ec4d02ed1c06b6))
* run build release before appimage ([62fd095](https://github.com/ubuntu-flutter-community/musicpod/commit/62fd095aa82c53d5cd7ae5e8f8bfa4b9096d37e1))
* some title of radio is html format, need to convert to human readable format ([#870](https://github.com/ubuntu-flutter-community/musicpod/issues/870)) ([4c398e1](https://github.com/ubuntu-flutter-community/musicpod/commit/4c398e1d7904d2e837cb2fc1c6160539f2bce236)), closes [#866](https://github.com/ubuntu-flutter-community/musicpod/issues/866)


### Miscellaneous Chores

* release 1.8.0 ([c0b9d5e](https://github.com/ubuntu-flutter-community/musicpod/commit/c0b9d5e5d8ae5a4c5c8f75017b19b91354d08882))

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
