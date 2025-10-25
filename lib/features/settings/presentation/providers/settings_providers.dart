import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/settings/data/repositories/account_settings_repository_impl.dart';
import 'package:money_tracker/features/settings/data/repositories/app_info_repository_impl.dart';
import 'package:money_tracker/features/settings/domain/entities/app_info.dart';
import 'package:money_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:money_tracker/features/settings/domain/repositories/account_settings_repository.dart';
import 'package:money_tracker/features/settings/domain/repositories/app_info_repository.dart';
import 'package:money_tracker/features/settings/domain/usecases/get_app_info.dart';
import 'package:money_tracker/features/settings/domain/usecases/sign_out_user.dart';
import 'package:money_tracker/features/settings/domain/usecases/watch_user_profile.dart';

final accountSettingsRepositoryProvider =
    Provider<AccountSettingsRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AccountSettingsRepositoryImpl(authRepository);
});

final watchUserProfileUseCaseProvider = Provider<WatchUserProfile>((ref) {
  return WatchUserProfile(ref.watch(accountSettingsRepositoryProvider));
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(watchUserProfileUseCaseProvider)();
});

final signOutUserUseCaseProvider = Provider<SignOutUser>((ref) {
  return SignOutUser(ref.watch(accountSettingsRepositoryProvider));
});

final appInfoRepositoryProvider = Provider<AppInfoRepository>((ref) {
  return AppInfoRepositoryImpl();
});

final getAppInfoUseCaseProvider = Provider<GetAppInfo>((ref) {
  return GetAppInfo(ref.watch(appInfoRepositoryProvider));
});

final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  return ref.watch(getAppInfoUseCaseProvider)();
});
