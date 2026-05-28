import '../model/report.dart';
import '../repository/report_repository.dart';

class ReportService {
  final ReportRepository _repository;
  

  ReportService({required ReportRepository repository})
      : _repository = repository;

  Future<void> submitReport({
    required String groupId,
    required String activityId,
    required ReportType type,
    required String description,
    required String targetUserId, 
    required String targetName,
  }) async {

    if (description.trim().isEmpty) {
      throw Exception('A descrição não pode ficar em branco.');
    }

    final report = Report(
      groupId: groupId,
      activityId: activityId,
      targetUserId: targetUserId,
      targetName: targetName,
      type: type,
      description: description.trim(),
      createdAt: DateTime.now(),
      
    );

    await _repository.addReport(report);
  }
}