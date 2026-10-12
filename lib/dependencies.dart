import 'package:get_it/get_it.dart';
export 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependencies.config.dart';

GetIt get di => GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) => di.init(environment: environment, environmentFilter: environmentFilter);
