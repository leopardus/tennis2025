import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? _googleUser;
  String? _username;

  bool get isLoggedIn => _googleUser != null || _username != null;
  String? get displayName => _googleUser?.displayName ?? _username;
  String? get userEmail => _googleUser?.email;

  AuthService() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _googleUser = account;
      if (_googleUser != null) {
        _username = null;
      }
      notifyListeners();
    });
    _googleSignIn.signInSilently();
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      // Re-throw the error so the UI layer can catch it and show feedback.
      throw error;
    }
  }

  Future<bool> signInWithUsernamePassword(String username, String password) async {
    // This is a mock authentication.
    // In a real app, you would call your backend service here.
    if (username == 'admin' && password == 'admin') {
      _username = username;
      _googleUser = null; // Clear Google user
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _googleUser = null;
    _username = null;
    notifyListeners();
  }
}
