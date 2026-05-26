import 'package:flutter/material.dart';
import 'package:naturats/components/profile/history_view.dart';
import 'package:naturats/components/profile/medals_view.dart';
import 'package:naturats/components/profile/statistics_view.dart';
import 'package:naturats/components/profile/weekly_points_chart.dart';
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

    if (_selectedIndex == 0) {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StatisticsView(
                co2: statistics['CO2'] ?? 0,
                recycled: statistics['recycled'] ?? 0,
                water: statistics['water'] ?? 0,
                km: statistics['km'] ?? 0,
              ),
              FutureBuilder<List<int>>(
                future: controller.getWeeklyPoints(),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? List.filled(7, 0);
                  return WeeklyPointsChart(pointsPerDay: data);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: () {
        switch (_selectedIndex) {
          case 1:
            return MedalsView();
          default:
            return HistoryView(
              completedChallenges: controller.getCompletedChallenges(),
            );
        }
      }(),
    );
  }
}
