import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/receipt_camera_widget.dart';
import './widgets/transaction_type_toggle.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // Form controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form state
  String _transactionType = 'expense';
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  XFile? _receiptImage;

  // Advanced options state
  bool _isRecurring = false;
  String _recurringFrequency = 'Bulanan';
  String? _selectedBudget;
  List<String> _tags = [];

  // Form validation
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => _showCancelDialog(),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      title: Text(
        'Tambah Transaksi',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_isDraftSaveable())
          TextButton(
            onPressed: _saveDraft,
            child: Text(
              'Draft',
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          TransactionTypeToggle(
            selectedType: _transactionType,
            onTypeChanged: (type) {
              setState(() {
                _transactionType = type;
                _selectedCategory = null; // Reset category when type changes
              });
              HapticFeedback.lightImpact();
            },
          ),
          AmountInputWidget(
            controller: _amountController,
            transactionType: _transactionType,
            onAmountChanged: (amount) {
              setState(() {});
              _validateAmount(amount);
            },
          ),
          CategorySelectorWidget(
            selectedCategory: _selectedCategory,
            transactionType: _transactionType,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
              HapticFeedback.selectionClick();
            },
          ),
          DescriptionInputWidget(
            controller: _descriptionController,
            onDescriptionChanged: (description) {
              setState(() {});
            },
          ),
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
              HapticFeedback.selectionClick();
            },
          ),
          ReceiptCameraWidget(
            onImageCaptured: (image) {
              setState(() => _receiptImage = image);
              if (image != null) {
                HapticFeedback.mediumImpact();
                _showSuccessSnackBar('Foto struk berhasil ditambahkan');
              }
            },
          ),
          AdvancedOptionsWidget(
            isRecurring: _isRecurring,
            recurringFrequency: _recurringFrequency,
            selectedBudget: _selectedBudget,
            tags: _tags,
            onRecurringChanged: (value) => setState(() => _isRecurring = value),
            onFrequencyChanged: (frequency) =>
                setState(() => _recurringFrequency = frequency),
            onBudgetChanged: (budget) =>
                setState(() => _selectedBudget = budget),
            onTagsChanged: (tags) => setState(() => _tags = tags),
          ),
          SizedBox(height: 12.h), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
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
                onPressed: () => _showCancelDialog(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canSaveTransaction() ? _saveTransaction : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  backgroundColor: _canSaveTransaction()
                      ? (_transactionType == 'income'
                          ? AppTheme.getSuccessColor(true)
                          : AppTheme.lightTheme.colorScheme.error)
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'save',
                            color: Colors.white,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Simpan Transaksi',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAmount(String amount) {
    if (amount.isNotEmpty) {
      final numericValue = _parseAmount(amount);
      if (numericValue > 1000000000) {
        // 1 billion IDR limit
        _showErrorSnackBar('Jumlah terlalu besar. Maksimal Rp 1.000.000.000');
        return;
      }
      if (numericValue < 100) {
        // Minimum 100 IDR
        _showErrorSnackBar('Jumlah minimal Rp 100');
        return;
      }
    }
  }

  double _parseAmount(String amount) {
    final cleanAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanAmount.isEmpty ? 0 : double.parse(cleanAmount);
  }

  bool _canSaveTransaction() {
    return _amountController.text.isNotEmpty &&
        _selectedCategory != null &&
        !_isLoading;
  }

  bool _isDraftSaveable() {
    return _amountController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategory != null;
  }

  void _saveDraft() {
    HapticFeedback.lightImpact();
    _showSuccessSnackBar('Draft berhasil disimpan');
    // Here you would typically save to local storage
  }

  Future<void> _saveTransaction() async {
    if (!_canSaveTransaction()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 1500));

      // Create transaction data
      final transactionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': _transactionType,
        'amount': _parseAmount(_amountController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'date': _selectedDate.toIso8601String(),
        'receiptImage': _receiptImage?.path,
        'isRecurring': _isRecurring,
        'recurringFrequency': _isRecurring ? _recurringFrequency : null,
        'budget': _selectedBudget,
        'tags': _tags,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Here you would typically save to local database
      debugPrint('Transaction saved: $transactionData');

      // Show success feedback
      HapticFeedback.heavyImpact();
      _showSuccessSnackBar(
          '${_transactionType == 'income' ? 'Pemasukan' : 'Pengeluaran'} berhasil disimpan');

      // Navigate back to dashboard
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacementNamed(context, '/dashboard-home');
    } catch (e) {
      _showErrorSnackBar('Gagal menyimpan transaksi. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCancelDialog() {
    if (!_isDraftSaveable()) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Batalkan Transaksi?',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Data yang sudah diisi akan hilang. Apakah Anda yakin ingin membatalkan?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Lanjut Edit',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: _saveDraft,
            child: Text(
              'Simpan Draft',
              style: TextStyle(
                color: AppTheme.getAccentColor(true),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Buang',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
