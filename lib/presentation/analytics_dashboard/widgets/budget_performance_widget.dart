import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetPerformanceWidget extends StatelessWidget {
  final String selectedPeriod;
  final DateTimeRange? dateRange;

  const BudgetPerformanceWidget({
    super.key,
    required this.selectedPeriod,
    this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final budgetData = _getBudgetData();

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
                'Performa Anggaran',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...budgetData.map((budget) => _buildBudgetItem(budget)).toList(),
          SizedBox(height: 2.h),
          _buildOverallSummary(budgetData),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(Map<String, dynamic> budget) {
    final category = budget['category'] as String;
    final budgetAmount = budget['budget'] as double;
    final spentAmount = budget['spent'] as double;
    final percentage = (spentAmount / budgetAmount * 100).clamp(0.0, 100.0);
    final status = _getBudgetStatus(percentage);

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: status['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status['label'],
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: status['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_formatCurrency(spentAmount)}',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: status['color'],
                ),
              ),
              Text(
                'dari Rp ${_formatCurrency(budgetAmount)}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 8,
                width: percentage / 100 * 100.w - 8.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      status['color'],
                      status['color'].withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% terpakai',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Sisa: Rp ${_formatCurrency(budgetAmount - spentAmount)}',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: spentAmount > budgetAmount
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.getSuccessColor(true),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallSummary(List<Map<String, dynamic>> budgetData) {
    final totalBudget =
        budgetData.fold(0.0, (sum, item) => sum + (item['budget'] as double));
    final totalSpent =
        budgetData.fold(0.0, (sum, item) => sum + (item['spent'] as double));
    final overallPercentage =
        (totalSpent / totalBudget * 100).clamp(0.0, 100.0);
    final status = _getBudgetStatus(overallPercentage);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status['color'].withValues(alpha: 0.1),
            status['color'].withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status['color'].withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Anggaran Bulan Ini',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: status['icon'],
                color: status['color'],
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terpakai',
                    style: AppTheme.lightTheme.textTheme.labelMedium,
                  ),
                  Text(
                    'Rp ${_formatCurrency(totalSpent)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: status['color'],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Anggaran',
                    style: AppTheme.lightTheme.textTheme.labelMedium,
                  ),
                  Text(
                    'Rp ${_formatCurrency(totalBudget)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: status['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${overallPercentage.toStringAsFixed(1)}% dari total anggaran telah digunakan',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: status['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getBudgetStatus(double percentage) {
    if (percentage <= 70) {
      return {
        'label': 'Aman',
        'color': AppTheme.getSuccessColor(true),
        'icon': 'check_circle',
      };
    } else if (percentage <= 90) {
      return {
        'label': 'Hati-hati',
        'color': AppTheme.getWarningColor(true),
        'icon': 'warning',
      };
    } else {
      return {
        'label': 'Melebihi',
        'color': AppTheme.lightTheme.colorScheme.error,
        'icon': 'error',
      };
    }
  }

  List<Map<String, dynamic>> _getBudgetData() {
    return [
      {
        'category': 'Makanan & Minuman',
        'budget': 15000000.0,
        'spent': 12500000.0,
      },
      {
        'category': 'Transportasi',
        'budget': 8000000.0,
        'spent': 8200000.0,
      },
      {
        'category': 'Belanja',
        'budget': 10000000.0,
        'spent': 6800000.0,
      },
      {
        'category': 'Hiburan',
        'budget': 5000000.0,
        'spent': 5300000.0,
      },
      {
        'category': 'Kesehatan',
        'budget': 4000000.0,
        'spent': 3500000.0,
      },
    ];
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
