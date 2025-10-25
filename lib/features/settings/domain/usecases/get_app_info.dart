import 'package:money_tracker/features/settings/domain/entities/app_info.dart';
import 'package:money_tracker/features/settings/domain/repositories/app_info_repository.dart';

class GetAppInfo {
  const GetAppInfo(this._repository);

  final AppInfoRepository _repository;

  Future<AppInfo> call() => _repository.getAppInfo();
}
