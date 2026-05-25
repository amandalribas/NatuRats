import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../model/group_activity.dart';

class ReportPostPage extends StatelessWidget {
  final String groupId;
  final GroupActivity activity;

  const ReportPostPage({
    super.key,
    required this.groupId,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        backgroundColor: AppColors.bgVerde,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.branco),
        title: const Text(
          'Fazer denúncia',
          style: TextStyle(
            color: AppColors.branco,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Aqui estará a lógica da denúncia',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}