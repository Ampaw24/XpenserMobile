class AuthResult {
  final String? uid;
  final String? userName;
  final String? email;
  final String? photoUrl;
  final bool isNewUser;

  /// From the stored profile; null when the user hasn't set them yet.
  final String? countryCode;
  final String? currencyCode;
  final String? error;
  final bool cancelled;

  const AuthResult._({
    this.uid,
    this.userName,
    this.email,
    this.photoUrl,
    this.isNewUser = false,
    this.countryCode,
    this.currencyCode,
    this.error,
    this.cancelled = false,
  });

  factory AuthResult.success({
    required String uid,
    required String userName,
    required String email,
    String? photoUrl,
    bool isNewUser = false,
    String? countryCode,
    String? currencyCode,
  }) => AuthResult._(
    uid: uid,
    userName: userName,
    email: email,
    photoUrl: photoUrl,
    isNewUser: isNewUser,
    countryCode: countryCode,
    currencyCode: currencyCode,
  );

  factory AuthResult.failure(String error) => AuthResult._(error: error);

  factory AuthResult.cancelled() => const AuthResult._(cancelled: true);

  bool get isSuccess => uid != null;
}
