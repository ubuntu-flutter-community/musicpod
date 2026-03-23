import 'package:github/github.dart';
import 'package:injectable/injectable.dart';

@module
abstract class GithubModule {
  GitHub get gitHub => GitHub();
}
