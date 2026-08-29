import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device currently has any network transport.
///
/// This is a *transport* check, not a reachability check - requests can still
/// fail while "online". The API layer handles that case separately.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    try {
      final List<ConnectivityResult> result =
          await _connectivity.checkConnectivity();
      return _hasTransport(result);
    } catch (_) {
      return true; // Assume online rather than blocking the user.
    }
  }

  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((List<ConnectivityResult> r) => _hasTransport(r));

  bool _hasTransport(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  }
}
