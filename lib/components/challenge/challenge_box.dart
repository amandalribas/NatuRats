
import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/components/challenge/detail_challenge_box.dart';
import 'package:naturats/model/category_model.dart';
import 'package:naturats/model/sub_category_model.dart';
import 'package:naturats/theme/app_colors.dart';



class ChallengeBox extends StatelessWidget {
  final String title;
  final String descr;
  final CategoryModel category;
  final SubCategoryModel subcategory;
  final VoidCallback? onTap;

  const ChallengeBox({
    super.key,
    required this.title,
    required this.descr,
    required this.category,
    required this.subcategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 110,
      constraints: const BoxConstraints(minHeight: 120),
      width: double.infinity, // Ocupa a largura disponível
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.borderCinza.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap:
              onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  DetailChallengeBox(
                      title: title,
                      descr: descr,
                      category: category,
                      subcategory: subcategory,
                    ),
                  ),
                );
              },
          child: Padding(
            //padding: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  //margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 65,
                  width: 65,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: subcategory.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    subcategory.icon,
                    color: AppColors.preto,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.preto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descr,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.borderCinza,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          CategoryTag(category: category),
                          CategoryTag(category: subcategory),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
