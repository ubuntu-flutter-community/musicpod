import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/app/app_config.dart';
import 'package:musicpod/settings/manager/contributors_manager.dart';

import 'contributors_manager_test.mocks.dart';

@GenerateMocks([GitHub, RepositoriesService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockGitHub mockGitHub;
  late MockRepositoriesService mockRepositoriesService;

  setUp(() async {
    await GetIt.I.reset();
    mockGitHub = MockGitHub();
    mockRepositoriesService = MockRepositoriesService();

    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
    di.registerSingleton<GitHub>(mockGitHub);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ContributorsManager', () {
    test('fetches user contributors and appends extra contributor', () async {
      final userContributor = Contributor(
        login: 'testuser',
        type: 'User',
        htmlUrl: 'https://github.com/testuser',
      );
      final botContributor = Contributor(
        login: 'bot',
        type: 'Bot',
        htmlUrl: 'https://github.com/bot',
      );

      when(
        mockRepositoriesService.listContributors(
          RepositorySlug.full(AppConfig.gitHubShortLink),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([userContributor, botContributor]),
      );

      final result = await container.read(contributorsManagerProvider.future);

      expect(result.length, 2);
      expect(result.first.login, 'testuser');
      expect(result.last.login, 'ubuntujaggers');
    });

    test('supports constructor injection for gitHub', () async {
      final userContributor = Contributor(login: 'custom_user', type: 'User');

      when(
        mockRepositoriesService.listContributors(
          RepositorySlug.full(AppConfig.gitHubShortLink),
        ),
      ).thenAnswer((_) => Stream.fromIterable([userContributor]));

      final manager = ContributorsManager(gitHub: mockGitHub);
      final overrideContainer = ProviderContainer(
        overrides: [contributorsManagerProvider.overrideWith(() => manager)],
      );

      final result = await overrideContainer.read(
        contributorsManagerProvider.future,
      );

      expect(result.length, 2);
      expect(result.first.login, 'custom_user');
      expect(result.last.login, 'ubuntujaggers');

      overrideContainer.dispose();
    });
  });
}
