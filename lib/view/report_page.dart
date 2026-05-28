// lib/pages/report_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../controller/report_controller.dart';
import '../service/report_service.dart';
import '../repository/report_repository.dart';
import '../view/report_reason_view.dart';

class ReportPage extends StatefulWidget {
  final String groupId;
  final String targetId;  
  final String targetType;  
  final String targetUserId; 
  final String targetName;  

  const ReportPage({
    super.key,
    required this.groupId,
    required this.targetId,
    required this.targetType,
    required this.targetUserId,
    required this.targetName,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final ReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReportController(
      service: ReportService(repository: ReportRepository()),
      groupId: widget.groupId,
      activityId: widget.targetId,
      targetType: widget.targetType,
      targetUserId: widget.targetUserId,
      targetName: widget.targetName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSuccessMessage() {
    final targetWord = widget.targetType == 'post' ? 'post' : 'usuário';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: AppColors.bgVerde, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Denúncia enviada!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          'Agradecemos a denúncia deste $targetWord.'
          ' Sua colaboração ajuda a manter a comunidade segura.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgVerde,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);    // fecha o diálogo
                Navigator.pop(context); // fecha a ReportPage
              },
              child: const Text('Fechar', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.targetType == 'post' ? 'Denunciar post' : 'Denunciar usuário';

    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        backgroundColor: AppColors.bgVerde,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.branco),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.branco,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ReportReasonView(
        controller: _controller,
        onReportSubmitted: _showSuccessMessage,
      ),
    );
  }
}