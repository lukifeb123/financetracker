import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TopCategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic>) onCategoryTap;

  const TopCategoriesWidget({
    Key? key,
    required this.categories,
    required this.onCategoryTap,
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.blue;
      case 'belanja':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'kesehatan':
        return Colors.red;
      case 'pendidikan':
        return Colors.green;
      case 'utilitas':
        return Colors.brown;
      case 'lainnya':
        return Colors.grey;
      default:
        return Colors.grey;
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
        return 'category';
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
                'Kategori Teratas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/category-management'),
                child: Text(
                  'Kelola',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          categories.isEmpty
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
                        iconName: 'pie_chart',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Belum ada data kategori',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Mulai tambahkan transaksi untuk melihat kategori teratas',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 25.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    itemCount: categories.length > 5 ? 5 : categories.length,
                    separatorBuilder: (context, index) => SizedBox(width: 3.w),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final name = category['name'] as String;
                      final amount = category['amount'] as double;
                      final percentage = category['percentage'] as double;
                      final transactionCount =
                          category['transactionCount'] as int;

                      return GestureDetector(
                        onTap: () => onCategoryTap(category),
                        child: Container(
                          width: 40.w,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.shadowColor.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(name)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: _getCategoryIcon(name),
                                      color: _getCategoryColor(name),
                                      size: 24,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 1.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(name)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: _getCategoryColor(name),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                _formatCurrency(amount),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _getCategoryColor(name),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'receipt',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '$transactionCount transaksi',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getCategoryColor(name),
                                ),
                                minHeight: 0.5.h,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
