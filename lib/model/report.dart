import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  spamFraudeGolpe,
  assedio,
  conteudoInapropriado,
  fakeNews,
  violenciaExploracao,
  discursoOdio,
  outros,
}

const Map<ReportType, String> reportTypeLabels = {
  ReportType.spamFraudeGolpe: 'Spam, fraude ou golpe',
  ReportType.assedio: 'Assédio',
  ReportType.conteudoInapropriado: 'Conteúdo inapropriado',
  ReportType.fakeNews: 'Fake news',
  ReportType.violenciaExploracao: 'Violência ou exploração',
  ReportType.discursoOdio: 'Símbolos ou discurso de ódio',
  ReportType.outros: 'Outros motivos',
};

class Report {
  final String? id;
  final String groupId;
  final String activityId; 
  final String targetUserId;
  final String targetName;
  final String targetType; 
  final String reporterUid;  
  final ReportType type;
  final String description;
  final DateTime createdAt;
  final bool dismissed;


  Report({
    this.id,
    required this.groupId,
    required this.activityId,
    required this.targetUserId,
    required this.targetName,
    required this.targetType,
    required this.reporterUid,
    required this.type,
    required this.description,
    required this.createdAt,
    this.dismissed = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'activityId': activityId,
      'targetUserId': targetUserId,
      'targetName': targetName,
      'targetType': targetType,
      'reporterUid': reporterUid,
      'type': type.name,
      'description': description,
      'createdAt': createdAt,
      'dismissed': false,
    };
  }

  factory Report.fromFirestore(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      groupId: data['groupId'] ?? '',
      activityId: data['activityId'] ?? '',
      targetUserId: data['targetUserId'] ?? '',
      targetName: data['targetName'] ?? '',
      targetType: data['targetType'] ?? 'post',
      reporterUid: data['reporterUid'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportType.outros,
      ),
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dismissed: data['dismissed'] ?? false,
    );
  }
}