import 'package:flutter/material.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/view/finish_challenge_dialog.dart';
import 'package:naturats/main.dart';

class DialogUtils {
  /// Exibe o diálogo de finalização de desafio após o rebuild completo da UI,
  /// evitando a piscada preta.
  static void showFinishChallengeDialog(Challenge challenge) {
    // Aguarda o fim do rebuild para abrir o diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentState?.overlay?.context;
      if (context == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => FinishChallengeDialog(
          challenge: challenge,
          points: challenge.duration.points,
        ),
      );
    });
  }
}