class DashboardSummary {
  const DashboardSummary({
    required this.totalProjects,
    required this.totalBudget,
    required this.totalSpent,
  });

  final int totalProjects;
  final double totalBudget;
  final double totalSpent;

  double get remaining => totalBudget - totalSpent;

  double get utilization =>
      totalBudget <= 0 ? 0 : (totalSpent / totalBudget).clamp(0, 1);

  bool get hasProjects => totalProjects > 0;

  static const DashboardSummary empty = DashboardSummary(
    totalProjects: 0,
    totalBudget: 0,
    totalSpent: 0,
  );
}
