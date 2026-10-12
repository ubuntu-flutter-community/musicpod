import 'package:github/github.dart';
import 'package:injectable/injectable.dart';

import '../app/app_config.dart';

@module
abstract class GithubModule {
  GitHub get gitHub => GitHub();
}

extension GitHubX on GitHub {
  Future<Release?> get latestRelease async =>
      (await repositories
              .listReleases(RepositorySlug.full(AppConfig.gitHubShortLink))
              .toList())
          .firstOrNull;
}
