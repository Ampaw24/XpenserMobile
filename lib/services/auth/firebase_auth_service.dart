import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:expenser/models/user_profile_model.dart';
import 'package:expenser/services/user_profile_service.dart';
import 'auth_result.dart';
import 'i_auth_service.dart';

class FirebaseAuthService implements IAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    UserProfileService? userProfileService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _profileService = userProfileService ?? UserProfileService();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserProfileService _profileService;

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.cancelled();

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;

      final candidate = _buildProfile(user, 'google');
      final checked = await _profileService.checkOrCreate(candidate);

      return AuthResult.success(
        uid: user.uid,
        userName: checked.profile.displayName,
        email: checked.profile.email,
        photoUrl: checked.profile.photoUrl,
        isNewUser: checked.isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'Google sign-in failed');
    } catch (_) {
      return AuthResult.failure('Google sign-in failed. Please try again.');
    }
  }

  @override
  Future<AuthResult> signInWithEmailPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user!;

      final candidate = _buildProfile(user, 'email');
      final checked = await _profileService.checkOrCreate(candidate);

      return AuthResult.success(
        uid: user.uid,
        userName: checked.profile.displayName,
        email: checked.profile.email,
        isNewUser: checked.isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'Login failed');
    } catch (_) {
      return AuthResult.failure('Login failed. Please try again.');
    }
  }

  @override
  Future<AuthResult> register(
      String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await result.user?.updateDisplayName(name.trim());
      await result.user?.reload();
      final user = _auth.currentUser!;

      final candidate = _buildProfile(user, 'email', overrideName: name.trim());
      final checked = await _profileService.checkOrCreate(candidate);

      return AuthResult.success(
        uid: user.uid,
        userName: checked.profile.displayName,
        email: checked.profile.email,
        isNewUser: checked.isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'Registration failed');
    } catch (_) {
      return AuthResult.failure('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  UserProfileModel _buildProfile(
    User user,
    String provider, {
    String? overrideName,
  }) {
    final now = DateTime.now().toIso8601String();
    return UserProfileModel(
      uid: user.uid,
      displayName: overrideName ??
          user.displayName ??
          user.email?.split('@').first ??
          'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      provider: provider,
      dateAccountCreated:
          user.metadata.creationTime?.toIso8601String() ?? now,
      lastSignInAt:
          user.metadata.lastSignInTime?.toIso8601String() ?? now,
    );
  }
}
