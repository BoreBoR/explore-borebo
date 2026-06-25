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

  Future<UserCredential> switchGoogleAccount() async {
    if (!kIsWeb) {
      await _initializeGoogleSignIn();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        await _googleSignIn.signOut();
      }
    }

    return signInWithGoogle();
  }

  Future<void> deleteCurrentAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No account is currently signed in.',
      );
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        await signOut();
      }
      rethrow;
    }

    await _deleteProfileIfAllowed(user);
    await _clearGoogleSessionAfterDelete();
  }

  Future<void> _clearGoogleSessionAfterDelete() async {
    if (!kIsWeb) {
      await _initializeGoogleSignIn();
      try {
        await _googleSignIn.disconnect();
      } catch (error) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {
          debugPrint('Skipping Google cleanup after delete: $error');
        }
      }
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
    try {
      await UserProfileService.instance.ensureUserProfile(user);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
      debugPrint('Skipping user profile sync: ${error.message}');
    }
  }

  Future<void> _deleteProfileIfAllowed(User user) async {
    try {
      await UserProfileService.instance.deleteUserProfile(user);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
      debugPrint('Skipping user profile delete: ${error.message}');
    }
  }
}
