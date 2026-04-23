import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/model/category_model.dart';
import 'package:naturats/model/sub_category_model.dart';
import 'package:naturats/theme/app_colors.dart';

class DetailChallengeBox extends StatelessWidget {
  final String title;
  final String descr;
  final CategoryModel category;
  final SubCategoryModel subcategory;

  const DetailChallengeBox({
    super.key,
    required this.title,
    required this.descr,
    required this.category,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCinza,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.preto),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //cabecalho
            Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: subcategory.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    subcategory.icon,
                    size: 40,
                    color: AppColors.preto,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.preto,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ), // Aumentei um pouco o espaço para as tags
                      // --- TAGS DE CATEGORIA E SUB CATEGORIA ---
                      Row(
                        children: [
                          CategoryTag(category: category),
                          const SizedBox(width: 4), // Espaço entre as tags
                          CategoryTag(category: subcategory),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            //Divider(color: Colors.grey.withValues(alpha: 0.7)),
            Divider(color: AppColors.borderCinza, thickness: 1),
            const SizedBox(height: 24),
            // inserir maior descricao
            const Text(
              "Sobre o desafio",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.preto,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              descr,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const Spacer(),

            // botao adicionar
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    print("Clicou em adicionar desafio");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttomVerde,
                    foregroundColor: AppColors.branco,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Adicionar Desafio à biblioteca",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
