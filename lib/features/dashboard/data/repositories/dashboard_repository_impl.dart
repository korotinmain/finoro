import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_overview.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_setup_input.dart';
import 'package:money_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:money_tracker/features/dashboard/domain/usecases/ensure_workspace_initialized.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Stream<List<WorkspaceOverview>> watchWorkspaces(String userId) {
    return _remoteDataSource.watchWorkspaces(userId).map((rawProjects) {
      return rawProjects
          .map(_mapWorkspace)
          .whereType<WorkspaceOverview>()
          .toList(growable: false);
    });
  }

  @override
  Future<void> createWorkspace(String userId, WorkspaceSetupInput input) async {
    await _remoteDataSource.createWorkspace(userId, {
      'name': input.name,
      'budget': input.budget,
      'spent': 0.0,
      'currency': input.currency,
      'goal': input.goal,
      'isConfigured': input.isConfigured,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<WorkspaceInitializationResult> ensureWorkspace(String userId) async {
    final result = await _remoteDataSource.ensureWorkspaceDocument(userId);
    return WorkspaceInitializationResult(
      workspaceId: result.workspaceId,
      requiresSetup: result.requiresSetup,
    );
  }

  @override
  Future<void> updateWorkspace(
    String userId,
    String workspaceId,
    WorkspaceSetupInput input,
  ) {
    return _remoteDataSource.updateWorkspace(userId, workspaceId, {
      'name': input.name,
      'budget': input.budget,
      'currency': input.currency,
      'goal': input.goal,
      'isConfigured': input.isConfigured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  WorkspaceOverview? _mapWorkspace(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }

    final name = (data['name'] as String?)?.trim();
    final budget = _toDouble(data['budget'] ?? data['totalBudget']);
    final spent = _toDouble(data['spent'] ?? data['totalSpent']);

    final goal = (data['goal'] as String?)?.trim() ?? '';
    final isConfigured = data['isConfigured'] as bool? ?? true;

    return WorkspaceOverview(
      id: id,
      name: (name == null || name.isEmpty) ? 'Untitled Workspace' : name,
      budget: budget,
      spent: spent,
      currency:
          (data['currency'] as String?)?.trim().isNotEmpty == true
              ? (data['currency'] as String).trim()
              : 'USD',
      goal: goal,
      coverImageUrl: data['coverImageUrl'] as String?,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      isConfigured: isConfigured,
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}
