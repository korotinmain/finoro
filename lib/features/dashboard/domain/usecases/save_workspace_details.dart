import 'package:money_tracker/features/dashboard/domain/entities/workspace_setup_input.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class SaveWorkspaceDetails {
  const SaveWorkspaceDetails(this._repository);

  final DashboardRepository _repository;

  Future<void> call(
    String userId,
    String workspaceId,
    WorkspaceSetupInput input,
  ) {
    return _repository.updateWorkspace(userId, workspaceId, input);
  }
}
