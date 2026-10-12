import 'package:github/github.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../dependencies.dart';
import '../extensions/string_x.dart';
import '../third_party/github_module.dart';
import 'app_config.dart';

part 'latest_release_manager.g.dart';

class LatestReleaseState {
  const LatestReleaseState({
    this.onlineVersion,
    this.downloadCount = 0,
    this.updateAvailable = false,
  });

  final String? onlineVersion;
  final int downloadCount;
  final bool updateAvailable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatestReleaseState &&
          runtimeType == other.runtimeType &&
          onlineVersion == other.onlineVersion &&
          downloadCount == other.downloadCount &&
          updateAvailable == other.updateAvailable;

  @override
  int get hashCode =>
      onlineVersion.hashCode ^ downloadCount.hashCode ^ updateAvailable.hashCode;
}

@Riverpod(keepAlive: true)
class LatestReleaseManager extends _$LatestReleaseManager {
  LatestReleaseManager({
    GitHub? gitHub,
    PackageInfo? packageInfo,
  })  : _gitHubOverride = gitHub,
        _packageInfoOverride = packageInfo;

  final GitHub? _gitHubOverride;
  final PackageInfo? _packageInfoOverride;

  GitHub get _gitHub => _gitHubOverride ?? di<GitHub>();
  PackageInfo get _packageInfo => _packageInfoOverride ?? di<PackageInfo>();

  @override
  Future<LatestReleaseState> build() async {
    final release = await _gitHub.latestRelease;
    if (release == null) {
      return const LatestReleaseState();
    }

    final onlineVersion = release.tagName;
    final currentVersion = _packageInfo.version;
    final onlineVersionInt = onlineVersion?.extendedVersion ?? 0;
    final currentVersionInt = currentVersion.extendedVersion ?? 0;
    final updateAvailable =
        (onlineVersionInt > currentVersionInt) && AppConfig.allowManualUpdate;

    final assets = await _gitHub.repositories
        .listReleaseAssets(
          RepositorySlug.full(AppConfig.gitHubShortLink),
          release,
        )
        .toList();

    final downloadCount = assets.fold<int>(
      0,
      (previousValue, element) =>
          previousValue + (element.downloadCount ?? 0),
    );

    return LatestReleaseState(
      onlineVersion: onlineVersion,
      downloadCount: downloadCount,
      updateAvailable: updateAvailable,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
