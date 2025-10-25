class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.isEmailVerified,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final bool isEmailVerified;
  final String? displayName;
  final String? photoUrl;

  String get displayNameOrEmail =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : email;

  AuthUser copyWith({
    String? uid,
    String? email,
    bool? isEmailVerified,
    String? displayName,
    String? photoUrl,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
