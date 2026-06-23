import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService._();

  static final instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> ensureUserProfile(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final displayName = user.displayName?.trim();
    final email = user.email?.trim();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final profileData = {
        'displayName': displayName?.isEmpty ?? true ? null : displayName,
        'email': email?.isEmpty ?? true ? null : email,
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSignInAt': FieldValue.serverTimestamp(),
      };

      if (snapshot.exists) {
        transaction.update(ref, profileData);
        return;
      }

      transaction.set(ref, {
        ...profileData,
        'uid': user.uid,
        'role': 'player',
        'vipUntil': null,
        'totalScore': 0,
        'wins': 0,
        'losses': 0,
        'matchesPlayed': 0,
        'lastMatchId': null,
        'lastScrollState': null,
        'preferences': <String, Object?>{
          'soundEnabled': true,
          'reducedMotion': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
