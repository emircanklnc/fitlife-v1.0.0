import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/date_helpers.dart';

class WeightChart extends StatelessWidget {
  final List<WeightEntry> weightHistory;
  final double? targetWeight;

  const WeightChart({
    Key? key,
    required this.weightHistory,
    this.targetWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weightHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kilo verisi yok',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Kilo eklemek için + butonuna tıklayın',
              style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Tarih sırasına göre sırala (en eski -> en yeni)
    final sortedHistory = List<WeightEntry>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Eğer sıralama sonrası liste boşsa veya tek eleman varsa
    if (sortedHistory.isEmpty || sortedHistory.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Grafik için en az 2 kilo kaydı gerekli',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          _getChartData(sortedHistory),
        ),
      ),
    );
  }

  LineChartData _getChartData(List<WeightEntry> sortedHistory) {
    final spots = sortedHistory
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.weight,
            ))
        .toList();

    // Min ve max kilo hesapla (hedef kilo dahil)
    double minWeight = sortedHistory
        .map((e) => e.weight)
        .reduce((a, b) => a < b ? a : b);
    double maxWeight = sortedHistory
        .map((e) => e.weight)
        .reduce((a, b) => a > b ? a : b);
    
    // Hedef kilo varsa, min/max'e dahil et
    if (targetWeight != null) {
      if (targetWeight! < minWeight) minWeight = targetWeight!;
      if (targetWeight! > maxWeight) maxWeight = targetWeight!;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.grey300,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}kg',
                style: AppTextStyles.small,
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < sortedHistory.length) {
                final entry = sortedHistory[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateHelpers.formatDateChart(entry.date),
                    style: AppTextStyles.small,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (sortedHistory.length - 1).toDouble(),
      minY: minWeight - 2,
      maxY: maxWeight + 2,
      lineBarsData: [
        // Ana kilo grafiği
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        // Hedef kilo çizgisi (son eklenen kilo) - Kesikli çizgi
        if (targetWeight != null)
          LineChartBarData(
            spots: [
              FlSpot(0, targetWeight!),
              FlSpot((sortedHistory.length - 1).toDouble(), targetWeight!),
            ],
            isCurved: false,
            color: AppColors.secondary.withOpacity(0.7),
            barWidth: 2,
            isStrokeCapRound: false,
            dotData: FlDotData(show: false),
            // fl_chart'ta dashArray yok, bu yüzden renk ve opacity ile vurguluyoruz
          ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: AppColors.textPrimary,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              if (spot.x.toInt() >= 0 && spot.x.toInt() < sortedHistory.length) {
                final entry = sortedHistory[spot.x.toInt()];
                return LineTooltipItem(
                  '${entry.weight.toStringAsFixed(1)} kg\n${DateHelpers.formatDate(entry.date)}',
                  AppTextStyles.small.copyWith(color: Colors.white),
                );
              }
              return LineTooltipItem('', AppTextStyles.small.copyWith(color: Colors.white));
            }).toList();
          },
        ),
      ),
    );
  }
}

