import 'package:flutter/material.dart';
import 'package:naturats/components/feedbacks/feedback_card.dart';
import 'package:naturats/components/feedbacks/feedback_form.dart';
import 'package:naturats/controller/feedback_controller.dart';
import '../theme/app_colors.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final FeedbackController _controller;

  final List<String> _suggestions = [
    'Interface intuitiva e bonita!',
    'As metas diárias são muito motivadoras.',
    'Sinto falta de mais categorias.',
    'Adorei o sistema de pontos!',
    'O design é moderno e fácil de usar.',
  ];

  @override
  void initState() {
    super.initState();
    _controller = FeedbackController();
    _controller.loadFeedback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitAndNotify() async {
    final ok = await _controller.submitFeedback();
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.hasFeedback ? 'Feedback atualizado!' : 'Feedback enviado!',
          ),
          backgroundColor: AppColors.bgVerde,
        ),
      );
    }
  }

  Future<void> _deleteAndNotify() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir feedback'),
        content: const Text('Tem certeza que deseja excluir seu feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.vermelho)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _controller.deleteFeedback();
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback excluído.'),
            backgroundColor: AppColors.vermelho,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,   // Fundo branco uniforme
      appBar: AppBar(
        backgroundColor: AppColors.bgVerde,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.branco),
        title: const Text('Dar Feedback',
            style: TextStyle(
                color: AppColors.branco,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.bgVerde),
            );
          }

          final showCard = _controller.hasFeedback && !_controller.isEditingForm;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: showCard
                  ? FeedbackCard(
                      feedback: _controller.existingFeedback!,
                      onEdit: _controller.startEditing,
                      onDelete: _deleteAndNotify,
                    )
                  : Padding(   // Sem Card – formulário integrado ao fundo
                      padding: const EdgeInsets.all(20),
                      child: FeedbackForm(
                        initialRating: _controller.rating,
                        initialComment: _controller.commentText,
                        hasExistingFeedback: _controller.hasFeedback,
                        suggestions: _suggestions,
                        onRatingChanged: _controller.setRating,
                        onCommentChanged: _controller.setComment,
                        onSubmit: _submitAndNotify,
                        onCancel: _controller.hasFeedback ? _controller.cancelEditing : null,
                        errorMessage: _controller.errorMessage,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}