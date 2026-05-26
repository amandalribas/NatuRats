import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class WeeklyPointsChart extends StatelessWidget {
  /// Lista com os pontos de cada dia: índice 0 = 6 dias atrás, índice 6 = hoje
  final List<int> pointsPerDay;

  const WeeklyPointsChart({super.key, required this.pointsPerDay});

  static const _days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  List<String> get _labels {
    final today = DateTime.now().weekday % 7; // 0=Dom … 6=Sáb
    const labels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return List.generate(7, (i) {
      final dayIndex = (today - 6 + i + 7) % 7;
      return labels[dayIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxY =
        (pointsPerDay.isEmpty
                ? 10
                : pointsPerDay.reduce((a, b) => a > b ? a : b))
            .toDouble();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.bgVerde,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Pontos esta semana',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${pointsPerDay.fold(0, (a, b) => a + b)} pts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bgVerde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 10 : maxY * 1.3,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY == 0 ? 5 : maxY / 2,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        final isToday = idx == 6;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _labels[idx],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isToday
                                  ? AppColors.bgVerde
                                  : Colors.grey.shade500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final pts = pointsPerDay[i].toDouble();
                  final isToday = i == 6;
                  final isEmpty = pts == 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: isEmpty ? 0.5 : pts, // barra mínima visual
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        color: isEmpty
                            ? Colors.grey.shade200
                            : isToday
                            ? AppColors.bgVerde
                            : AppColors.bgVerde.withOpacity(0.45),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) {
                      final pts = pointsPerDay[group.x];
                      if (pts == 0) return null;
                      return BarTooltipItem(
                        '$pts pts',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
