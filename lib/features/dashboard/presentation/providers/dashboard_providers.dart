import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:money_tracker/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:money_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_overview.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/calculate_dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/create_workspace.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/ensure_workspace_initialized.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/save_workspace_details.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/watch_workspace_overview.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final watchWorkspaceOverviewProvider = Provider<WatchWorkspaceOverview>((ref) {
  return WatchWorkspaceOverview(ref.watch(dashboardRepositoryProvider));
});

final calculateDashboardSummaryProvider = Provider<CalculateDashboardSummary>((
  ref,
) {
  return const CalculateDashboardSummary();
});

final saveWorkspaceDetailsProvider = Provider<SaveWorkspaceDetails>((ref) {
  return SaveWorkspaceDetails(ref.watch(dashboardRepositoryProvider));
});

final createWorkspaceProvider = Provider<CreateWorkspace>((ref) {
  return CreateWorkspace(ref.watch(dashboardRepositoryProvider));
});

final ensureWorkspaceInitializedProvider = Provider<EnsureWorkspaceInitialized>(
  (ref) {
    return EnsureWorkspaceInitialized(ref.watch(dashboardRepositoryProvider));
  },
);

final dashboardWorkspacesProvider = StreamProvider<List<WorkspaceOverview>>((
  ref,
) {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) {
    return Stream.value(const <WorkspaceOverview>[]);
  }

  final watchWorkspaces = ref.watch(watchWorkspaceOverviewProvider);
  return watchWorkspaces(user.uid);
});

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final calculator = ref.watch(calculateDashboardSummaryProvider);
  final workspacesAsync = ref.watch(dashboardWorkspacesProvider);

  return workspacesAsync.maybeWhen(
    data: calculator.call,
    orElse: () => DashboardSummary.empty,
  );
});
