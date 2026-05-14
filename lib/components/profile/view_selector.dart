import 'package:flutter/material.dart';
import 'package:naturats/components/profile/history_view.dart';
import 'package:naturats/components/profile/medals_view.dart';
import 'package:naturats/components/profile/statistics_view.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'package:provider/provider.dart';

class ViewSelector extends StatelessWidget {
  const ViewSelector({super.key, required int selectedIndex})
      : _selectedIndex = selectedIndex;

  final int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context);
    final statistics = controller.getStatistics();
    
    return Expanded(
      child: () {
        switch (_selectedIndex) {
          case 0:
            return StatisticsView(
              co2: statistics['co2'] ?? 0,
              recycled: statistics['recycled'] ?? 0,
              water: statistics['water'] ?? 0,
              km: statistics['km'] ?? 0,
            );
          case 1:
            return MedalsView();
          default:
            return HistoryView();
        }
      } (),
    );
  }
}