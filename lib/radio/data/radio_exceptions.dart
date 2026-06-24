import 'package:radio_browser_api/radio_browser_api.dart';

class FindRadioBrowserHostsTimeoutException implements Exception {
  static const Duration timeoutDuration = Duration(seconds: 15);

  FindRadioBrowserHostsTimeoutException();

  @override
  String toString() =>
      'Finding Radio Browser hosts takes longer than usual. Are you connected to the internet? If yes, this might be a server issue.';
}

class LookUpRadioBrowserHostsException implements Exception {
  LookUpRadioBrowserHostsException();

  @override
  String toString() =>
      'Can not lookup any Radio Browser hosts, are you connected to the internet?';
}

class RadioBrowserApiNotConnectedException implements Exception {
  final String? message;

  RadioBrowserApiNotConnectedException({this.message});

  @override
  String toString() => message ?? '$RadioBrowserApi not connected';
}

class RadioBrowserServerUnavailableException implements Exception {
  final String? message;

  RadioBrowserServerUnavailableException([this.message]);

  @override
  String toString() => message ?? 'RadioBrowser server is unavailable';
}

class FindStationTimeoutException implements Exception {
  FindStationTimeoutException();

  @override
  String toString() =>
      'Finding (this) station(s) takes longer than usual. Are you connected to the internet? If yes, this might be a server issue.';
}

class LoadTagsTimeoutException implements Exception {
  LoadTagsTimeoutException();

  static const Duration timeoutDuration = Duration(seconds: 15);

  @override
  String toString() =>
      'Loading radio tags takes longer than usual. Are you connected to the internet? If yes, this might be a server issue.';
}

class LoadTagsFailedException implements Exception {
  final String message;

  LoadTagsFailedException(this.message);

  @override
  String toString() =>
      'An error occurred while loading radio tags, the server might be unavailable: $message';
}
