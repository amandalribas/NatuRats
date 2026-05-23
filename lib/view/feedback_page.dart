// view/feedback_page.dart
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dar Feedback'),
      ),
      body: const Center(
        child: Text('Aqui você pode enviar seu feedback.'),
      ),
    );
  }
}