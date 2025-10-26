import 'package:cloud_firestore/cloud_firestore.dart';

class WorkspaceBootstrapResult {
  const WorkspaceBootstrapResult({
    required this.workspaceId,
    required this.requiresSetup,
  });

  final String workspaceId;
  final bool requiresSetup;
}

class DashboardRemoteDataSource {
  DashboardRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _workspacesCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('workspaces');
  }

  Stream<List<Map<String, dynamic>>> watchWorkspaces(String userId) {
    return _workspacesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {...data, 'id': doc.id};
          })
          .toList(growable: false);
    });
  }

  Future<void> createWorkspace(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    await _workspacesCollection(userId).add(payload);
  }

  Future<WorkspaceBootstrapResult> ensureWorkspaceDocument(
    String userId,
  ) async {
    final collection = _workspacesCollection(userId);
    final snapshot = await collection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      final requiresSetup = !(data['isConfigured'] as bool? ?? true);
      return WorkspaceBootstrapResult(
        workspaceId: doc.id,
        requiresSetup: requiresSetup,
      );
    }

    final docRef = collection.doc();
    await docRef.set({
      'name': '',
      'goal': '',
      'budget': 0.0,
      'spent': 0.0,
      'currency': 'USD',
      'isConfigured': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return WorkspaceBootstrapResult(
      workspaceId: docRef.id,
      requiresSetup: true,
    );
  }

  Future<void> updateWorkspace(
    String userId,
    String workspaceId,
    Map<String, dynamic> payload,
  ) async {
    await _workspacesCollection(userId).doc(workspaceId).update(payload);
  }
}
