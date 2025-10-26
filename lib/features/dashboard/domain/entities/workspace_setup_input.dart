class WorkspaceSetupInput {
  const WorkspaceSetupInput({
    required this.name,
    required this.budget,
    required this.currency,
    required this.goal,
    this.isConfigured = true,
  });

  final String name;
  final double budget;
  final String currency;
  final String goal;
  final bool isConfigured;
}
