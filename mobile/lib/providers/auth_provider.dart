import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/biometric_service.dart';
import '../core/services/notification_service.dart';
import '../core/storage/app_prefs.dart';
import '../core/storage/secure_store.dart';
import '../core/storage/session.dart';
import '../data/models/app_user.dart';
import '../data/models/auth_session.dart';
import '../data/repositories/auth_repository.dart';

enum AuthState { unknown, signedOut, signedIn, locked }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository repository,
    required SecureStore store,
    required BiometricService biometrics,
  })  : _repo = repository,
        _store = store,
        _biometrics = biometrics;

  final AuthRepository _repo;
  final SecureStore _store;
  final BiometricService _biometrics;

  AuthState _state = AuthState.unknown;
  AppUser? _user;
  bool _busy = false;
  String? _error;

  AuthState get state => _state;
  AppUser? get user => _user;
  bool get busy => _busy;
  String? get error => _error;
  bool get isSignedIn => _state == AuthState.signedIn && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Restores a saved session at start-up, applying the biometric lock when the
  /// user has enabled it.
  Future<void> restore() async {
    final String? token = await _store.readToken();
    if (token == null || token.isEmpty) {
      _setState(AuthState.signedOut);
      return;
    }

    Session.token = token;

    // Show the cached profile immediately so the app is usable offline.
    final String? cached = await _store.readUserJson();
    if (cached != null && cached.isNotEmpty) {
      try {
        _user = AppUser.fromJson(
          (jsonDecode(cached) as Map<dynamic, dynamic>).cast<String, dynamic>(),
        );
      } catch (_) {}
    }

    if (AppPrefs.instance.biometricLock && _user != null) {
      _setState(AuthState.locked);
      return;
    }

    await _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    try {
      final AppUser fresh = await _repo.me();
      _user = fresh;
      await _store.writeUserJson(jsonEncode(fresh.toJson()));
      _setState(AuthState.signedIn);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await signOut();
        return;
      }
      // Offline or server hiccup: keep the cached profile.
      _setState(_user != null ? AuthState.signedIn : AuthState.signedOut);
    } catch (_) {
      _setState(_user != null ? AuthState.signedIn : AuthState.signedOut);
    }
  }

  /// Unlocks a session that is behind the biometric gate.
  Future<bool> unlock() async {
    final bool ok = await _biometrics.authenticate(
      reason: 'Unlock your Bright Future account',
    );
    if (ok) {
      await _refreshProfile();
    }
    return ok;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) =>
      _run(() => _repo.login(email: email, password: password));

  Future<bool> signInAsAdmin({
    required String email,
    required String password,
  }) =>
      _run(() => _repo.adminLogin(email: email, password: password));

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) =>
      _run(() => _repo.signup(
            fullName: fullName,
            email: email,
            password: password,
            phone: phone,
          ));

  Future<bool> _run(Future<AuthSession> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final AuthSession session = await action();
      Session.token = session.token;
      _user = session.user;
      await _store.writeToken(session.token);
      await _store.writeUserJson(jsonEncode(session.user.toJson()));
      await AppPrefs.instance.setLastEmail(session.user.email);
      _busy = false;
      _setState(AuthState.signedIn);
      unawaited(_subscribeToTopics(session.user));
      return true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
    }
    _busy = false;
    notifyListeners();
    return false;
  }

  Future<void> _subscribeToTopics(AppUser user) async {
    await NotificationService.instance.subscribeToTopic('all-users');
    if (user.isAdmin) {
      await NotificationService.instance.subscribeToTopic('admins');
    }
  }

  Future<void> signOut({bool keepCache = false}) async {
    Session.clear();
    _user = null;
    _error = null;
    await _store.clear();
    if (!keepCache) {
      await AppPrefs.instance.clearCache();
    }
    await AppPrefs.instance.setBiometricLock(false);
    _setState(AuthState.signedOut);
  }

  /// Locally updates the cached profile (used after a profile edit).
  Future<void> applyProfile(AppUser updated) async {
    _user = updated;
    await _store.writeUserJson(jsonEncode(updated.toJson()));
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _setState(AuthState value) {
    _state = value;
    notifyListeners();
  }
}
