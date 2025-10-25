import 'package:money_tracker/features/dashboard/domain/entities/project_overview.dart';

abstract class DashboardRepository {
  Stream<List<ProjectOverview>> watchProjects(String userId);
}
