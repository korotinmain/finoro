import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:money_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_tracker/features/auth/domain/usecases/get_current_user.dart';
import 'package:money_tracker/features/auth/domain/usecases/reload_current_user.dart';
import 'package:money_tracker/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:money_tracker/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:money_tracker/features/auth/domain/usecases/sign_out.dart';
import 'package:money_tracker/features/auth/domain/usecases/watch_auth_user.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});

final signInWithAppleProvider = Provider<SignInWithApple>((ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final reloadCurrentUserProvider = Provider<ReloadCurrentUser>((ref) {
  return ReloadCurrentUser(ref.watch(authRepositoryProvider));
});

final watchAuthUserProvider = Provider<WatchAuthUser>((ref) {
  return WatchAuthUser(ref.watch(authRepositoryProvider));
});

final authUserStreamProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(watchAuthUserProvider)();
});

final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  final asyncUser = ref.watch(authUserStreamProvider);
  return asyncUser.maybeWhen(
    data: (user) => user,
    orElse: () => ref.watch(authRepositoryProvider).currentUser,
  );
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});
