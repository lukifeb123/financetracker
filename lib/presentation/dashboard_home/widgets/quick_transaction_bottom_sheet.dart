import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickTransactionBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onTransactionAdded;

  const QuickTransactionBottomSheet({
    Key? key,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  State<QuickTransactionBottomSheet> createState() =>
      _QuickTransactionBottomSheetState();
}

class _QuickTransactionBottomSheetState
    extends State<QuickTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _transactionType = 'expense';
  String _selectedCategory = 'Makanan';

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Utilitas',
    'Lainnya'
  ];

  final List<String> _incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Freelance',
    'Bisnis',
    'Lainnya'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.isEmpty) return '';

    int amount = int.parse(cleanValue);
    String formattedAmount = amount.toString();

    String result = '';
    for (int i = 0; i < formattedAmount.length; i++) {
      if (i > 0 && (formattedAmount.length - i) % 3 == 0) {
        result += '.';
      }
      result += formattedAmount[i];
    }

    return 'Rp $result';
  }

  double _parseCurrency(String value) {
    String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    return cleanValue.isEmpty ? 0.0 : double.parse(cleanValue);
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'type': _transactionType,
        'amount': _parseCurrency(_amountController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'date': DateTime.now(),
      };

      widget.onTransactionAdded(transaction);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi berhasil ditambahkan'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Tambah Transaksi Cepat',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 3.h),

            // Transaction Type Toggle
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _transactionType = 'expense';
                          _selectedCategory = _expenseCategories.first;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _transactionType == 'expense'
                              ? AppTheme.errorLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'trending_down',
                              color: _transactionType == 'expense'
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Pengeluaran',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _transactionType == 'expense'
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _transactionType = 'income';
                          _selectedCategory = _incomeCategories.first;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _transactionType == 'income'
                              ? AppTheme.successLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'trending_up',
                              color: _transactionType == 'income'
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Pemasukan',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _transactionType == 'income'
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'attach_money',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                if (_parseCurrency(value) <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                return null;
              },
              onChanged: (value) {
                String formatted = _formatCurrency(value);
                if (formatted != value) {
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            SizedBox(height: 2.h),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'category',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              items: (_transactionType == 'expense'
                      ? _expenseCategories
                      : _incomeCategories)
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 2.h),

            // Description Input
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'description',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
              maxLines: 2,
            ),
            SizedBox(height: 4.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _transactionType == 'expense'
                      ? AppTheme.errorLight
                      : AppTheme.successLight,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Tambah Transaksi',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
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
}
