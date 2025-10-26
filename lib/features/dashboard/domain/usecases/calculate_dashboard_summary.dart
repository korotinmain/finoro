import 'package:money_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_overview.dart';

class CalculateDashboardSummary {
  const CalculateDashboardSummary();

  DashboardSummary call(List<WorkspaceOverview> workspaces) {
    if (workspaces.isEmpty) {
      return DashboardSummary.empty;
    }

    final totalBudget = workspaces.fold<double>(
      0,
      (sum, workspace) => sum + workspace.budget,
    );
    final totalSpent = workspaces.fold<double>(
      0,
      (sum, workspace) => sum + workspace.spent,
    );

    return DashboardSummary(
      totalWorkspaces: workspaces.length,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
    );
  }
}
