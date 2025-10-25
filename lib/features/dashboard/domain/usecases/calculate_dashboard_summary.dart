import 'package:money_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/entities/project_overview.dart';

class CalculateDashboardSummary {
  const CalculateDashboardSummary();

  DashboardSummary call(List<ProjectOverview> projects) {
    if (projects.isEmpty) {
      return DashboardSummary.empty;
    }

    final totalBudget = projects.fold<double>(
      0,
      (sum, project) => sum + project.budget,
    );
    final totalSpent = projects.fold<double>(
      0,
      (sum, project) => sum + project.spent,
    );

    return DashboardSummary(
      totalProjects: projects.length,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
    );
  }
}
