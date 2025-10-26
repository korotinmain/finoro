import 'package:money_tracker/features/dashboard/domain/entities/create_project_input.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class CreateProject {
  const CreateProject(this._repository);

  final DashboardRepository _repository;

  Future<void> call(String userId, CreateProjectInput input) {
    return _repository.createProject(userId, input);
  }
}
