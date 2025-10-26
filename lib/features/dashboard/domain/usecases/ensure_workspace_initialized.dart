import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class WorkspaceInitializationResult {
  const WorkspaceInitializationResult({
    required this.workspaceId,
    required this.requiresSetup,
  });

  final String workspaceId;
  final bool requiresSetup;
}

class EnsureWorkspaceInitialized {
  const EnsureWorkspaceInitialized(this._repository);

  final DashboardRepository _repository;

  Future<WorkspaceInitializationResult> call(String userId) {
    return _repository.ensureWorkspace(userId);
  }
}
