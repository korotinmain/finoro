import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:money_tracker/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:money_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/entities/project_overview.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/calculate_dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/watch_projects_overview.dart';

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final watchProjectsOverviewProvider = Provider<WatchProjectsOverview>((ref) {
  return WatchProjectsOverview(ref.watch(dashboardRepositoryProvider));
});

final calculateDashboardSummaryProvider =
    Provider<CalculateDashboardSummary>((ref) {
  return const CalculateDashboardSummary();
});

final dashboardProjectsProvider =
    StreamProvider<List<ProjectOverview>>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) {
    return Stream.value(const <ProjectOverview>[]);
  }

  final watchProjects = ref.watch(watchProjectsOverviewProvider);
  return watchProjects(user.uid);
});

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final calculator = ref.watch(calculateDashboardSummaryProvider);
  final projectsAsync = ref.watch(dashboardProjectsProvider);

  return projectsAsync.maybeWhen(
    data: calculator.call,
    orElse: () => DashboardSummary.empty,
  );
});
