import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String desc;
  final String primaryButtonText;
  final Color primaryButtonColor;
  final VoidCallback onConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    required this.desc,
    required this.primaryButtonText,
    required this.primaryButtonColor,
    required this.onConfirm
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.branco,
      title: Text(title, textAlign: TextAlign.center),
      content: Text(desc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(230, 50),
                backgroundColor: primaryButtonColor,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(primaryButtonText, style: TextStyle(
                  color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              child: const Text("Fechar"),
            ),
          ],
        )
      ],
    );
  }
}