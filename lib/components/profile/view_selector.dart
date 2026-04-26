import 'package:flutter/material.dart';
import 'package:naturats/components/profile/history_view.dart';
import 'package:naturats/components/profile/medals_view.dart';
import 'package:naturats/components/profile/statistics_view.dart';

class ViewSelector extends StatelessWidget {
  const ViewSelector({super.key, required int selectedIndex})
      : _selectedIndex = selectedIndex;

  final int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: () {
        switch (_selectedIndex) {
          case 0:
            return StatisticsView();
          case 1:
            return MedalsView();
          default:
            return HistoryView();
        }
      } (),
    );
  }
}