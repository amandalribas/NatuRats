// lib/widgets/feedback_form.dart
import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';
import 'star_rating.dart';

class FeedbackForm extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  final bool hasExistingFeedback; 
  final List<String> suggestions;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;
  final String? errorMessage;

  const FeedbackForm({
    super.key,
    required this.initialRating,
    required this.initialComment,
    required this.hasExistingFeedback,
    required this.suggestions,
    required this.onRatingChanged,
    required this.onCommentChanged,
    required this.onSubmit,
    this.onCancel,
    this.errorMessage,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void didUpdateWidget(covariant FeedbackForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialComment != oldWidget.initialComment) {
      _commentController.text = widget.initialComment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Conte-nos o que achou do Naturats!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.preto),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Estrelas
        const Text('Sua nota *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.preto)),
        const SizedBox(height: 12),
        StarRating(
          rating: widget.initialRating,
          interactive: true,
          onRatingChanged: widget.onRatingChanged,
        ),
        if (widget.errorMessage != null && widget.initialRating == 0.0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Selecione uma nota.',
                style: TextStyle(color: AppColors.vermelho, fontSize: 12),
                textAlign: TextAlign.center),
          ),
        const SizedBox(height: 24),

        // Comentário
        const Text('Deixe um comentário (opcional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.preto)),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          onChanged: widget.onCommentChanged,
          maxLines: 4,
          style: const TextStyle(color: AppColors.preto),
          decoration: InputDecoration(
            hintText: 'Escreva aqui sua opinião...',
            hintStyle: TextStyle(color: AppColors.textCinza),
            filled: true,
            fillColor: AppColors.branco,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderCinza)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.buttomVerde, width: 2)),
          ),
        ),
        const SizedBox(height: 16),

        // Sugestões (apenas se não houver feedback)
        if (!widget.hasExistingFeedback) ...[
          const Text('Sugestões:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.preto)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion,
                    style: const TextStyle(fontSize: 13, color: AppColors.preto)),
                backgroundColor: AppColors.boxVerde.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.buttomVerde.withOpacity(0.5))),
                onPressed: () {
                  _commentController.text = suggestion;
                  widget.onCommentChanged(suggestion);
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 32),

        // Botões
        Row(
          children: [
            if (widget.hasExistingFeedback)
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bgVerde,
                    side: const BorderSide(color: AppColors.bgVerde),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            if (widget.hasExistingFeedback) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onSubmit,
                icon: Icon(
                  widget.hasExistingFeedback ? Icons.update : Icons.send,
                  color: AppColors.branco,
                ),
                label: Text(widget.hasExistingFeedback ? 'Atualizar' : 'Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttomVerde,
                  foregroundColor: AppColors.branco,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        if (widget.errorMessage != null && widget.initialRating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(widget.errorMessage!,
                style: const TextStyle(color: AppColors.vermelho), textAlign: TextAlign.center),
          ),
      ],
    );
  }
}