import 'package:money_tracker/features/dashboard/domain/entities/workspace_setup_input.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class CreateWorkspace {
  const CreateWorkspace(this._repository);

  final DashboardRepository _repository;

  Future<void> call(String userId, WorkspaceSetupInput input) {
    return _repository.createWorkspace(userId, input);
  }
}
