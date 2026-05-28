
import 'package:flutter/material.dart';
import '../controller/report_controller.dart';
import '../model/report.dart';
import '../theme/app_colors.dart';

class ReportDescriptionView extends StatefulWidget {
  final ReportController controller;

  const ReportDescriptionView({super.key, required this.controller});

  @override
  State<ReportDescriptionView> createState() => _ReportDescriptionViewState();
}

class _ReportDescriptionViewState extends State<ReportDescriptionView> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.controller.description);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    widget.controller.updateDescription(_textController.text);
    final success = await widget.controller.submitReport();

    if (!mounted) return;

    if (success) {
      // Volta para a tela de seleção de motivo informando sucesso
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel =
        reportTypeLabels[widget.controller.selectedType] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.bgVerde,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Denunciar: $typeLabel',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrução
            Text(
              'Descreva melhor o ocorrido:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 12),
            // Campo de texto estilizado
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Escreva aqui os detalhes...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.bgVerde, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            if (widget.controller.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  widget.controller.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            const SizedBox(height: 24),
            // Botão de envio
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                return SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vermelho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: widget.controller.isLoading ? null : _submit,
                    child: widget.controller.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Enviar denúncia',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}