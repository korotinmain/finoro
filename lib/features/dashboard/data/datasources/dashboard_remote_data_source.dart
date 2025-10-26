import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _projectsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('projects');
  }

  Stream<List<Map<String, dynamic>>> watchProjects(String userId) {
    return _projectsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'id': doc.id};
      }).toList();
    });
  }

  Future<void> createProject(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    await _projectsCollection(userId).add(payload);
  }
}
