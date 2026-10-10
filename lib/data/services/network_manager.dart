import 'dart:async';

import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

// https://pub.dev/packages/connectivity_plus#usage
class NetworkManager {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'NetworkManager'));

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  NetworkManager() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    // Connectivity().checkConnectivity().then(_onConnectivityChanged);
  }

  List<ConnectivityResult> latestConnectivityResult = [];

  void _onConnectivityChanged(List<ConnectivityResult> event) {
    latestConnectivityResult = event;
    _log.i('_onConnectivityChanged event=$event isMobileNetwork=${isMobileNetwork()}');
  }

  bool isMobileNetwork() {
    return latestConnectivityResult.contains(ConnectivityResult.mobile);
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
