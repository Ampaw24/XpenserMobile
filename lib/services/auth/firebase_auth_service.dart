import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_result.dart';
import 'i_auth_service.dart';

class FirebaseAuthService implements IAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

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
      final name = result.user?.displayName ??
          result.user?.email?.split('@').first ??
          'User';
      return AuthResult.success(name);
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
      final name =
          result.user?.displayName ?? email.split('@').first;
      return AuthResult.success(name);
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
      return AuthResult.success(name.trim());
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
}
