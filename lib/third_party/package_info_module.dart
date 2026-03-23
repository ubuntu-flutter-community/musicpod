import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@module
abstract class PackageInfoModule {
  @preResolve
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();
}
