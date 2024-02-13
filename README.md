# Musicpod

Music, Radio, Television and Podcast player for Linux Desktop, MacOS, Windows and Android made with Flutter.

Install for Linux Desktop:

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/musicpod)

Install For MacOS & Windows:

[Release Page](https://github.com/ubuntu-flutter-community/musicpod/releases)

Android release is WIP!


|Dark | Light|
|-|-|
|![](.github/local_dark.png)|![](.github/local_light.png)|
|![](.github/radio_dark.png)|![](.github/radio_light.png)|
|![](.github/podcast_dark.png)|![](.github/podcast_light.png)|
|![](.github/album_dark.png)|![](.github/album_light.png)|
|![](.github/full_window_dark.png)|![](.github/full_window_light.png)|
|![](.github/wide_window_dark.png)|![](.github/wide_window_light.png)|

## Credits

Thank you @amugofjava for creating the very easy to use and reliable [podcast_search](https://github.com/amugofjava/podcast_search)!

Thanks @alexmercerind for the super performant [Mediakit library](https://github.com/alexmercerind/media_kit) and [mpris_service](https://github.com/alexmercerind/mpris_service) dart implementation!

Thank you @KRTirtho for the very easy to use [Metadata God](https://github.com/KRTirtho/metadata_god) package

Thank you @tomassasovsky for the [dart implementation of radiobrowser-api](https://github.com/tomassasovsky/radio-browser-api.dart)

## MusicPod Level 1

- [X] play local audio files
- [X] filter local files
- [X] set root directory
- [X] create and manage playlists
- [X] play internet radio streams
- [X] browse for radio stations
- [X] play podcasts
- [X] search for podcasts
- [X] load podcast charts
- [X] filter podcasts by country
- [X] filter podcasts by genre
- [X] save playlists
- [X] save liked songs
- [X] save settings on disk
- [X] notify when a new episode of your subscribed podcasts is available

## MusicPod Level 2

- [X] Video Podcasts ([#71](https://github.com/ubuntu-flutter-community/musicpod/issues/71))
- [X] Play TV Stations found on radiobrowser
- [ ] Chromecast Support ([#91](https://github.com/ubuntu-flutter-community/musicpod/issues/91))
- [X] streaming provider agnostic sharing links
- [X] option to download podcasts (#[240](https://github.com/ubuntu-flutter-community/musicpod/issues/240))
- [X] reduced memory allocation
- [ ] WebDav support (#[248](https://github.com/ubuntu-flutter-community/musicpod/issues/248))
- [ ] upnp/dlna support (#[248](https://github.com/ubuntu-flutter-community/musicpod/issues/247))

## Supported operating systems and package formats

- [X] Ubuntu Desktop
  - [X] [snap package](https://snapcraft.io/musicpod) (this is the primary supported package!)
  - [ ] Flatpak ([WIP](https://github.com/ubuntu-flutter-community/musicpod/issues/10))
- [X] Windows Support
  - [ ] Windows Store
  - [ ] [Exe](https://github.com/ubuntu-flutter-community/musicpod/releases)
- [X] Android Support (Media Controls are WIP)
  - [ ] PlayStore
- [X] MacOs Support
  - [ ] Apple?Store?
  - [ ] [DMG](https://github.com/ubuntu-flutter-community/musicpod/releases)
- [ ] iOS Support
  - [ ] AppStore
