import 'package:flutter/foundation.dart';

/// Shared loading/error bookkeeping for the data providers.
mixin LoadState on ChangeNotifier {
  bool _loading = false;
  bool _refreshing = false;
  String? _error;
  bool _fromCache = false;

  bool get loading => _loading;
  bool get refreshing => _refreshing;
  String? get error => _error;

  /// True when the visible data came from the offline snapshot.
  bool get fromCache => _fromCache;

  @protected
  void beginLoad({bool refresh = false}) {
    if (refresh) {
      _refreshing = true;
    } else {
      _loading = true;
    }
    _error = null;
    notifyListeners();
  }

  @protected
  void endLoad({String? error, bool fromCache = false}) {
    _loading = false;
    _refreshing = false;
    _error = error;
    _fromCache = fromCache;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
