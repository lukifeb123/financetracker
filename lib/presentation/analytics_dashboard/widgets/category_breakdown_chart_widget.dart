import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryBreakdownChartWidget extends StatefulWidget {
  final String selectedPeriod;
  final DateTimeRange? dateRange;

  const CategoryBreakdownChartWidget({
    super.key,
    required this.selectedPeriod,
    this.dateRange,
  });

  @override
  State<CategoryBreakdownChartWidget> createState() =>
      _CategoryBreakdownChartWidgetState();
}

class _CategoryBreakdownChartWidgetState
    extends State<CategoryBreakdownChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Breakdown Kategori',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: 'pie_chart',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 25.h,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 8.w,
                      sections: _buildPieChartSections(categoryData),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return _buildLegendItem(
                      category['name'] as String,
                      category['color'] as Color,
                      category['amount'] as double,
                      category['percentage'] as double,
                      index == touchedIndex,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pengeluaran:',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${_formatCurrency(_getTotalExpense())}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      List<Map<String, dynamic>> categoryData) {
    return categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 14.sp : 12.sp;
      final radius = isTouched ? 12.w : 10.w;

      return PieChartSectionData(
        color: category['color'] as Color,
        value: category['percentage'] as double,
        title: '${(category['percentage'] as double).toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? _buildBadge(category['name'] as String) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(String categoryName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        categoryName,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color, double amount,
      double percentage, bool isHighlighted) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color:
            isHighlighted ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight:
                        isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Rp ${_formatCurrency(amount)}',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCategoryData() {
    return [
      {
        'name': 'Makanan & Minuman',
        'amount': 12500000.0,
        'percentage': 32.2,
        'color': const Color(0xFF2E7D5A),
      },
      {
        'name': 'Transportasi',
        'amount': 8200000.0,
        'percentage': 21.1,
        'color': const Color(0xFFE67E22),
      },
      {
        'name': 'Belanja',
        'amount': 6800000.0,
        'percentage': 17.5,
        'color': const Color(0xFF9B59B6),
      },
      {
        'name': 'Hiburan',
        'amount': 5300000.0,
        'percentage': 13.7,
        'color': const Color(0xFF3498DB),
      },
      {
        'name': 'Kesehatan',
        'amount': 3500000.0,
        'percentage': 9.0,
        'color': const Color(0xFFE74C3C),
      },
      {
        'name': 'Lainnya',
        'amount': 2500000.0,
        'percentage': 6.4,
        'color': const Color(0xFF95A5A6),
      },
    ];
  }

  double _getTotalExpense() {
    return _getCategoryData()
        .fold(0.0, (sum, category) => sum + (category['amount'] as double));
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
