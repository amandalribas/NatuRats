import 'package:flutter/material.dart';
import 'package:naturats/components/group/group_header.dart';
import 'package:naturats/components/group/group_search_bar.dart';
import 'package:naturats/components/group/group_options_sheet.dart';
import 'package:naturats/components/group/group_card.dart';
import 'package:naturats/theme/app_colors.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const GroupOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,

      // ➕ BOTÃO FLUTUANTE
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        backgroundColor: AppColors.bgVerde,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GroupHeader(),

            const SizedBox(height: 15),

            const GroupSearchBar(),

            const SizedBox(height: 20),

            //exemplos

            const Group(
              id: "1",
              name: "Planeta em Ação",
              description:
                  "Pessoas que se unem para transformar pequenas atitudes em grandes mudanças para o planeta.",
              totalPeople: 1200,
              totalPoints: 34250,
              imageUrl: "https://static.todamateria.com.br/upload/ma/os/maosplantandoarvorespelosobjetivosdedesenvolvimentosustentaveldomeioambiente-cke.jpg",
            ),

            const Group(
              id: "2",
              name: "Protetores da Vida Animal",
              description:
                  "Grupo focado na defesa, cuidado e respeito aos animais em todas as formas.",
              totalPeople: 400,
              totalPoints: 1520,
              imageUrl: "https://www.cmc.mg.gov.br/wordpress/wp-content/uploads/2021/09/bem-estar-animal.jpg",
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}