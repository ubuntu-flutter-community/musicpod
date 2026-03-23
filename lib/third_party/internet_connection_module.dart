import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:injectable/injectable.dart';

@module
abstract class InternetConnectionModule {
  InternetConnection get internetConnection => InternetConnection();
}
