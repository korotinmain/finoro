class CreateProjectInput {
  const CreateProjectInput({
    required this.name,
    required this.budget,
    required this.currency,
  });

  final String name;
  final double budget;
  final String currency;
}
