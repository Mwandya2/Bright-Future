import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider(this._service) {
    _bootstrap();
  }

  final ConnectivityService _service;
  StreamSubscription<bool>? _sub;

  bool _online = true;
  bool get isOnline => _online;
  bool get isOffline => !_online;

  Future<void> _bootstrap() async {
    _online = await _service.isOnline();
    notifyListeners();
    _sub = _service.onStatusChange.listen((bool value) {
      if (_online != value) {
        _online = value;
        notifyListeners();
      }
    });
  }

  Future<void> refresh() async {
    final bool value = await _service.isOnline();
    if (_online != value) {
      _online = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
