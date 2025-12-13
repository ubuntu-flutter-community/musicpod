%define appname musicpod
%define appid org.feichtmeier.musicpod

Name:           musicpod
Version:        2.9.0
Release:        1%{?dist}
Summary:        Music, podcast and internet radio player
License:        GPL-3.0+
URL:            https://github.com/ubuntu-flutter-community/musicpod
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  cmake
BuildRequires:  ninja-build
BuildRequires:  pkgconfig
BuildRequires:  gtk3-devel
BuildRequires:  clang
BuildRequires:  curl
BuildRequires:  unzip
BuildRequires:  xz
BuildRequires:  rust
BuildRequires:  cargo
BuildRequires:  libmpv-devel
BuildRequires:  mpv

Requires:       gtk3
Requires:       libmpv
Requires:       mpv

%description
MusicPod is a local music, radio, television and podcast player for Linux Desktop.
It allows you to play local audio files, browse podcasts online, and listen to
internet radio stations with support for metadata and artwork lookup.

%prep
%setup -q

%build
# Build the Flutter Linux release
flutter build linux --release

%install
# Install application files
mkdir -p %{buildroot}/opt/musicpod
cp -r build/linux/x64/release/bundle/* %{buildroot}/opt/musicpod/

# Install binary symlink to /usr/bin
mkdir -p %{buildroot}/usr/bin
ln -s /opt/musicpod/musicpod %{buildroot}/usr/bin/musicpod

# Install desktop file
mkdir -p %{buildroot}/usr/share/applications
cp snap/gui/musicpod.desktop %{buildroot}/usr/share/applications/%{appid}.desktop
sed -i 's|Icon=${SNAP}/meta/gui/musicpod.png|Icon=musicpod|g' %{buildroot}/usr/share/applications/%{appid}.desktop

# Install icon
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
cp snap/gui/musicpod.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/musicpod.png
mkdir -p %{buildroot}/usr/share/pixmaps
cp snap/gui/musicpod.png %{buildroot}/usr/share/pixmaps/musicpod.png

# Make binary executable
chmod +x %{buildroot}/opt/musicpod/musicpod

%files
%defattr(-,root,root,-)
/opt/musicpod
/usr/bin/musicpod
/usr/share/applications/%{appid}.desktop
/usr/share/icons/hicolor/256x256/apps/musicpod.png
/usr/share/pixmaps/musicpod.png

