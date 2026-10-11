import 'package:flutter_it/flutter_it.dart';
export 'package:flutter_it/flutter_it.dart' show di;
import 'package:injectable/injectable.dart';

import 'dependencies.config.dart';

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) => di.init(environment: environment, environmentFilter: environmentFilter);
