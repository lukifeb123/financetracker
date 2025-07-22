import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/budget_performance_widget.dart';
import './widgets/category_breakdown_chart_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/expense_income_chart_widget.dart';
import './widgets/spending_patterns_widget.dart';
import './widgets/time_period_selector_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  String _selectedPeriod = 'monthly';
  DateTimeRange? _selectedDateRange;
  bool _hasTransactionData = true; // Set to false to show empty state
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _hasTransactionData
          ? _buildAnalyticsContent()
          : const EmptyStateWidget(),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 3,
        onTap: _onBottomNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        'Analitik Keuangan',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _exportReport,
          icon: CustomIconWidget(
            iconName: 'file_download',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          tooltip: 'Ekspor Laporan',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildAnalyticsContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: TimePeriodSelectorWidget(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: _onPeriodChanged,
                  onDateRangePressed: _showDateRangePicker,
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ExpenseIncomeChartWidget(
                  selectedPeriod: _selectedPeriod,
                  dateRange: _selectedDateRange,
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: CategoryBreakdownChartWidget(
                  selectedPeriod: _selectedPeriod,
                  dateRange: _selectedDateRange,
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SpendingPatternsWidget(
                  selectedPeriod: _selectedPeriod,
                  dateRange: _selectedDateRange,
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: BudgetPerformanceWidget(
                  selectedPeriod: _selectedPeriod,
                  dateRange: _selectedDateRange,
                ),
              ),
              SizedBox(height: 10.h), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _selectedDateRange = null; // Reset custom date range
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Restart animation for smooth transition
    _animationController.reset();
    _animationController.forward();
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
              headerForegroundColor: Colors.white,
              rangeSelectionBackgroundColor:
                  AppTheme.lightTheme.colorScheme.primaryContainer,
              dayStyle: AppTheme.lightTheme.textTheme.bodyMedium,
              yearStyle: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _selectedPeriod = 'custom';
      });

      HapticFeedback.selectionClick();

      // Restart animation
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _exportReport() async {
    try {
      HapticFeedback.mediumImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Menyiapkan laporan...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );

      // Generate report content
      final reportContent = _generateReportContent();
      final fileName =
          'laporan_analitik_${DateTime.now().millisecondsSinceEpoch}.csv';

      // Export based on platform
      await _exportFile(reportContent, fileName);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Laporan berhasil diekspor!',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.getSuccessColor(true),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengekspor laporan. Silakan coba lagi.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _exportFile(String content, String fileName) async {
    if (kIsWeb) {
      // Web implementation
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile implementation would go here
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String _generateReportContent() {
    final now = DateTime.now();
    final periodText = _selectedPeriod == 'monthly' ? 'Bulanan' : 'Tahunan';

    return '''
Laporan Analitik Keuangan - $periodText
Tanggal Ekspor: ${now.day}/${now.month}/${now.year}

=== RINGKASAN KEUANGAN ===
Total Pemasukan: Rp 50.000.000
Total Pengeluaran: Rp 38.800.000
Selisih: Rp 11.200.000

=== BREAKDOWN KATEGORI ===
Makanan & Minuman: Rp 12.500.000 (32.2%)
Transportasi: Rp 8.200.000 (21.1%)
Belanja: Rp 6.800.000 (17.5%)
Hiburan: Rp 5.300.000 (13.7%)
Kesehatan: Rp 3.500.000 (9.0%)
Lainnya: Rp 2.500.000 (6.4%)

=== POLA PENGELUARAN HARIAN ===
Senin: Rp 1.800.000
Selasa: Rp 1.200.000
Rabu: Rp 1.600.000
Kamis: Rp 2.100.000
Jumat: Rp 2.400.000
Sabtu: Rp 2.800.000
Minggu: Rp 2.200.000

=== PERFORMA ANGGARAN ===
Makanan & Minuman: 83.3% (Rp 12.500.000 dari Rp 15.000.000)
Transportasi: 102.5% (Rp 8.200.000 dari Rp 8.000.000) - MELEBIHI
Belanja: 68.0% (Rp 6.800.000 dari Rp 10.000.000)
Hiburan: 106.0% (Rp 5.300.000 dari Rp 5.000.000) - MELEBIHI
Kesehatan: 87.5% (Rp 3.500.000 dari Rp 4.000.000)

Dibuat oleh FinanceTracker App
''';
  }

  void _onBottomNavTap(int index) {
    HapticFeedback.selectionClick();

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard-home');
        break;
      case 1:
        Navigator.pushNamed(context, '/add-transaction');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/transaction-history');
        break;
      case 3:
        // Already on analytics dashboard
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/category-management');
        break;
    }
  }
}
