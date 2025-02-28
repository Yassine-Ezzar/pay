import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (e) {
      print('Erreur lors de la vérification de la biométrie: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour vous enregistrer avec SmartPay',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true, // Continue même si l’app passe en arrière-plan
        ),
      );
    } catch (e) {
      print('Erreur biométrique: $e');
      return false;
    }
  }
}