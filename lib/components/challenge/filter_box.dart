import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/filter_category.dart';
import 'package:naturats/model/category_model.dart';
import 'package:naturats/model/sub_category_model.dart';
import 'package:naturats/theme/app_colors.dart';

class FilterBox extends StatefulWidget {
  const FilterBox({super.key});

  @override
  State<StatefulWidget> createState() => _FilterBoxState();
}

class _FilterBoxState extends State<FilterBox> {
  bool _isExpanded = false;

  CategoryModel? _selectedCategory;
  SubCategoryModel? _selectedSubCategory;

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 48) / 3;

    return Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filtros",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textCinza,
                  ),
                ),
                const SizedBox(width: 4),
                // Ícone que muda de acordo com o estado
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...CategoryModel.values.map(
                  (c) => SizedBox(
                    width: width,
                    child: FilterCategory(
                      category: c,
                      isSelected: _selectedCategory == c,
                      onTap: () => {
                        setState(() {
                          _selectedCategory = (_selectedCategory == c)
                              ? null
                              : c;
                        }),
                      },
                    ),
                  ),
                ),
                ...SubCategoryModel.values.map(
                  (s) => SizedBox(
                    width: width,
                    child: FilterCategory(
                      category: s,
                      isSelected: _selectedSubCategory == s,
                      onTap: () => {
                        setState(() {
                          _selectedSubCategory = (_selectedSubCategory == s)
                              ? null
                              : s;
                        }),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
