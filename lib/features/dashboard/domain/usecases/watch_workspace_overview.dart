import 'package:money_tracker/features/dashboard/domain/entities/workspace_overview.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class WatchWorkspaceOverview {
  const WatchWorkspaceOverview(this._repository);

  final DashboardRepository _repository;

  Stream<List<WorkspaceOverview>> call(String userId) {
    return _repository.watchWorkspaces(userId);
  }
}
