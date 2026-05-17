import 'package:flutter/material.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'package:naturats/model/medal.dart';
import 'package:naturats/theme/app_colors.dart';
import 'medal_card.dart';

class MedalsView extends StatelessWidget {
  const MedalsView({super.key});

  Color _getMedalColor(BuildContext context, String type) {
    switch (type) {
      case 'water':
        return AppColors.agua;
      case 'recycle':
        return AppColors.residuos;
      case 'energy':
        return AppColors.energia;
      case 'mobility':
        return AppColors.mobilidade;
      case 'consistency':
        return AppColors.consistencia;
      default:
        return AppColors.prata;
    }
  }


  @override
  Widget build(BuildContext context) {
    final controller = ProfileController(context);
    
    return StreamBuilder<List<Medal>>(
      // Presumindo que o seu controller vai retornar o Stream do Service do Firebase
      stream: controller.getMedalsStream(), 
      builder: (context, snapshot) {
        
        // 1. Tratamento de Erro
        if (snapshot.hasError) {
          print("ERRO DO FIREBASE NO NATURATS: ${snapshot.error}");
          return const Center(
            child: Text('Erro ao carregar suas medalhas.'),
          );
        }

        // 2. Estado de Carregamento (enquanto o Firebase não responde)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final medals = snapshot.data ?? [];

        // 3. Caso o banco esteja vazio
        if (medals.isEmpty) {
          return const Center(
            child: Text('Nenhuma medalha encontrada.'),
          );
        }

        // 4. Renderização do Grid com os dados reais
        return GridView.builder(
          padding: const EdgeInsets.all(4.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.85, // Adicionado para dar mais espaço vertical ao texto do card
          ),
          itemCount: medals.length,
          itemBuilder: (context, index) {
            final medal = medals[index];
            
            return MedalCard(
              medal: medal,
              // Agora a cor muda dinamicamente dependendo do tipo da medalha!
              color: _getMedalColor(context, medal.type), 
            );
          },
        );
      },
    );
  }
}    
    /*final medals = controller.getMedals();

    return GridView.builder(
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: medals.length,
      itemBuilder: (context, index) {
        final medal = medals[index];
        return MedalCard(
          medal: medal,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );*/

