import 'package:firebase_auth/firebase_auth.dart';
import '../model/report.dart';
import '../repository/report_repository.dart';

class ReportService {
  final ReportRepository _repository;

  static const int _maxReportsPerTarget = 3;

  ReportService({required ReportRepository repository})
      : _repository = repository;

  Future<void> submitReport({
    required String groupId,
    required String activityId,
    required String targetType,  
    required ReportType type,
    required String description,
    required String targetUserId,
    required String targetName,
  }) async {
    if (description.trim().isEmpty) {
      throw Exception('A descrição não pode ficar em branco.');
    }

    final reporterUid = FirebaseAuth.instance.currentUser?.uid;
    if (reporterUid == null) {
      throw Exception('Usuário não autenticado.');
    }


    final targetId = targetType == 'post' ? activityId : targetUserId;

    final count = await _repository.countUserReportsForTarget(
      reporterUid: reporterUid,
      groupId: groupId,
      targetId: targetId,
      targetType: targetType,
    );

    if (count >= _maxReportsPerTarget) {
      final palavra = targetType == 'post' ? 'post' : 'usuário';
      throw Exception(
        'Você já denunciou este $palavra $_maxReportsPerTarget vezes neste grupo.',
      );
    }

    final report = Report(
      groupId: groupId,
      activityId: activityId,
      targetUserId: targetUserId,
      targetName: targetName,
      targetType: targetType,
      reporterUid: reporterUid,
      type: type,
      description: description.trim(),
      createdAt: DateTime.now(),
    );

    await _repository.addReport(report);
  }
}