import 'package:money_tracker/features/settings/domain/entities/app_info.dart';

abstract class AppInfoRepository {
  Future<AppInfo> getAppInfo();
}
