import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.bgVerde),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            Text(
              "Grupos",
              style: TextStyle(
                color: AppColors.branco,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              "Conecte-se com outros usuários.",
              style: TextStyle(
                color: AppColors.branco, fontSize: 16
                ),
            ),
          ],
        ),
      ),
    );
  }
}
