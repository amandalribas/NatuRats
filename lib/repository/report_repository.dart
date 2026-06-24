import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/report.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;


  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').add(report.toFirestore());
  }

  Future<int> countUserReportsForTarget({
    required String reporterUid,
    required String groupId,
    required String targetId,
    required String targetType,
  }) async {
    Query query = _firestore
        .collection('reports')
        .where('reporterUid', isEqualTo: reporterUid)
        .where('groupId', isEqualTo: groupId)
        .where('targetType', isEqualTo: targetType);

    if (targetType == 'post') {
      query = query.where('activityId', isEqualTo: targetId);
    } else {
      query = query.where('targetUserId', isEqualTo: targetId);
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }
  Future<List<Report>> fetchPendingReportsForGroup(String groupId) async {
    final snapshot = await _firestore
        .collection('reports')
        .where('groupId', isEqualTo: groupId)
        .where('dismissed', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Report.fromFirestore(doc.id, doc.data()))
        .toList();
  }


  Future<void> dismissReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'dismissed': true,
      'dismissedAt': FieldValue.serverTimestamp(),
    });
  }


  Stream<int> pendingReportsCountStream(String groupId) {
    return _firestore
        .collection('reports')
        .where('groupId', isEqualTo: groupId)
        .where('dismissed', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}