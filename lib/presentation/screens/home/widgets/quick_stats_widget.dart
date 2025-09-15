// lib/presentation/screens/home/widgets/quick_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';

class QuickStatsWidget extends StatefulWidget {
  final int completedTrips;
  final int savedPaths;
  final int achievements;

  const QuickStatsWidget({
    super.key,
    required this.completedTrips,
    required this.savedPaths,
    required this.achievements,
  });

  @override
  State<QuickStatsWidget> createState() => _QuickStatsWidgetState();
}

class _QuickStatsWidgetState extends State<QuickStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائياتك',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // الإحصائيات الرئيسية
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'رحلات مكتملة',
                  value: widget.completedTrips.toString(),
                  icon: PhosphorIcons.check_circle_fill,
                  color: AppColors.success,
                  index: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'مسارات محفوظة',
                  value: widget.savedPaths.toString(),
                  icon: PhosphorIcons.bookmark_simple_fill,
                  color: AppColors.primary,
                  index: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'إنجازات',
                  value: widget.achievements.toString(),
                  icon: PhosphorIcons.trophy_fill,
                  color: Colors.amber,
                  index: 2,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // جراف التقدم الأسبوعي
          _buildWeeklyProgressChart(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = Curves.easeOut.transform(
          (_animation.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
        );
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgressChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIcons.chart_line,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'نشاطك هذا الأسبوع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.trend_up,
                      color: AppColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+15%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['س', 'أ', 'ث', 'أ', 'خ', 'ج', 'س'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 1 * _animation.value),
                          FlSpot(1, 3 * _animation.value),
                          FlSpot(2, 2 * _animation.value),
                          FlSpot(3, 5 * _animation.value),
                          FlSpot(4, 3 * _animation.value),
                          FlSpot(5, 4 * _animation.value),
                          FlSpot(6, 6 * _animation.value),
                        ],
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
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem('مسارات مكتملة', AppColors.primary),
              const SizedBox(width: 16),
              _buildLegendItem('متوسط الأسبوع: 3.4', AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}