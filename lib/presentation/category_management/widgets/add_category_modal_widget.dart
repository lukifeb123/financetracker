import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddCategoryModalWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCategoryAdded;
  final Map<String, dynamic>? editingCategory;

  const AddCategoryModalWidget({
    super.key,
    required this.onCategoryAdded,
    this.editingCategory,
  });

  @override
  State<AddCategoryModalWidget> createState() => _AddCategoryModalWidgetState();
}

class _AddCategoryModalWidgetState extends State<AddCategoryModalWidget> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedIcon = 'category';
  String _selectedType = 'expense';
  String? _selectedParentCategory;
  Color _selectedColor = const Color(0xFF1B365D);

  final List<String> _availableIcons = [
    'restaurant',
    'local_gas_station',
    'home',
    'shopping_cart',
    'movie',
    'fitness_center',
    'school',
    'local_hospital',
    'directions_car',
    'flight',
    'hotel',
    'phone',
    'wifi',
    'electric_bolt',
    'water_drop',
    'account_balance',
    'credit_card',
    'savings',
    'trending_up',
    'work',
    'business',
    'store',
    'local_grocery_store',
    'local_pharmacy',
    'local_cafe',
    'local_bar',
    'local_pizza',
    'fastfood',
    'cake',
    'local_florist',
  ];

  final List<Color> _availableColors = [
    const Color(0xFF1B365D),
    const Color(0xFF2E7D5A),
    const Color(0xFFE67E22),
    const Color(0xFFE74C3C),
    const Color(0xFF9B59B6),
    const Color(0xFF3498DB),
    const Color(0xFF1ABC9C),
    const Color(0xFFF39C12),
    const Color(0xFF34495E),
    const Color(0xFF95A5A6),
    const Color(0xFFE91E63),
    const Color(0xFF673AB7),
  ];

  final List<Map<String, dynamic>> _parentCategories = [
    {'id': 'makanan', 'name': 'Makanan', 'type': 'expense'},
    {'id': 'transportasi', 'name': 'Transportasi', 'type': 'expense'},
    {'id': 'tagihan', 'name': 'Tagihan', 'type': 'expense'},
    {'id': 'hiburan', 'name': 'Hiburan', 'type': 'expense'},
    {'id': 'gaji', 'name': 'Gaji', 'type': 'income'},
    {'id': 'bisnis', 'name': 'Bisnis', 'type': 'income'},
    {'id': 'investasi', 'name': 'Investasi', 'type': 'income'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingCategory != null) {
      _nameController.text = widget.editingCategory!['name'] as String? ?? '';
      _selectedIcon = widget.editingCategory!['icon'] as String? ?? 'category';
      _selectedType = widget.editingCategory!['type'] as String? ?? 'expense';
      _selectedParentCategory = widget.editingCategory!['parentId'] as String?;
      _selectedColor =
          Color(widget.editingCategory!['color'] as int? ?? 0xFF1B365D);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEditing = widget.editingCategory != null;

    return Container(
        height: 90.h,
        decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          _buildHeader(context, isDark, isEditing),
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameInput(context, isDark),
                        SizedBox(height: 3.h),
                        _buildTypeSelector(context, isDark),
                        SizedBox(height: 3.h),
                        _buildParentCategorySelector(context, isDark),
                        SizedBox(height: 3.h),
                        _buildIconSelector(context, isDark),
                        SizedBox(height: 3.h),
                        _buildColorSelector(context, isDark),
                        SizedBox(height: 4.h),
                        _buildActionButtons(context, isDark, isEditing),
                      ]))),
        ]));
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isEditing) {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 0.5))),
        child: Row(children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                  iconName: 'close',
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  size: 6.w)),
          Expanded(
              child: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight),
                  textAlign: TextAlign.center)),
          SizedBox(width: 12.w),
        ]));
  }

  Widget _buildNameInput(BuildContext context, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Nama Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight)),
      SizedBox(height: 1.h),
      TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Masukkan nama kategori'),
          style: Theme.of(context).textTheme.bodyLarge),
    ]);
  }

  Widget _buildTypeSelector(BuildContext context, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tipe Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight)),
      SizedBox(height: 1.h),
      Row(children: [
        Expanded(
            child: _buildTypeOption(
                context, isDark, 'expense', 'Pengeluaran', 'remove')),
        SizedBox(width: 3.w),
        Expanded(
            child: _buildTypeOption(
                context, isDark, 'income', 'Pemasukan', 'add')),
      ]),
    ]);
  }

  Widget _buildTypeOption(BuildContext context, bool isDark, String type,
      String label, String iconName) {
    final bool isSelected = _selectedType == type;
    final Color color = type == 'income'
        ? AppTheme.getSuccessColor(!isDark)
        : AppTheme.errorLight;

    return InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? color
                        : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    width: isSelected ? 2 : 0.5)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CustomIconWidget(
                  iconName: iconName,
                  color: isSelected
                      ? color
                      : (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
                  size: 5.w),
              SizedBox(width: 2.w),
              Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? color
                          : (isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400)),
            ])));
  }

  Widget _buildParentCategorySelector(BuildContext context, bool isDark) {
    final filteredParents = _parentCategories
        .where((parent) => (parent['type'] as String) == _selectedType)
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Kategori Induk (Opsional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight)),
      SizedBox(height: 1.h),
      DropdownButtonFormField<String>(
          value: _selectedParentCategory,
          decoration: const InputDecoration(hintText: 'Pilih kategori induk'),
          items: [
            const DropdownMenuItem<String>(
                value: null, child: Text('Tidak ada')),
            ...filteredParents.map((parent) => DropdownMenuItem<String>(
                value: parent['id'] as String,
                child: Text(parent['name'] as String))),
          ],
          onChanged: (value) =>
              setState(() => _selectedParentCategory = value)),
    ]);
  }

  Widget _buildIconSelector(BuildContext context, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pilih Ikon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight)),
      SizedBox(height: 1.h),
      Container(
          height: 25.h,
          decoration: BoxDecoration(
              border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 0.5),
              borderRadius: BorderRadius.circular(12)),
          child: GridView.builder(
              padding: EdgeInsets.all(2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.w),
              itemBuilder: (context, index) {
                final iconName = _availableIcons[index];
                final isSelected = _selectedIcon == iconName;

                return InkWell(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                        decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: _selectedColor, width: 2)
                                : null),
                        child: Center(
                            child: CustomIconWidget(
                                iconName: iconName,
                                color: isSelected
                                    ? _selectedColor
                                    : (isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight),
                                size: 6.w))));
              })),
    ]);
  }

  Widget _buildColorSelector(BuildContext context, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pilih Warna',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight)),
      SizedBox(height: 1.h),
      Wrap(
          spacing: 3.w,
          runSpacing: 2.h,
          children: _availableColors.map((color) {
            final isSelected = _selectedColor == color;

            return InkWell(
                onTap: () => setState(() => _selectedColor = color),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                                width: 3)
                            : null),
                    child: isSelected
                        ? Center(
                            child: CustomIconWidget(
                                iconName: 'check',
                                color: Colors.white,
                                size: 5.w))
                        : null));
          }).toList()),
    ]);
  }

  Widget _buildActionButtons(
      BuildContext context, bool isDark, bool isEditing) {
    return Row(children: [
      Expanded(
          child: OutlinedButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal'))),
      SizedBox(width: 4.w),
      Expanded(
          child: ElevatedButton(
              onPressed:
                  _nameController.text.trim().isEmpty ? null : _saveCategory,
              child: Text(isEditing ? 'Simpan' : 'Tambah'))),
    ]);
  }

  void _saveCategory() {
    final categoryData = {
      'id': widget.editingCategory?['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text.trim(),
      'icon': _selectedIcon,
      'type': _selectedType,
      'parentId': _selectedParentCategory,
      'color': _selectedColor.value,
      'transactionCount': widget.editingCategory?['transactionCount'] ?? 0,
      'totalAmount': widget.editingCategory?['totalAmount'] ?? 0.0,
      'subcategories': widget.editingCategory?['subcategories'] ?? [],
      'createdAt': widget.editingCategory?['createdAt'] ??
          DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    widget.onCategoryAdded(categoryData);
    Navigator.pop(context);
  }
}
