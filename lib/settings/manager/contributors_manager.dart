import 'package:github/github.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../../dependencies.dart';

part 'contributors_manager.g.dart';

@Riverpod(keepAlive: true)
class ContributorsManager extends _$ContributorsManager {
  ContributorsManager({GitHub? gitHub}) : _gitHubOverride = gitHub;

  final GitHub? _gitHubOverride;
  GitHub get _gitHub => _gitHubOverride ?? di<GitHub>();

  @override
  Future<List<Contributor>> build() async {
    final list = await _gitHub.repositories
        .listContributors(RepositorySlug.full(AppConfig.gitHubShortLink))
        .where((c) => c.type == 'User')
        .toList();
    return [
      ...list,
      Contributor(
        login: 'ubuntujaggers',
        htmlUrl: 'https://github.com/ubuntujaggers',
        avatarUrl: 'https://avatars.githubusercontent.com/u/38893390?v=4',
      ),
    ];
  }
}
