class UserProfileModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String provider;
  final String dateAccountCreated;
  final String lastSignInAt;

  const UserProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.provider,
    required this.dateAccountCreated,
    required this.lastSignInAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'provider': provider,
      'date_account_created': dateAccountCreated,
      'lastSignInAt': lastSignInAt,
    };
    if (photoUrl != null) map['photoUrl'] = photoUrl;
    return map;
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) =>
      UserProfileModel(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String? ?? '',
        email: map['email'] as String? ?? '',
        photoUrl: map['photoUrl'] as String?,
        provider: map['provider'] as String? ?? 'email',
        // Support both the new key and the old 'createdAt' key for compat
        dateAccountCreated: map['date_account_created'] as String? ??
            map['createdAt'] as String? ??
            '',
        lastSignInAt: map['lastSignInAt'] as String? ?? '',
      );
}
