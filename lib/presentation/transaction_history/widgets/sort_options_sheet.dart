import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortOptionsSheet extends StatelessWidget {
  final String currentSortBy;
  final bool isAscending;
  final Function(String, bool) onSortChanged;

  const SortOptionsSheet({
    Key? key,
    required this.currentSortBy,
    required this.isAscending,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'key': 'date', 'label': 'Tanggal', 'icon': 'calendar_today'},
      {'key': 'amount', 'label': 'Jumlah', 'icon': 'attach_money'},
      {'key': 'category', 'label': 'Kategori', 'icon': 'category'},
      {'key': 'description', 'label': 'Deskripsi', 'icon': 'description'},
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 3.h),
          ...sortOptions.map((option) => _buildSortOption(
                context,
                option['key'] as String,
                option['label'] as String,
                option['icon'] as String,
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Urutkan Berdasarkan',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String key,
    String label,
    String iconName,
  ) {
    final isSelected = currentSortBy == key;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // Toggle ascending/descending if same option is selected
          onSortChanged(key, !isAscending);
        } else {
          // Select new option with default descending for date/amount, ascending for others
          final defaultAscending = key == 'category' || key == 'description';
          onSortChanged(key, defaultAscending);
        }
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected) ...[
              CustomIconWidget(
                iconName: isAscending ? 'arrow_upward' : 'arrow_downward',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                _getSortOrderText(key, isAscending),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSortOrderText(String sortBy, bool ascending) {
    switch (sortBy) {
      case 'date':
        return ascending ? 'Terlama' : 'Terbaru';
      case 'amount':
        return ascending ? 'Terendah' : 'Tertinggi';
      case 'category':
      case 'description':
        return ascending ? 'A-Z' : 'Z-A';
      default:
        return ascending ? 'Naik' : 'Turun';
    }
  }
}
