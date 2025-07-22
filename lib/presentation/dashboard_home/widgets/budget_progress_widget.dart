import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> budgets;
  final Function(Map<String, dynamic>) onBudgetTap;

  const BudgetProgressWidget({
    Key? key,
    required this.budgets,
    required this.onBudgetTap,
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

  Color _getBudgetStatusColor(double percentage) {
    if (percentage >= 90) {
      return AppTheme.errorLight;
    } else if (percentage >= 70) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  String _getBudgetStatusText(double percentage) {
    if (percentage >= 100) {
      return 'Melebihi anggaran';
    } else if (percentage >= 90) {
      return 'Hampir habis';
    } else if (percentage >= 70) {
      return 'Perlu perhatian';
    } else {
      return 'Aman';
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return 'restaurant';
      case 'transportasi':
        return 'directions_car';
      case 'belanja':
        return 'shopping_bag';
      case 'hiburan':
        return 'movie';
      case 'kesehatan':
        return 'local_hospital';
      case 'pendidikan':
        return 'school';
      case 'utilitas':
        return 'electrical_services';
      case 'lainnya':
        return 'category';
      default:
        return 'account_balance_wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Anggaran',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/analytics-dashboard'),
                child: Text(
                  'Detail',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          budgets.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'account_balance_wallet',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Belum ada anggaran',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Atur anggaran untuk memantau pengeluaran Anda',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: budgets.length > 3 ? 3 : budgets.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final category = budget['category'] as String;
                    final budgetAmount = budget['budgetAmount'] as double;
                    final spentAmount = budget['spentAmount'] as double;
                    final percentage =
                        (spentAmount / budgetAmount * 100).clamp(0.0, 100.0);
                    final remainingAmount = budgetAmount - spentAmount;

                    return GestureDetector(
                      onTap: () => onBudgetTap(budget),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: _getBudgetStatusColor(percentage)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: _getCategoryIcon(category),
                                    color: _getBudgetStatusColor(percentage),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      Text(
                                        _getBudgetStatusText(percentage),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color:
                                              _getBudgetStatusColor(percentage),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color:
                                            _getBudgetStatusColor(percentage),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    Text(
                                      remainingAmount >= 0
                                          ? 'Sisa ${_formatCurrency(remainingAmount)}'
                                          : 'Lebih ${_formatCurrency(remainingAmount.abs())}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Terpakai: ${_formatCurrency(spentAmount)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Text(
                                  'Anggaran: ${_formatCurrency(budgetAmount)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getBudgetStatusColor(percentage),
                              ),
                              minHeight: 1.h,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
