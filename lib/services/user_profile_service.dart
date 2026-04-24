import 'package:firebase_database/firebase_database.dart';
import 'package:expenser/models/user_profile_model.dart';

class UserProfileService {
  DatabaseReference _profileRef(String uid) =>
      FirebaseDatabase.instance.ref('users/$uid/profile');

  /// Checks RTDB for an existing profile.
  /// - EXISTS  → updates mutable fields only; returns the stored profile + isNewUser: false
  /// - NEW     → writes the full profile with date_account_created; returns isNewUser: true
  Future<({UserProfileModel profile, bool isNewUser})> checkOrCreate(
    UserProfileModel candidate,
  ) async {
    final ref = _profileRef(candidate.uid);
    final snap = await ref.get();

    if (snap.exists && snap.value != null) {
      await ref.update({
        'displayName': candidate.displayName,
        if (candidate.photoUrl != null) 'photoUrl': candidate.photoUrl,
        'lastSignInAt': candidate.lastSignInAt,
      });
      final fetched = UserProfileModel.fromMap(
        Map<String, dynamic>.from(snap.value as Map),
      );
      return (profile: fetched, isNewUser: false);
    } else {
      await ref.set(candidate.toMap());
      return (profile: candidate, isNewUser: true);
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _profileRef(uid).update({'fcmToken': token});
  }

  Future<UserProfileModel?> get(String uid) async {
    final snap = await _profileRef(uid).get();
    if (!snap.exists || snap.value == null) return null;
    return UserProfileModel.fromMap(
      Map<String, dynamic>.from(snap.value as Map),
    );
  }
}
