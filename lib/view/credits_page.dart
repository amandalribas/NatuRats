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
        iconTheme: const IconThemeData(color: AppColors.branco),
        title: const Text(
          "Créditos",
          style: TextStyle(
            color: AppColors.branco,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const Text(
              "NatuRats",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.bgVerde,
              ),
            ),
            const SizedBox(height: 20),

            // Card com a mensagem motivacional
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.branco,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone e saudação
                    Row(
                      children: [
                        const Text(
                          "🌿",
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "E aí, naturats!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bgVerde,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Texto principal
                    const Text(
                      "O objetivo deste aplicativo é ser o seu companheiro diário "
                      "na jornada por um planeta mais saudável. Seja num desafio "
                      "individual ou em grupo, cada ação sustentável que você registra "
                      "faz diferença, seja reduzindo CO₂, economizando água, reciclando, pedalando… "
                      "tudo conta!",
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Esperamos que você esteja curtindo a experiência e se sentindo "
                      "cada vez mais engajado(a). Se tiver ideias ou sugestões para "
                      "melhorarmos o app, ficaremos muito felizes em ouvir você. Seu "
                      "feedback é essencial, "
                      "cada crítica ou elogio nos ajuda a crescer.",
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Card dos desenvolvedores
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.bgVerde.withOpacity(0.3),
                ),
              ),
              color: AppColors.branco,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: AppColors.bgVerde),
                        const SizedBox(width: 8),
                        const Text(
                          "Desenvolvido por",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildDevName("Amanda Lemos Ribas"),
                    _buildDevName("Carina Alves de Lima Lanchine"),
                    _buildDevName("Isabella Direito Labre Martins"),
                    _buildDevName("João Vítor Luciano Gonçalves"),
                    _buildDevName("Luiza Canto Furley Schmidt"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para formatar cada nome com um ícone sutil
  Widget _buildDevName(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.bgVerde),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}