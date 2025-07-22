import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpenseIncomeChartWidget extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final List<Map<String, dynamic>> monthlyData;

  const ExpenseIncomeChartWidget({
    Key? key,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyData,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String formattedWhole = '';
    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        formattedWhole += '.';
      }
      formattedWhole += amountStr[i];
    }
    return 'Rp $formattedWhole';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pemasukan vs Pengeluaran',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18.sp)),
          SizedBox(height: 3.h),
          Row(children: [
            Expanded(
                child: _buildSummaryCard(context, 'Pemasukan', totalIncome,
                    AppTheme.successLight, 'trending_up')),
            SizedBox(width: 4.w),
            Expanded(
                child: _buildSummaryCard(context, 'Pengeluaran', totalExpense,
                    AppTheme.errorLight, 'trending_down')),
          ]),
          SizedBox(height: 4.h),
          SizedBox(
              height: 200,
              child: monthlyData.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          CustomIconWidget(
                              iconName: 'bar_chart',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 48),
                          SizedBox(height: 2.h),
                          Text('Belum ada data untuk ditampilkan',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ]))
                  : BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxValue() * 1.2,
                      barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final isIncome = rodIndex == 0;
                                final label =
                                    isIncome ? 'Pemasukan' : 'Pengeluaran';
                                return BarTooltipItem(
                                    '$label\n${_formatCurrency(rod.toY)}',
                                    theme.textTheme.bodySmall!.copyWith(
                                        color: theme
                                            .colorScheme.onInverseSurface));
                              })),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final weeks = [
                                      'Minggu 1',
                                      'Minggu 2',
                                      'Minggu 3',
                                      'Minggu 4'
                                    ];
                                    if (value.toInt() < weeks.length) {
                                      return Padding(
                                          padding: EdgeInsets.only(top: 1.h),
                                          child: Text(weeks[value.toInt()],
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(fontSize: 10.sp)));
                                    }
                                    return const SizedBox();
                                  })),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (value, meta) {
                                    return Text(_formatShortCurrency(value),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(fontSize: 10.sp));
                                  }))),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(),
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxValue() / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                                strokeWidth: 1);
                          })))),
          SizedBox(height: 2.h),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildLegendItem(context, AppTheme.successLight, 'Pemasukan'),
            SizedBox(width: 6.w),
            _buildLegendItem(context, AppTheme.errorLight, 'Pengeluaran'),
          ]),
        ]));
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount,
      Color color, String iconName) {
    final theme = Theme.of(context);

    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CustomIconWidget(iconName: iconName, color: color, size: 20),
            SizedBox(width: 2.w),
            Expanded(
                child: Text(title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp))),
          ]),
          SizedBox(height: 1.h),
          Text(_formatCurrency(amount),
              style: theme.textTheme.titleMedium?.copyWith(
                  color: color, fontWeight: FontWeight.w700, fontSize: 16.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]));
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      SizedBox(width: 2.w),
      Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp)),
    ]);
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(4, (index) {
      final weekData = index < monthlyData.length ? monthlyData[index] : null;
      final income = weekData?['income']?.toDouble() ?? 0.0;
      final expense = weekData?['expense']?.toDouble() ?? 0.0;

      return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
                toY: income,
                color: AppTheme.successLight,
                width: 4.w,
                borderRadius: BorderRadius.circular(2)),
            BarChartRodData(
                toY: expense,
                color: AppTheme.errorLight,
                width: 4.w,
                borderRadius: BorderRadius.circular(2)),
          ],
          barsSpace: 1.w);
    });
  }

  double _getMaxValue() {
    double maxValue = 0;
    for (final data in monthlyData) {
      final income = (data['income'] as num?)?.toDouble() ?? 0.0;
      final expense = (data['expense'] as num?)?.toDouble() ?? 0.0;
      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }
    return maxValue > 0 ? maxValue : 1000000;
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
