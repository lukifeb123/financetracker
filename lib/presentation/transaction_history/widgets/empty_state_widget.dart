import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String type;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    Key? key,
    required this.type,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(),
            SizedBox(height: 4.h),
            Text(
              _getTitle(),
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              _getDescription(),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: CustomIconWidget(
                  iconName: _getActionIcon(),
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Text(_getActionText()),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: _getIllustrationIcon(),
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20.w,
        ),
      ),
    );
  }

  String _getIllustrationIcon() {
    switch (type) {
      case 'no_transactions':
        return 'receipt_long';
      case 'no_results':
        return 'search_off';
      case 'no_month_data':
        return 'event_busy';
      default:
        return 'inbox';
    }
  }

  String _getTitle() {
    switch (type) {
      case 'no_transactions':
        return 'Belum Ada Transaksi';
      case 'no_results':
        return 'Tidak Ada Hasil';
      case 'no_month_data':
        return 'Tidak Ada Transaksi Bulan Ini';
      default:
        return 'Tidak Ada Data';
    }
  }

  String _getDescription() {
    switch (type) {
      case 'no_transactions':
        return 'Mulai catat transaksi pertama Anda untuk melacak keuangan dengan lebih baik.';
      case 'no_results':
        return 'Tidak ditemukan transaksi yang sesuai dengan pencarian atau filter Anda. Coba ubah kriteria pencarian.';
      case 'no_month_data':
        return 'Belum ada transaksi yang tercatat untuk bulan ini. Mulai tambahkan transaksi baru.';
      default:
        return 'Tidak ada data yang tersedia saat ini.';
    }
  }

  String _getActionIcon() {
    switch (type) {
      case 'no_transactions':
      case 'no_month_data':
        return 'add';
      case 'no_results':
        return 'clear';
      default:
        return 'refresh';
    }
  }

  String _getActionText() {
    switch (type) {
      case 'no_transactions':
      case 'no_month_data':
        return 'Tambah Transaksi';
      case 'no_results':
        return 'Hapus Filter';
      default:
        return 'Muat Ulang';
    }
  }
}
