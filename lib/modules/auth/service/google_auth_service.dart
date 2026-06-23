import 'package:benjii/modules/auth/service/user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static const _serverClientId =
      '163340677850-n3elcmm8kqh5v56pgtvq66ukrf34vqbu.apps.googleusercontent.com';

  static final instance = GoogleAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleSignInInitialization;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final credential = await _firebaseAuth.signInWithPopup(
        GoogleAuthProvider(),
      );
      await _ensureProfile(credential.user);
      return credential;
    }

    await _initializeGoogleSignIn();

    final googleAccount = await _googleSignIn.authenticate();
    final googleAuth = googleAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await _ensureProfile(userCredential.user);
    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    if (!kIsWeb) {
      await _initializeGoogleSignIn();
      await _googleSignIn.signOut();
    }
  }

  Future<void> _initializeGoogleSignIn() {
    return _googleSignInInitialization ??= _googleSignIn.initialize(
      serverClientId: _serverClientId,
    );
  }

  Future<void> _ensureProfile(User? user) async {
    if (user == null) {
      return;
    }
    await UserProfileService.instance.ensureUserProfile(user);
  }
}
