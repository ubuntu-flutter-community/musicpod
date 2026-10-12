import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/app_config.dart';
import 'package:musicpod/app/latest_release_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'latest_release_manager_test.mocks.dart';

@GenerateMocks([GitHub, RepositoriesService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockGitHub mockGitHub;
  late MockRepositoriesService mockRepositoriesService;
  final packageInfo = PackageInfo(
    appName: 'Musicpod',
    packageName: 'com.example.musicpod',
    version: '1.0.0',
    buildNumber: '1',
  );

  setUp(() async {
    await GetIt.I.reset();
    mockGitHub = MockGitHub();
    mockRepositoriesService = MockRepositoriesService();

    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
    di.registerSingleton<GitHub>(mockGitHub);
    di.registerSingleton<PackageInfo>(packageInfo);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('LatestReleaseManager', () {
    test('computes update available and download counts correctly', () async {
      final release = Release(tagName: 'v2.0.0');
      final asset1 = ReleaseAsset(downloadCount: 50);
      final asset2 = ReleaseAsset(downloadCount: 150);

      when(
        mockRepositoriesService.listReleases(
          RepositorySlug.full(AppConfig.gitHubShortLink),
        ),
      ).thenAnswer((_) => Stream.fromIterable([release]));

      when(
        mockRepositoriesService.listReleaseAssets(
          RepositorySlug.full(AppConfig.gitHubShortLink),
          release,
        ),
      ).thenAnswer((_) => Stream.fromIterable([asset1, asset2]));

      final result = await container.read(latestReleaseManagerProvider.future);

      expect(result.onlineVersion, 'v2.0.0');
      expect(result.downloadCount, 200);
      expect(result.updateAvailable, AppConfig.allowManualUpdate);
    });

    test('returns default state when no release found', () async {
      when(
        mockRepositoriesService.listReleases(
          RepositorySlug.full(AppConfig.gitHubShortLink),
        ),
      ).thenAnswer((_) => const Stream.empty());

      final result = await container.read(latestReleaseManagerProvider.future);

      expect(result.onlineVersion, isNull);
      expect(result.downloadCount, 0);
      expect(result.updateAvailable, isFalse);
    });

    test(
      'updateAvailable is false when online version is older or same',
      () async {
        final release = Release(tagName: 'v1.0.0');

        when(
          mockRepositoriesService.listReleases(
            RepositorySlug.full(AppConfig.gitHubShortLink),
          ),
        ).thenAnswer((_) => Stream.fromIterable([release]));

        when(
          mockRepositoriesService.listReleaseAssets(
            RepositorySlug.full(AppConfig.gitHubShortLink),
            release,
          ),
        ).thenAnswer((_) => const Stream.empty());

        final result = await container.read(
          latestReleaseManagerProvider.future,
        );

        expect(result.onlineVersion, 'v1.0.0');
        expect(result.downloadCount, 0);
        expect(result.updateAvailable, isFalse);
      },
    );

    test('supports constructor injection for gitHub and packageInfo', () async {
      final customPackageInfo = PackageInfo(
        appName: 'Musicpod',
        packageName: 'com.example.musicpod',
        version: '3.0.0',
        buildNumber: '1',
      );
      final release = Release(tagName: 'v2.5.0');

      when(
        mockRepositoriesService.listReleases(
          RepositorySlug.full(AppConfig.gitHubShortLink),
        ),
      ).thenAnswer((_) => Stream.fromIterable([release]));

      when(
        mockRepositoriesService.listReleaseAssets(
          RepositorySlug.full(AppConfig.gitHubShortLink),
          release,
        ),
      ).thenAnswer((_) => const Stream.empty());

      final manager = LatestReleaseManager(
        gitHub: mockGitHub,
        packageInfo: customPackageInfo,
      );

      final overrideContainer = ProviderContainer(
        overrides: [latestReleaseManagerProvider.overrideWith(() => manager)],
      );

      final result = await overrideContainer.read(
        latestReleaseManagerProvider.future,
      );

      expect(result.onlineVersion, 'v2.5.0');
      expect(result.updateAvailable, isFalse);

      overrideContainer.dispose();
    });
  });
}
