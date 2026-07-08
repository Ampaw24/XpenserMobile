import 'auth_result.dart';

abstract class IAuthService {
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithEmailPassword(String email, String password);
  Future<AuthResult> register(String name, String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
}
