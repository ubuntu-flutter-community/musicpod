import 'package:connectivity_plus/connectivity_plus.dart';

extension ConnectivityX on Connectivity {
  bool isOnline(List<ConnectivityResult>? res) =>
      res?.contains(ConnectivityResult.ethernet) == true ||
      res?.contains(ConnectivityResult.bluetooth) == true ||
      res?.contains(ConnectivityResult.mobile) == true ||
      res?.contains(ConnectivityResult.vpn) == true ||
      res?.contains(ConnectivityResult.wifi) == true;

  bool isMaybeLowBandWidth(List<ConnectivityResult>? res) =>
      res?.contains(ConnectivityResult.ethernet) == false &&
      res?.contains(ConnectivityResult.wifi) == false;
}
