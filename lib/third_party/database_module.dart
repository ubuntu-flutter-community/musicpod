import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

import '../app/app_config.dart';
import '../common/persistence/database.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  Database get database => Database(driftDatabase(name: AppConfig.appId));
}
