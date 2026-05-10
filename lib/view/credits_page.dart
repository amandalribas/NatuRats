import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        backgroundColor: AppColors.bgVerde,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.branco,
        ),
        title: const Text(
          "Créditos",
          style: TextStyle(
            color: AppColors.branco,
            fontWeight: FontWeight.bold,
          ),
        ),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NatuRats",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Desenvolvido por",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text("• Amanda Lemos Ribas"),
            const Text("• Carina Alves de Lima Lanchine"),
            const Text("• Isabella Direito Labre Martins"),
            const Text("• João Vítor Luciano Gonçalves"),
            const Text("• Luiza Canto Furley Schmidt"),


          
          ],
        ),
      ),
    );
  }
}