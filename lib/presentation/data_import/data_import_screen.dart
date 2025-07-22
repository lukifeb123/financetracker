import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/import_service.dart';
import './widgets/file_upload_widget.dart';
import './widgets/import_instructions_widget.dart';
import './widgets/import_preview_widget.dart';

class DataImportScreen extends StatefulWidget {
  const DataImportScreen({Key? key}) : super(key: key);

  @override
  State<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends State<DataImportScreen> {
  final ImportService _importService = ImportService();

  List<Map<String, dynamic>> _importedTransactions = [];
  bool _isLoading = false;
  bool _showPreview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _showPreview ? _buildBottomActions() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      title: Text(
        'Import Data',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _downloadTemplate,
          child: Text(
            'Template',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Memproses file...',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (_showPreview && _importedTransactions.isNotEmpty) {
      return ImportPreviewWidget(
        transactions: _importedTransactions,
        onTransactionToggle: _toggleTransaction,
        onEditTransaction: _editTransaction,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImportInstructionsWidget(),
          SizedBox(height: 4.h),
          FileUploadWidget(
            onFileSelected: _handleFileImport,
          ),
          if (_importedTransactions.isNotEmpty) ...[
            SizedBox(height: 4.h),
            _buildImportSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildImportSummary() {
    final totalAmount = _importedTransactions
        .where((t) => t['selected'] == true)
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    final selectedCount =
        _importedTransactions.where((t) => t['selected'] == true).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.getSuccessColor(true),
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'File berhasil diproses',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                    'Transaksi dipilih',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$selectedCount dari ${_importedTransactions.length}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total nilai',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(totalAmount)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _showPreview = true),
              child: Text('Lihat Preview'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final selectedCount =
        _importedTransactions.where((t) => t['selected'] == true).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _showPreview = false),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text('Kembali'),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed:
                    selectedCount > 0 ? _importSelectedTransactions : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  backgroundColor: selectedCount > 0
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                ),
                child: Text(
                  'Import $selectedCount Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFileImport() async {
    setState(() => _isLoading = true);

    try {
      final transactions = await _importService.importFromFile();

      // Mark all transactions as selected by default
      for (final transaction in transactions) {
        transaction['selected'] = true;
      }

      setState(() {
        _importedTransactions = transactions;
        _isLoading = false;
      });

      if (transactions.isEmpty) {
        _showErrorMessage('Tidak ada data transaksi yang ditemukan dalam file');
      } else {
        HapticFeedback.mediumImpact();
        _showSuccessMessage('${transactions.length} transaksi berhasil dimuat');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage(e.toString());
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      await _importService.exportTemplate();
      _showSuccessMessage('Template berhasil diunduh');
    } catch (e) {
      _showErrorMessage('Gagal mengunduh template');
    }
  }

  void _toggleTransaction(int index) {
    setState(() {
      _importedTransactions[index]['selected'] =
          !(_importedTransactions[index]['selected'] ?? false);
    });
  }

  void _editTransaction(int index, Map<String, dynamic> updatedTransaction) {
    setState(() {
      _importedTransactions[index] = {
        ..._importedTransactions[index],
        ...updatedTransaction
      };
    });
  }

  Future<void> _importSelectedTransactions() async {
    final selectedTransactions =
        _importedTransactions.where((t) => t['selected'] == true).toList();

    if (selectedTransactions.isEmpty) {
      _showErrorMessage('Pilih minimal satu transaksi untuk diimpor');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate saving to local database
      await Future.delayed(Duration(milliseconds: 1500));

      HapticFeedback.heavyImpact();
      _showSuccessMessage(
          '${selectedTransactions.length} transaksi berhasil diimpor');

      // Navigate back to dashboard
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacementNamed(context, '/dashboard-home');
    } catch (e) {
      _showErrorMessage('Gagal mengimpor transaksi');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.getSuccessColor(true),
      textColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: Colors.white,
    );
  }
}
