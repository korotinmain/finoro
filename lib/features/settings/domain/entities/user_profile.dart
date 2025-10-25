class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.isEmailVerified,
  });

  final String displayName;
  final String email;
  final bool isEmailVerified;
}
