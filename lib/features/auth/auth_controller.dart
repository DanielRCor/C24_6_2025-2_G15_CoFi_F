import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loginWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.signInWithGoogle();

    _isLoading = false;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _errorMessage = "Error al iniciar sesión";
    }

    notifyListeners();
  }

  void logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
