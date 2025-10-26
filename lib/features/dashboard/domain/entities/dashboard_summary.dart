class DashboardSummary {
  const DashboardSummary({
    required this.totalWorkspaces,
    required this.totalBudget,
    required this.totalSpent,
  });

  final int totalWorkspaces;
  final double totalBudget;
  final double totalSpent;

  double get remaining => totalBudget - totalSpent;

  double get utilization =>
      totalBudget <= 0 ? 0 : (totalSpent / totalBudget).clamp(0, 1);

  bool get hasWorkspaces => totalWorkspaces > 0;

  static const DashboardSummary empty = DashboardSummary(
    totalWorkspaces: 0,
    totalBudget: 0,
    totalSpent: 0,
  );
}
