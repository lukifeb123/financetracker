import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReceiptResultWidget extends StatefulWidget {
  final Map<String, dynamic> extractedData;
  final XFile? capturedImage;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onRetake;
  final Function(Map<String, dynamic>) onEdit;

  const ReceiptResultWidget({
    Key? key,
    required this.extractedData,
    required this.capturedImage,
    required this.onSave,
    required this.onRetake,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<ReceiptResultWidget> createState() => _ReceiptResultWidgetState();
}

class _ReceiptResultWidgetState extends State<ReceiptResultWidget> {
  late Map<String, dynamic> _editableData;

  @override
  void initState() {
    super.initState();
    _editableData = Map<String, dynamic>.from(widget.extractedData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildReceiptImage(),
                  _buildExtractedData(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.getSuccessColor(true),
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Struk Berhasil Dianalisis',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Periksa dan edit data jika diperlukan',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptImage() {
    if (widget.capturedImage == null) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.capturedImage!.path),
          height: 25.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildExtractedData() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
          Text(
            'Data Transaksi',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildEditableField(
            'Jumlah',
            'amount',
            'Rp ${_formatCurrency(_editableData['amount']?.toDouble() ?? 0.0)}',
            Icons.attach_money,
            isAmount: true,
          ),
          _buildEditableField(
            'Deskripsi',
            'description',
            _editableData['description']?.toString() ?? 'Tidak ada deskripsi',
            Icons.description,
          ),
          _buildEditableField(
            'Kategori',
            'category',
            _editableData['category']?.toString() ?? 'Lainnya',
            Icons.category,
            isCategory: true,
          ),
          _buildEditableField(
            'Merchant',
            'merchant',
            _editableData['merchant']?.toString() ?? 'Tidak diketahui',
            Icons.store,
          ),
          _buildEditableField(
            'Tanggal',
            'date',
            _formatDate(_editableData['date']?.toString() ?? ''),
            Icons.calendar_today,
            isDate: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String key,
    String value,
    IconData icon, {
    bool isAmount = false,
    bool isCategory = false,
    bool isDate = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: GestureDetector(
        onTap: () =>
            _editField(label, key, value, isAmount, isCategory, isDate),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      value,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ],
          ),
        ),
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
              child: OutlinedButton.icon(
                onPressed: widget.onRetake,
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 5.w,
                ),
                label: Text('Foto Ulang'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => widget.onSave(_editableData),
                icon: CustomIconWidget(
                  iconName: 'save',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text(
                  'Simpan Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getSuccessColor(true),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editField(String label, String key, String currentValue, bool isAmount,
      bool isCategory, bool isDate) {
    if (isCategory) {
      _showCategoryPicker(key);
    } else if (isDate) {
      _showDatePicker(key);
    } else {
      _showTextEditDialog(label, key, currentValue, isAmount);
    }
  }

  void _showTextEditDialog(
      String label, String key, String currentValue, bool isAmount) {
    final controller = TextEditingController(
      text: isAmount ? (_editableData[key]?.toString() ?? '') : currentValue,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          keyboardType: isAmount ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            prefixText: isAmount ? 'Rp ' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _editableData[key] = isAmount
                    ? double.tryParse(controller.text) ?? 0.0
                    : controller.text;
              });
              widget.onEdit(_editableData);
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(String key) {
    final categories = [
      'Makanan',
      'Transportasi',
      'Belanja',
      'Hiburan',
      'Kesehatan',
      'Utilitas',
      'Lainnya'
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Kategori',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ...categories.map((category) => ListTile(
                  title: Text(category),
                  onTap: () {
                    setState(() {
                      _editableData[key] = category;
                    });
                    widget.onEdit(_editableData);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(String key) async {
    final currentDate =
        DateTime.tryParse(_editableData[key]?.toString() ?? '') ??
            DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() {
        _editableData[key] = pickedDate.toIso8601String().split('T')[0];
      });
      widget.onEdit(_editableData);
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
