import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String? selectedCategory;
  final String transactionType;
  final Function(String) onCategorySelected;

  const CategorySelectorWidget({
    Key? key,
    required this.selectedCategory,
    required this.transactionType,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Kategori',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 12.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: _getCategories().length + 1,
              itemBuilder: (context, index) {
                if (index == _getCategories().length) {
                  return _buildAddCategoryButton(context);
                }

                final category = _getCategories()[index];
                final isSelected = selectedCategory == category['name'];

                return _buildCategoryChip(category, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> category, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: () => onCategorySelected(category['name'] as String),
        child: Container(
          width: 20.w,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? (transactionType == 'income'
                    ? AppTheme.getSuccessColor(true).withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1))
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (transactionType == 'income'
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.lightTheme.colorScheme.error)
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (transactionType == 'income'
                          ? AppTheme.getSuccessColor(true)
                              .withValues(alpha: 0.2)
                          : AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.2))
                      : AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: category['icon'] as String,
                  color: isSelected
                      ? (transactionType == 'income'
                          ? AppTheme.getSuccessColor(true)
                          : AppTheme.lightTheme.colorScheme.error)
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                category['name'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? (transactionType == 'income'
                          ? AppTheme.getSuccessColor(true)
                          : AppTheme.lightTheme.colorScheme.error)
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: () => _showCategoryModal(context),
        child: Container(
          width: 20.w,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Tambah',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Pilih Kategori',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                ),
                itemCount: _getAllCategories().length,
                itemBuilder: (context, index) {
                  final category = _getAllCategories()[index];
                  return GestureDetector(
                    onTap: () {
                      onCategorySelected(category['name'] as String);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: AppTheme
                                  .lightTheme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: category['icon'] as String,
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 7.w,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            category['name'] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  List<Map<String, dynamic>> _getCategories() {
    if (transactionType == 'income') {
      return [
        {'name': 'Gaji', 'icon': 'work'},
        {'name': 'Bonus', 'icon': 'card_giftcard'},
        {'name': 'Investasi', 'icon': 'trending_up'},
        {'name': 'Freelance', 'icon': 'laptop'},
      ];
    } else {
      return [
        {'name': 'Makanan', 'icon': 'restaurant'},
        {'name': 'Transport', 'icon': 'directions_car'},
        {'name': 'Belanja', 'icon': 'shopping_cart'},
        {'name': 'Tagihan', 'icon': 'receipt'},
      ];
    }
  }

  List<Map<String, dynamic>> _getAllCategories() {
    if (transactionType == 'income') {
      return [
        {'name': 'Gaji', 'icon': 'work'},
        {'name': 'Bonus', 'icon': 'card_giftcard'},
        {'name': 'Investasi', 'icon': 'trending_up'},
        {'name': 'Freelance', 'icon': 'laptop'},
        {'name': 'Bisnis', 'icon': 'business'},
        {'name': 'Hadiah', 'icon': 'redeem'},
        {'name': 'Dividen', 'icon': 'account_balance'},
        {'name': 'Penjualan', 'icon': 'sell'},
        {'name': 'Lainnya', 'icon': 'more_horiz'},
      ];
    } else {
      return [
        {'name': 'Makanan', 'icon': 'restaurant'},
        {'name': 'Transport', 'icon': 'directions_car'},
        {'name': 'Belanja', 'icon': 'shopping_cart'},
        {'name': 'Tagihan', 'icon': 'receipt'},
        {'name': 'Kesehatan', 'icon': 'local_hospital'},
        {'name': 'Hiburan', 'icon': 'movie'},
        {'name': 'Pendidikan', 'icon': 'school'},
        {'name': 'Olahraga', 'icon': 'fitness_center'},
        {'name': 'Rumah', 'icon': 'home'},
        {'name': 'Pakaian', 'icon': 'checkroom'},
        {'name': 'Teknologi', 'icon': 'devices'},
        {'name': 'Lainnya', 'icon': 'more_horiz'},
      ];
    }
  }
}
