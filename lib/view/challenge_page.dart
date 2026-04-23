import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/challenge_box.dart';
import 'package:naturats/components/challenge/challenge_header.dart';
import 'package:naturats/components/challenge/filter_box.dart';
import 'package:naturats/model/category_model.dart';
import 'package:naturats/model/sub_category_model.dart';
import 'package:naturats/theme/app_colors.dart';

// Página criada para testar o front-end

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCinza,
      body: SingleChildScrollView(
        //child: SizedBox(
        //width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChallengeHeader(),
            const FilterBox(),
            //const SizedBox(height: 5),
            const ChallengeBox(
              title: "Ajudando a natureza",
              descr:
                  "Dedique um minuto para regar ou cuidar de uma planta em casa ou no trabalho.",
              category: CategoryModel.diaria,
              subcategory: SubCategoryModel.biodiversidade,
            ),
            const ChallengeBox(
              title: "Economizar agua",
              descr:
                  "Participe de uma ação de limpeza de orla ou margem de rio.",
              category: CategoryModel.mensal,
              subcategory: SubCategoryModel.agua,
            ),
            const ChallengeBox(
              title: "Dia de Bicicleta",
              descr:
                  "Troque o transporte motorizado pela bicicleta em pelo menos um dia útil.",
              category: CategoryModel.semanal,
              subcategory: SubCategoryModel.mobilidade,
            ),
            const ChallengeBox(
              title: "Descarte Consciente",
              descr:
                  "Separe corretamente ao menos 3 itens recicláveis do lixo comum.",
              category: CategoryModel.diaria,
              subcategory: SubCategoryModel.residuos,
            ),
            const ChallengeBox(
              title: "Luz Natural",
              descr:
                  "Luz Natural: Mantenha as lâmpadas apagadas em ambientes com iluminação solar até às 17h.",
              category: CategoryModel.diaria,
              subcategory: SubCategoryModel.energia,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
