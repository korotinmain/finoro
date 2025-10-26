import 'package:money_tracker/features/dashboard/domain/entities/create_project_input.dart';
import 'package:money_tracker/features/dashboard/domain/entities/project_overview.dart';

abstract class DashboardRepository {
  Stream<List<ProjectOverview>> watchProjects(String userId);
  Future<void> createProject(String userId, CreateProjectInput input);
}
