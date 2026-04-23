import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthenticationService();

  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      googleUser != null
          ? await _signInOnFirebase(googleUser)
          : false;
      return true;
    } catch (e) {
      debugPrint("Error on sign in with google: $e");
      return false;
    }
  }

  Future<void> _signInOnFirebase(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _fbAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error on firebase auth: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _fbAuth.signOut();
      _googleSignIn.disconnect();
    } catch (e) {
      debugPrint("Error on sign out: $e");
    }
  }

  User? getFirebaseAuthUser() {
    return _fbAuth.currentUser;
  }

  bool isSignedIn() {
    return getFirebaseAuthUser() != null;
  }
}