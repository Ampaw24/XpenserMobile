class UserProfileModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String provider;
  final String dateAccountCreated;
  final String lastSignInAt;
  final String? fcmToken;

  /// ISO 3166-1 alpha-2, e.g. "GH". Null until the user sets it.
  final String? countryCode;

  /// ISO 4217, e.g. "GHS". Null until the user sets it.
  final String? currencyCode;

  const UserProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.provider,
    required this.dateAccountCreated,
    required this.lastSignInAt,
    this.fcmToken,
    this.countryCode,
    this.currencyCode,
  });

  /// True once country and currency are set; required before using the app.
  bool get hasLocale => countryCode != null && currencyCode != null;

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
    if (fcmToken != null) map['fcmToken'] = fcmToken;
    if (countryCode != null) map['country'] = countryCode;
    if (currencyCode != null) map['currency'] = currencyCode;
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
        dateAccountCreated:
            map['date_account_created'] as String? ??
            map['createdAt'] as String? ??
            '',
        lastSignInAt: map['lastSignInAt'] as String? ?? '',
        fcmToken: map['fcmToken'] as String?,
        countryCode: _nonEmpty(map['country']),
        currencyCode: _nonEmpty(map['currency']),
      );

  static String? _nonEmpty(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
}
