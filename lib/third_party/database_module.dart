import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app/app_config.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  Database get database => Database(
    driftDatabase(
      name: AppConfig.appId,
      native: DriftNativeOptions(
        databaseDirectory: () async {
          final supportDir = await getApplicationSupportDirectory();
          await supportDir.create(recursive: true);

          Directory docsDir;
          try {
            docsDir = await getApplicationDocumentsDirectory();
          } catch (e, stackTrace) {
            Logger.w(
              'Application documents directory not found or inaccessible: $e, ${AppConfig.appName} is now using support directory anyways!',
              tag: '$DatabaseModule',
              trace: stackTrace,
            );
            return supportDir;
          }

          try {
            for (final ext in ['', '-wal', '-shm']) {
              final oldFile = File(
                p.join(docsDir.path, '${AppConfig.appId}.sqlite$ext'),
              );
              final newFile = File(
                p.join(supportDir.path, '${AppConfig.appId}.sqlite$ext'),
              );
              if (await oldFile.exists() && !await newFile.exists()) {
                Logger.i(
                  'Found old database file at ${oldFile.path}, moving to ${newFile.path}',
                  tag: '$DatabaseModule',
                );
                try {
                  await oldFile.rename(newFile.path);
                } on FileSystemException {
                  await oldFile.copy(newFile.path);
                  await oldFile.delete();
                }
              }
            }
          } catch (e, stackTrace) {
            Logger.w(
              'Failed to migrate database files: $e, ${AppConfig.appName} is now using support directory anyways!',
              tag: '$DatabaseModule',
              trace: stackTrace,
            );
          }
          return supportDir;
        },
      ),
    ),
  );
}
