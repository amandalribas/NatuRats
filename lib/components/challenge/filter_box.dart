import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/filter_category.dart';
import 'package:naturats/model/challenge_duration.dart';
import 'package:naturats/model/challenge_type.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../controller/challenges_controller.dart';

class FilterBox extends StatefulWidget {
  const FilterBox({super.key});

  @override
  State<StatefulWidget> createState() => _FilterBoxState();
}

class _FilterBoxState extends State<FilterBox> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChallengesController>();
    double width = (MediaQuery.of(context).size.width - 48) / 3;

    return Padding(
      padding: _isExpanded ? const EdgeInsets.fromLTRB(16, 16, 16, 16)
                          : const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                ...ChallengeDuration.values.map(
                  (c) => SizedBox(
                    width: width,
                    child: FilterCategory(
                      category: c,
                      isSelected: controller.selectedDurations.contains(c),
                      onTap: () {
                        controller.toggleDurationFilter(c);
                      },
                    ),
                  ),
                ),
                ...ChallengeType.values.map(
                  (s) => SizedBox(
                    width: width,
                    child: FilterCategory(
                      category: s,
                      isSelected: controller.selectedTypes.contains(s),
                      onTap: () {
                        controller.toggleTypeFilter(s);
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
