class AuthResult {
  final String? userName;
  final String? error;
  final bool cancelled;

  const AuthResult._({this.userName, this.error, this.cancelled = false});

  factory AuthResult.success(String userName) =>
      AuthResult._(userName: userName);

  factory AuthResult.failure(String error) => AuthResult._(error: error);

  factory AuthResult.cancelled() => const AuthResult._(cancelled: true);

  bool get isSuccess => userName != null;
}
