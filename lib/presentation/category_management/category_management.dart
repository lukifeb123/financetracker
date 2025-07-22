import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_category_modal_widget.dart';
import './widgets/category_item_widget.dart';
import './widgets/category_section_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/search_bar_widget.dart';

class CategoryManagement extends StatefulWidget {
  const CategoryManagement({super.key});

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement> {
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  String _searchQuery = '';
  bool _isExpenseExpanded = true;
  bool _isIncomeExpanded = true;
  final Map<String, bool> _categoryExpansionState = {};

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _filterCategories();
  }

  void _initializeCategories() {
    _allCategories = [
      // Expense Categories
      {
        'id': 'makanan',
        'name': 'Makanan',
        'icon': 'restaurant',
        'type': 'expense',
        'color': 0xFFE67E22,
        'transactionCount': 45,
        'totalAmount': 2500000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'makanan_sarapan',
            'name': 'Sarapan',
            'icon': 'free_breakfast',
            'transactionCount': 15,
            'totalAmount': 750000.0,
          },
          {
            'id': 'makanan_makan_siang',
            'name': 'Makan Siang',
            'icon': 'lunch_dining',
            'transactionCount': 20,
            'totalAmount': 1200000.0,
          },
          {
            'id': 'makanan_makan_malam',
            'name': 'Makan Malam',
            'icon': 'dinner_dining',
            'transactionCount': 10,
            'totalAmount': 550000.0,
          },
        ],
        'createdAt': '2025-01-15T08:30:00.000Z',
        'updatedAt': '2025-01-22T10:15:02.354Z',
      },
      {
        'id': 'transportasi',
        'name': 'Transportasi',
        'icon': 'directions_car',
        'type': 'expense',
        'color': 0xFF3498DB,
        'transactionCount': 32,
        'totalAmount': 1800000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'transportasi_bensin',
            'name': 'Bensin',
            'icon': 'local_gas_station',
            'transactionCount': 12,
            'totalAmount': 800000.0,
          },
          {
            'id': 'transportasi_ojek',
            'name': 'Ojek Online',
            'icon': 'motorcycle',
            'transactionCount': 20,
            'totalAmount': 1000000.0,
          },
        ],
        'createdAt': '2025-01-10T09:00:00.000Z',
        'updatedAt': '2025-01-21T14:20:15.123Z',
      },
      {
        'id': 'tagihan',
        'name': 'Tagihan',
        'icon': 'receipt_long',
        'type': 'expense',
        'color': 0xFFE74C3C,
        'transactionCount': 8,
        'totalAmount': 1200000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'tagihan_listrik',
            'name': 'Listrik',
            'icon': 'electric_bolt',
            'transactionCount': 1,
            'totalAmount': 350000.0,
          },
          {
            'id': 'tagihan_air',
            'name': 'Air',
            'icon': 'water_drop',
            'transactionCount': 1,
            'totalAmount': 150000.0,
          },
          {
            'id': 'tagihan_internet',
            'name': 'Internet',
            'icon': 'wifi',
            'transactionCount': 1,
            'totalAmount': 400000.0,
          },
          {
            'id': 'tagihan_telepon',
            'name': 'Telepon',
            'icon': 'phone',
            'transactionCount': 1,
            'totalAmount': 300000.0,
          },
        ],
        'createdAt': '2025-01-05T10:15:00.000Z',
        'updatedAt': '2025-01-20T16:45:30.456Z',
      },
      {
        'id': 'hiburan',
        'name': 'Hiburan',
        'icon': 'movie',
        'type': 'expense',
        'color': 0xFF9B59B6,
        'transactionCount': 12,
        'totalAmount': 900000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'hiburan_bioskop',
            'name': 'Bioskop',
            'icon': 'theaters',
            'transactionCount': 3,
            'totalAmount': 300000.0,
          },
          {
            'id': 'hiburan_game',
            'name': 'Game',
            'icon': 'sports_esports',
            'transactionCount': 5,
            'totalAmount': 400000.0,
          },
          {
            'id': 'hiburan_streaming',
            'name': 'Streaming',
            'icon': 'play_circle',
            'transactionCount': 4,
            'totalAmount': 200000.0,
          },
        ],
        'createdAt': '2025-01-12T11:30:00.000Z',
        'updatedAt': '2025-01-22T09:10:45.789Z',
      },
      {
        'id': 'belanja',
        'name': 'Belanja',
        'icon': 'shopping_cart',
        'type': 'expense',
        'color': 0xFF1ABC9C,
        'transactionCount': 25,
        'totalAmount': 1500000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'belanja_pakaian',
            'name': 'Pakaian',
            'icon': 'checkroom',
            'transactionCount': 8,
            'totalAmount': 800000.0,
          },
          {
            'id': 'belanja_elektronik',
            'name': 'Elektronik',
            'icon': 'devices',
            'transactionCount': 3,
            'totalAmount': 500000.0,
          },
          {
            'id': 'belanja_rumah_tangga',
            'name': 'Rumah Tangga',
            'icon': 'home_repair_service',
            'transactionCount': 14,
            'totalAmount': 200000.0,
          },
        ],
        'createdAt': '2025-01-08T13:45:00.000Z',
        'updatedAt': '2025-01-21T12:30:20.234Z',
      },
      // Income Categories
      {
        'id': 'gaji',
        'name': 'Gaji',
        'icon': 'work',
        'type': 'income',
        'color': 0xFF27AE60,
        'transactionCount': 2,
        'totalAmount': 15000000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'gaji_pokok',
            'name': 'Gaji Pokok',
            'icon': 'account_balance_wallet',
            'transactionCount': 1,
            'totalAmount': 12000000.0,
          },
          {
            'id': 'gaji_tunjangan',
            'name': 'Tunjangan',
            'icon': 'card_giftcard',
            'transactionCount': 1,
            'totalAmount': 3000000.0,
          },
        ],
        'createdAt': '2025-01-01T08:00:00.000Z',
        'updatedAt': '2025-01-22T08:00:00.000Z',
      },
      {
        'id': 'bisnis',
        'name': 'Bisnis',
        'icon': 'business',
        'type': 'income',
        'color': 0xFF2E7D5A,
        'transactionCount': 15,
        'totalAmount': 8500000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'bisnis_penjualan',
            'name': 'Penjualan',
            'icon': 'point_of_sale',
            'transactionCount': 10,
            'totalAmount': 6000000.0,
          },
          {
            'id': 'bisnis_jasa',
            'name': 'Jasa',
            'icon': 'handyman',
            'transactionCount': 5,
            'totalAmount': 2500000.0,
          },
        ],
        'createdAt': '2025-01-03T09:30:00.000Z',
        'updatedAt': '2025-01-21T15:45:10.567Z',
      },
      {
        'id': 'investasi',
        'name': 'Investasi',
        'icon': 'trending_up',
        'type': 'income',
        'color': 0xFFF39C12,
        'transactionCount': 5,
        'totalAmount': 2200000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'investasi_saham',
            'name': 'Saham',
            'icon': 'show_chart',
            'transactionCount': 3,
            'totalAmount': 1500000.0,
          },
          {
            'id': 'investasi_reksadana',
            'name': 'Reksadana',
            'icon': 'pie_chart',
            'transactionCount': 2,
            'totalAmount': 700000.0,
          },
        ],
        'createdAt': '2025-01-07T14:20:00.000Z',
        'updatedAt': '2025-01-20T11:25:35.890Z',
      },
      {
        'id': 'freelance',
        'name': 'Freelance',
        'icon': 'laptop_mac',
        'type': 'income',
        'color': 0xFF673AB7,
        'transactionCount': 8,
        'totalAmount': 4500000.0,
        'parentId': null,
        'subcategories': [
          {
            'id': 'freelance_design',
            'name': 'Design',
            'icon': 'design_services',
            'transactionCount': 4,
            'totalAmount': 2500000.0,
          },
          {
            'id': 'freelance_programming',
            'name': 'Programming',
            'icon': 'code',
            'transactionCount': 4,
            'totalAmount': 2000000.0,
          },
        ],
        'createdAt': '2025-01-09T16:10:00.000Z',
        'updatedAt': '2025-01-22T07:30:25.123Z',
      },
    ];

    // Initialize expansion state
    for (var category in _allCategories) {
      _categoryExpansionState[category['id'] as String] = false;
    }
  }

  void _filterCategories() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredCategories = List.from(_allCategories);
      } else {
        _filteredCategories = _allCategories.where((category) {
          final categoryName = (category['name'] as String).toLowerCase();
          final searchLower = _searchQuery.toLowerCase();

          // Search in category name
          bool matchesCategory = categoryName.contains(searchLower);

          // Search in subcategories
          bool matchesSubcategory = false;
          final subcategories =
              category['subcategories'] as List<dynamic>? ?? [];
          for (var sub in subcategories) {
            final subMap = sub as Map<String, dynamic>;
            final subName = (subMap['name'] as String).toLowerCase();
            if (subName.contains(searchLower)) {
              matchesSubcategory = true;
              break;
            }
          }

          return matchesCategory || matchesSubcategory;
        }).toList();
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterCategories();
  }

  void _clearSearch() {
    _searchQuery = '';
    _filterCategories();
  }

  List<Map<String, dynamic>> _getExpenseCategories() {
    return _filteredCategories
        .where((cat) => (cat['type'] as String) == 'expense')
        .toList();
  }

  List<Map<String, dynamic>> _getIncomeCategories() {
    return _filteredCategories
        .where((cat) => (cat['type'] as String) == 'income')
        .toList();
  }

  double _getTotalAmount(List<Map<String, dynamic>> categories) {
    return categories.fold(
        0.0, (sum, cat) => sum + ((cat['totalAmount'] as double?) ?? 0.0));
  }

  void _showAddCategoryModal({Map<String, dynamic>? editingCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryModalWidget(
        editingCategory: editingCategory,
        onCategoryAdded: _onCategoryAdded,
      ),
    );
  }

  void _onCategoryAdded(Map<String, dynamic> categoryData) {
    setState(() {
      final existingIndex = _allCategories.indexWhere(
        (cat) => (cat['id'] as String) == (categoryData['id'] as String),
      );

      if (existingIndex != -1) {
        _allCategories[existingIndex] = categoryData;
      } else {
        _allCategories.add(categoryData);
        _categoryExpansionState[categoryData['id'] as String] = false;
      }
    });
    _filterCategories();
  }

  void _toggleCategoryExpansion(String categoryId) {
    setState(() {
      _categoryExpansionState[categoryId] =
          !(_categoryExpansionState[categoryId] ?? false);
    });
  }

  void _editCategory(Map<String, dynamic> category) {
    _showAddCategoryModal(editingCategory: category);
  }

  void _duplicateCategory(Map<String, dynamic> category) {
    final duplicatedCategory = Map<String, dynamic>.from(category);
    duplicatedCategory['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    duplicatedCategory['name'] = '${category['name']} (Copy)';
    duplicatedCategory['transactionCount'] = 0;
    duplicatedCategory['totalAmount'] = 0.0;
    duplicatedCategory['subcategories'] = [];
    duplicatedCategory['createdAt'] = DateTime.now().toIso8601String();
    duplicatedCategory['updatedAt'] = DateTime.now().toIso8601String();

    _onCategoryAdded(duplicatedCategory);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kategori "${category['name']}" berhasil diduplikat'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _setBudget(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => _BudgetDialog(
        categoryName: category['name'] as String,
        onBudgetSet: (amount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Anggaran untuk ${category['name']} berhasil diatur: ${_formatCurrency(amount)}'),
              backgroundColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
          );
        },
      ),
    );
  }

  void _deleteCategory(Map<String, dynamic> category) {
    final transactionCount = category['transactionCount'] as int? ?? 0;

    if (transactionCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tidak Dapat Menghapus'),
          content: Text(
            'Kategori "${category['name']}" memiliki $transactionCount transaksi. '
            'Hapus semua transaksi terlebih dahulu atau pindahkan ke kategori lain.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Kategori'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allCategories.removeWhere((cat) =>
                    (cat['id'] as String) == (category['id'] as String));
                _categoryExpansionState.remove(category['id'] as String);
              });
              _filterCategories();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Kategori "${category['name']}" berhasil dihapus'),
                  backgroundColor: AppTheme.errorLight,
                ),
              );
            },
            child: Text('Hapus'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorLight),
          ),
        ],
      ),
    );
  }

  void _viewTransactions(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/transaction-history');
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';

    String formattedAmount = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;

    for (int i = formattedAmount.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = '.$result';
        counter = 0;
      }
      result = formattedAmount[i] + result;
      counter++;
    }

    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseCategories = _getExpenseCategories();
    final incomeCategories = _getIncomeCategories();

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Kelola Kategori'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddCategoryModal(),
            icon: CustomIconWidget(
              iconName: 'add',
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: _filteredCategories.isEmpty && _searchQuery.isNotEmpty
          ? EmptyStateWidget(
              title: 'Kategori Tidak Ditemukan',
              subtitle:
                  'Tidak ada kategori yang cocok dengan pencarian "$_searchQuery"',
              iconName: 'search_off',
              showButton: false,
            )
          : _allCategories.isEmpty
              ? EmptyStateWidget(
                  title: 'Belum Ada Kategori',
                  subtitle:
                      'Mulai dengan menambahkan kategori pertama Anda untuk mengorganisir transaksi keuangan',
                  iconName: 'category',
                  onButtonPressed: () => _showAddCategoryModal(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    _filterCategories();
                  },
                  child: Column(
                    children: [
                      SearchBarWidget(
                        onSearchChanged: _onSearchChanged,
                        onClearSearch: _clearSearch,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            if (expenseCategories.isNotEmpty) ...[
                              CategorySectionHeaderWidget(
                                title: 'Pengeluaran',
                                iconName: 'remove',
                                color: AppTheme.errorLight,
                                categoryCount: expenseCategories.length,
                                totalAmount: _getTotalAmount(expenseCategories),
                                isExpanded: _isExpenseExpanded,
                                onToggle: () => setState(() =>
                                    _isExpenseExpanded = !_isExpenseExpanded),
                              ),
                              if (_isExpenseExpanded)
                                ...expenseCategories.map((category) =>
                                    CategoryItemWidget(
                                      category: category,
                                      isExpanded: _categoryExpansionState[
                                              category['id'] as String] ??
                                          false,
                                      onTap: () => _toggleCategoryExpansion(
                                          category['id'] as String),
                                      onEdit: () => _editCategory(category),
                                      onDuplicate: () =>
                                          _duplicateCategory(category),
                                      onSetBudget: () => _setBudget(category),
                                      onDelete: () => _deleteCategory(category),
                                      onViewTransactions: () =>
                                          _viewTransactions(category),
                                    )),
                            ],
                            if (incomeCategories.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              CategorySectionHeaderWidget(
                                title: 'Pemasukan',
                                iconName: 'add',
                                color: AppTheme.getSuccessColor(!isDark),
                                categoryCount: incomeCategories.length,
                                totalAmount: _getTotalAmount(incomeCategories),
                                isExpanded: _isIncomeExpanded,
                                onToggle: () => setState(() =>
                                    _isIncomeExpanded = !_isIncomeExpanded),
                              ),
                              if (_isIncomeExpanded)
                                ...incomeCategories.map((category) =>
                                    CategoryItemWidget(
                                      category: category,
                                      isExpanded: _categoryExpansionState[
                                              category['id'] as String] ??
                                          false,
                                      onTap: () => _toggleCategoryExpansion(
                                          category['id'] as String),
                                      onEdit: () => _editCategory(category),
                                      onDuplicate: () =>
                                          _duplicateCategory(category),
                                      onSetBudget: () => _setBudget(category),
                                      onDelete: () => _deleteCategory(category),
                                      onViewTransactions: () =>
                                          _viewTransactions(category),
                                    )),
                            ],
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryModal(),
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 7.w,
        ),
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  final String categoryName;
  final Function(double) onBudgetSet;

  const _BudgetDialog({
    required this.categoryName,
    required this.onBudgetSet,
  });

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text('Atur Anggaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori: ${widget.categoryName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Anggaran',
              hintText: 'Masukkan jumlah dalam Rupiah',
              prefixText: 'Rp ',
            ),
            style: AppTheme.getDataTextStyle(
              isLight: !isDark,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final budgetText = _budgetController.text.trim();
            if (budgetText.isNotEmpty) {
              final budget = double.tryParse(
                  budgetText.replaceAll('.', '').replaceAll(',', ''));
              if (budget != null && budget > 0) {
                widget.onBudgetSet(budget);
                Navigator.pop(context);
              }
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
