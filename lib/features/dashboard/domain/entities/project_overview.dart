import 'dart:math' as math;

class ProjectOverview {
  const ProjectOverview({
    required this.id,
    required this.name,
    required this.budget,
    required this.spent,
    required this.currency,
    this.coverImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double budget;
  final double spent;
  final String currency;
  final String? coverImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get remaining => budget - spent;

  double get progress {
    if (budget <= 0) {
      return spent > 0 ? 1 : 0;
    }
    return math.min(1, math.max(0, spent / budget));
  }

  bool get isOverBudget => spent > budget;
}
