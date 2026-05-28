import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/report.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').add(report.toFirestore());
  }
}