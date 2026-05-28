// lib/view/report_reason_view.dart
import 'package:flutter/material.dart';
import '../controller/report_controller.dart';
import '../model/report.dart';
import 'report_description_view.dart';

class ReportReasonView extends StatefulWidget {
  final ReportController controller;
  final VoidCallback? onReportSubmitted;

  const ReportReasonView({
    super.key,
    required this.controller,
    this.onReportSubmitted,
  });

  @override
  State<ReportReasonView> createState() => _ReportReasonViewState();
}

class _ReportReasonViewState extends State<ReportReasonView> {
  @override
  Widget build(BuildContext context) {
    final reasons = ReportType.values;
    final targetWord = widget.controller.targetType == 'post' ? 'post' : 'usuário';

    return Column(
      children: [
        // Cabeçalho
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            children: [
              Text(
                'Por que você está '
                 'denunciando este $targetWord?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sua denúncia é anônima. '
                'Ninguém saberá quem a enviou.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        // Lista de motivos
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reasons.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final type = reasons[index];
              final label = reportTypeLabels[type] ?? type.name;
              return ListTile(
                title: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                onTap: () async {
                  widget.controller.selectType(type);
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ReportDescriptionView(controller: widget.controller),
                    ),
                  );
                  // Se voltou com sucesso, dispara o callback
                  if (result == true) {
                    widget.onReportSubmitted?.call();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}