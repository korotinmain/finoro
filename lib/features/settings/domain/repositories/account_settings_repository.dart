import 'package:money_tracker/features/settings/domain/entities/user_profile.dart';

abstract class AccountSettingsRepository {
  Stream<UserProfile?> watchUserProfile();
  Future<void> signOut();
}
