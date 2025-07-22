import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String transactionType;
  final Function(String) onAmountChanged;

  const AmountInputWidget({
    Key? key,
    required this.controller,
    required this.transactionType,
    required this.onAmountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jumlah',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: AppTheme.getDataTextStyle(
                  isLight: true,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ).copyWith(
                  color: transactionType == 'income'
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    _CurrencyInputFormatter(),
                  ],
                  style: AppTheme.getDataTextStyle(
                    isLight: true,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ).copyWith(
                    color: transactionType == 'income'
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.lightTheme.colorScheme.error,
                  ),
                  decoration: InputDecoration(
                    hintText: '0,00',
                    hintStyle: AppTheme.getDataTextStyle(
                      isLight: true,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onAmountChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildQuickAmountButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons() {
    final List<String> quickAmounts = [
      '10.000',
      '50.000',
      '100.000',
      '500.000'
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: quickAmounts.map((amount) {
        return GestureDetector(
          onTap: () {
            controller.text = amount;
            onAmountChanged(amount);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Rp $amount',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String formatted = _formatCurrency(newText);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    int intValue = int.parse(value);
    String formatted = intValue.toString();

    String result = '';
    int count = 0;

    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = formatted[i] + result;
      count++;
    }

    return result;
  }
}
