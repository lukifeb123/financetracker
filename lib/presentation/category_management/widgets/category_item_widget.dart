import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryItemWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSetBudget;
  final VoidCallback? onDelete;
  final VoidCallback? onViewTransactions;
  final bool isExpanded;

  const CategoryItemWidget({
    super.key,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onSetBudget,
    this.onDelete,
    this.onViewTransactions,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String categoryName = category['name'] as String? ?? '';
    final String categoryIcon = category['icon'] as String? ?? 'category';
    final int transactionCount = category['transactionCount'] as int? ?? 0;
    final double totalAmount = category['totalAmount'] as double? ?? 0.0;
    final String categoryType = category['type'] as String? ?? 'expense';
    final List<dynamic> subcategories =
        category['subcategories'] as List<dynamic>? ?? [];
    final Color categoryColor =
        Color(category['color'] as int? ?? (isDark ? 0xFF4A90E2 : 0xFF1B365D));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMainCategoryItem(context, isDark, categoryName, categoryIcon,
              transactionCount, totalAmount, categoryType, categoryColor),
          if (isExpanded && subcategories.isNotEmpty)
            _buildSubcategories(context, isDark, subcategories),
        ],
      ),
    );
  }

  Widget _buildMainCategoryItem(
    BuildContext context,
    bool isDark,
    String categoryName,
    String categoryIcon,
    int transactionCount,
    double totalAmount,
    String categoryType,
    Color categoryColor,
  ) {
    return Dismissible(
      key: Key('category_${category['id']}'),
      background: _buildSwipeBackground(context, isDark, true),
      secondaryBackground: _buildSwipeBackground(context, isDark, false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
        } else if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: categoryIcon,
                    color: categoryColor,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '$transactionCount transaksi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(totalAmount),
                    style: AppTheme.getDataTextStyle(
                      isLight: !isDark,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
                      color: categoryType == 'income'
                          ? AppTheme.getSuccessColor(!isDark)
                          : AppTheme.errorLight,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  CustomIconWidget(
                    iconName: isExpanded
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    size: 5.w,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isDark, bool isLeft) {
    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.getSuccessColor(!isDark).withValues(alpha: 0.1)
            : AppTheme.errorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isLeft ? 'edit' : 'delete',
            color: isLeft
                ? AppTheme.getSuccessColor(!isDark)
                : AppTheme.errorLight,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            isLeft ? 'Edit' : 'Hapus',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isLeft
                      ? AppTheme.getSuccessColor(!isDark)
                      : AppTheme.errorLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategories(
      BuildContext context, bool isDark, List<dynamic> subcategories) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: (subcategories).map<Widget>((subcategory) {
          final subMap = subcategory as Map<String, dynamic>;
          final String subName = subMap['name'] as String? ?? '';
          final String subIcon =
              subMap['icon'] as String? ?? 'subdirectory_arrow_right';
          final int subTransactionCount =
              subMap['transactionCount'] as int? ?? 0;
          final double subTotalAmount = subMap['totalAmount'] as double? ?? 0.0;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                SizedBox(width: 4.w),
                CustomIconWidget(
                  iconName: subIcon,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subTransactionCount > 0)
                        Text(
                          '$subTransactionCount transaksi',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                        ),
                    ],
                  ),
                ),
                if (subTotalAmount > 0)
                  Text(
                    _formatCurrency(subTotalAmount),
                    style: AppTheme.getDataTextStyle(
                      isLight: !isDark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ).copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(context, 'edit', 'Edit Kategori', onEdit),
            _buildContextMenuItem(
                context, 'content_copy', 'Duplikat', onDuplicate),
            _buildContextMenuItem(context, 'account_balance_wallet',
                'Atur Anggaran', onSetBudget),
            _buildContextMenuItem(
                context, 'list', 'Lihat Transaksi', onViewTransactions),
            _buildContextMenuItem(context, 'delete', 'Hapus Kategori', onDelete,
                isDestructive: true),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String iconName,
    String title,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isDestructive
                  ? AppTheme.errorLight
                  : (isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight),
              size: 6.w,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDestructive
                        ? AppTheme.errorLight
                        : (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';

    String formattedAmount = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;

    for (int i = formattedAmount.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = '.$result';
        counter = 0;
      }
      result = formattedAmount[i] + result;
      counter++;
    }

    return 'Rp $result';
  }
}
