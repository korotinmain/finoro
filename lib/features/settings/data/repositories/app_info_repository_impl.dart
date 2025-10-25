import 'package:money_tracker/features/settings/domain/entities/app_info.dart';
import 'package:money_tracker/features/settings/domain/repositories/app_info_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoRepositoryImpl implements AppInfoRepository {
  @override
  Future<AppInfo> getAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppInfo(version: '${info.version}+${info.buildNumber}');
    } catch (_) {
      return const AppInfo(version: '1.0.0');
    }
  }
}
