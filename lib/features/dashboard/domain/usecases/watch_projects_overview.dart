import 'package:money_tracker/features/dashboard/domain/entities/project_overview.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class WatchProjectsOverview {
  const WatchProjectsOverview(this._repository);

  final DashboardRepository _repository;

  Stream<List<ProjectOverview>> call(String userId) {
    return _repository.watchProjects(userId);
  }
}
