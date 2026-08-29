import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Face ID / Touch ID / fingerprint gate used to re-open a saved session.
class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// True when the device has hardware *and* an enrolled biometric or PIN.
  Future<bool> isAvailable() async {
    try {
      final bool supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final bool canCheck = await _auth.canCheckBiometrics;
      if (canCheck) return true;
      // Device passcode still counts as a valid lock.
      return supported;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// A human label for the strongest enrolled biometric, for settings copy.
  Future<String> describeAvailable() async {
    try {
      final List<BiometricType> types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return 'Face unlock';
      if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
      if (types.contains(BiometricType.iris)) return 'Iris';
      if (types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak)) {
        return 'Biometric unlock';
      }
      return 'Device passcode';
    } catch (_) {
      return 'Biometric unlock';
    }
  }

  Future<bool> authenticate({
    String reason = 'Unlock Bright Future',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
