import 'package:money_tracker/features/dashboard/domain/entities/workspace_overview.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_setup_input.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/ensure_workspace_initialized.dart';

abstract class DashboardRepository {
  Stream<List<WorkspaceOverview>> watchWorkspaces(String userId);
  Future<void> createWorkspace(String userId, WorkspaceSetupInput input);
  Future<WorkspaceInitializationResult> ensureWorkspace(String userId);
  Future<void> updateWorkspace(
    String userId,
    String workspaceId,
    WorkspaceSetupInput input,
  );
}
