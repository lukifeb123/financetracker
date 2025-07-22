import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_section_header.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/month_year_picker.dart';
import './widgets/sort_options_sheet.dart';
import './widgets/transaction_list_item.dart';
import './widgets/transaction_search_bar.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {
    'type': 'all',
    'category': 'Semua',
    'minAmount': 0,
    'maxAmount': null,
    'startDate': null,
    'endDate': null,
  };
  String _sortBy = 'date';
  bool _isAscending = false;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  Set<int> _selectedTransactions = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _allTransactions = [
      {
        'id': 1,
        'description': 'Makan siang di Warung Padang',
        'amount': 25000.0,
        'category': 'Makanan',
        'type': 'expense',
        'date': now.subtract(const Duration(hours: 2)),
        'notes': 'Makan dengan teman kantor',
      },
      {
        'id': 2,
        'description': 'Gaji bulanan',
        'amount': 8500000.0,
        'category': 'Gaji',
        'type': 'income',
        'date': now.subtract(const Duration(days: 1)),
        'notes': 'Gaji bulan Juli 2025',
      },
      {
        'id': 3,
        'description': 'Bensin motor',
        'amount': 50000.0,
        'category': 'Transportasi',
        'type': 'expense',
        'date': now.subtract(const Duration(days: 1, hours: 3)),
        'notes': 'Isi bensin Pertamax',
      },
      {
        'id': 4,
        'description': 'Belanja groceries',
        'amount': 150000.0,
        'category': 'Belanja',
        'type': 'expense',
        'date': now.subtract(const Duration(days: 2)),
        'notes': 'Belanja mingguan di supermarket',
      },
      {
        'id': 5,
        'description': 'Bonus proyek',
        'amount': 2000000.0,
        'category': 'Investasi',
        'type': 'income',
        'date': now.subtract(const Duration(days: 3)),
        'notes': 'Bonus penyelesaian proyek mobile app',
      },
      {
        'id': 6,
        'description': 'Nonton bioskop',
        'amount': 75000.0,
        'category': 'Hiburan',
        'type': 'expense',
        'date': now.subtract(const Duration(days: 3, hours: 5)),
        'notes': 'Nonton film dengan keluarga',
      },
      {
        'id': 7,
        'description': 'Konsultasi dokter',
        'amount': 200000.0,
        'category': 'Kesehatan',
        'type': 'expense',
        'date': now.subtract(const Duration(days: 5)),
        'notes': 'Pemeriksaan rutin',
      },
      {
        'id': 8,
        'description': 'Kursus online',
        'amount': 500000.0,
        'category': 'Pendidikan',
        'type': 'expense',
        'date': now.subtract(const Duration(days: 7)),
        'notes': 'Kursus Flutter development',
      },
      {
        'id': 9,
        'description': 'Hadiah ulang tahun',
        'amount': 300000.0,
        'category': 'Hadiah',
        'type': 'expense',
        'date': now.subtract(const Duration(days: 10)),
        'notes': 'Hadiah untuk adik',
      },
      {
        'id': 10,
        'description': 'Freelance project',
        'amount': 1500000.0,
        'category': 'Gaji',
        'type': 'income',
        'date': now.subtract(const Duration(days: 12)),
        'notes': 'Proyek website company profile',
      },
    ];
    _applyFiltersAndSort();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading more data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // In real app, load more data from database
          // For demo, we'll just mark as no more data after first load
          _hasMoreData = false;
        });
      }
    });
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description =
            (transaction['description'] as String).toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final amount = transaction['amount'].toString();
        final query = _searchQuery.toLowerCase();

        return description.contains(query) ||
            category.contains(query) ||
            amount.contains(query);
      }).toList();
    }

    // Apply type filter
    if (_activeFilters['type'] != 'all') {
      filtered = filtered
          .where((transaction) => transaction['type'] == _activeFilters['type'])
          .toList();
    }

    // Apply category filter
    if (_activeFilters['category'] != 'Semua') {
      filtered = filtered
          .where((transaction) =>
              transaction['category'] == _activeFilters['category'])
          .toList();
    }

    // Apply amount range filter
    if (_activeFilters['minAmount'] != null &&
        _activeFilters['minAmount'] > 0) {
      filtered = filtered
          .where((transaction) =>
              (transaction['amount'] as double) >= _activeFilters['minAmount'])
          .toList();
    }

    if (_activeFilters['maxAmount'] != null) {
      filtered = filtered
          .where((transaction) =>
              (transaction['amount'] as double) <= _activeFilters['maxAmount'])
          .toList();
    }

    // Apply date range filter
    if (_activeFilters['startDate'] != null) {
      filtered = filtered.where((transaction) {
        final transactionDate = transaction['date'] as DateTime;
        final startDate = _activeFilters['startDate'] as DateTime;
        return transactionDate
            .isAfter(startDate.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (_activeFilters['endDate'] != null) {
      filtered = filtered.where((transaction) {
        final transactionDate = transaction['date'] as DateTime;
        final endDate = _activeFilters['endDate'] as DateTime;
        return transactionDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'date':
          comparison = (a['date'] as DateTime).compareTo(b['date'] as DateTime);
          break;
        case 'amount':
          comparison = (a['amount'] as double).compareTo(b['amount'] as double);
          break;
        case 'category':
          comparison =
              (a['category'] as String).compareTo(b['category'] as String);
          break;
        case 'description':
          comparison = (a['description'] as String)
              .compareTo(b['description'] as String);
          break;
      }

      return _isAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  bool _hasActiveFilters() {
    return _activeFilters['type'] != 'all' ||
        _activeFilters['category'] != 'Semua' ||
        (_activeFilters['minAmount'] != null &&
            _activeFilters['minAmount'] > 0) ||
        _activeFilters['maxAmount'] != null ||
        _activeFilters['startDate'] != null ||
        _activeFilters['endDate'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            TransactionSearchBar(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _applyFiltersAndSort();
              },
              onFilterTap: _showFilterSheet,
              hasActiveFilters: _hasActiveFilters(),
            ),
            MonthYearPicker(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
                _applyFiltersAndSort();
              },
            ),
            Expanded(
              child: _buildTransactionList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode ? null : _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isSelectionMode
            ? '${_selectedTransactions.length} dipilih'
            : 'Riwayat Transaksi',
      ),
      leading: _isSelectionMode
          ? IconButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedTransactions.clear();
                });
              },
              icon: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            )
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _selectedTransactions.isNotEmpty ? _bulkDelete : null,
            icon: CustomIconWidget(
              iconName: 'delete',
              color: _selectedTransactions.isNotEmpty
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _selectedTransactions.isNotEmpty ? _bulkExport : null,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: _selectedTransactions.isNotEmpty
                  ? AppTheme.lightTheme.colorScheme.onSurface
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: _showSortSheet,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select_multiple',
                child: Text('Pilih Beberapa'),
              ),
              const PopupMenuItem(
                value: 'export_all',
                child: Text('Ekspor Semua'),
              ),
            ],
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionList() {
    if (_filteredTransactions.isEmpty) {
      return EmptyStateWidget(
        type: _searchQuery.isNotEmpty || _hasActiveFilters()
            ? 'no_results'
            : 'no_month_data',
        onActionPressed: () {
          if (_searchQuery.isNotEmpty || _hasActiveFilters()) {
            setState(() {
              _searchQuery = '';
              _searchController.clear();
              _activeFilters = {
                'type': 'all',
                'category': 'Semua',
                'minAmount': 0,
                'maxAmount': null,
                'startDate': null,
                'endDate': null,
              };
            });
            _applyFiltersAndSort();
          } else {
            Navigator.pushNamed(context, '/add-transaction');
          }
        },
      );
    }

    final groupedTransactions = _groupTransactionsByDate();
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: sortedDates.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= sortedDates.length) {
          return _buildLoadingIndicator();
        }

        final dateKey = sortedDates[index];
        final transactions = groupedTransactions[dateKey]!;
        final date = DateTime.parse(dateKey);

        final totalAmount = transactions.fold<double>(0, (sum, transaction) {
          final amount = transaction['amount'] as double;
          final isIncome = transaction['type'] == 'income';
          return sum + (isIncome ? amount : -amount);
        });

        return Column(
          children: [
            DateSectionHeader(
              date: date,
              totalAmount: totalAmount,
              transactionCount: transactions.length,
            ),
            ...transactions
                .map((transaction) => _buildTransactionItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isSelected = _selectedTransactions.contains(transaction['id']);

    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedTransactions.add(transaction['id'] as int);
          });
        }
      },
      onTap: _isSelectionMode
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedTransactions.remove(transaction['id']);
                  if (_selectedTransactions.isEmpty) {
                    _isSelectionMode = false;
                  }
                } else {
                  _selectedTransactions.add(transaction['id'] as int);
                }
              });
            }
          : null,
      child: Container(
        decoration: _isSelectionMode && isSelected
            ? BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
              )
            : null,
        child: Stack(
          children: [
            TransactionListItem(
              transaction: transaction,
              onTap: _isSelectionMode
                  ? null
                  : () => _viewTransactionDetail(transaction),
              onEdit: () => _editTransaction(transaction),
              onDuplicate: () => _duplicateTransaction(transaction),
              onShare: () => _shareTransaction(transaction),
              onDelete: () => _deleteTransaction(transaction),
            ),
            if (_isSelectionMode)
              Positioned(
                right: 8.w,
                top: 2.h,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 4.w,
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
      child: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 7.w,
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadMockData();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterBottomSheet(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SortOptionsSheet(
        currentSortBy: _sortBy,
        isAscending: _isAscending,
        onSortChanged: (sortBy, ascending) {
          setState(() {
            _sortBy = sortBy;
            _isAscending = ascending;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'select_multiple':
        setState(() {
          _isSelectionMode = true;
        });
        break;
      case 'export_all':
        _exportAllTransactions();
        break;
    }
  }

  void _viewTransactionDetail(Map<String, dynamic> transaction) {
    // Navigate to transaction detail or show detailed modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: EdgeInsets.only(bottom: 3.h),
              ),
              Text(
                'Detail Transaksi',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3.h),
              // Transaction details would be shown here
            ],
          ),
        ),
      ),
    );
  }

  void _editTransaction(Map<String, dynamic> transaction) {
    Navigator.pushNamed(context, '/add-transaction', arguments: transaction);
  }

  void _duplicateTransaction(Map<String, dynamic> transaction) {
    final duplicated = Map<String, dynamic>.from(transaction);
    duplicated['id'] = DateTime.now().millisecondsSinceEpoch;
    duplicated['date'] = DateTime.now();

    setState(() {
      _allTransactions.insert(0, duplicated);
    });
    _applyFiltersAndSort();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil diduplikat')),
    );
  }

  void _shareTransaction(Map<String, dynamic> transaction) {
    final text = '''
Transaksi: ${transaction['description']}
Kategori: ${transaction['category']}
Jumlah: ${_formatCurrency(transaction['amount'] as double)}
Tanggal: ${_formatDate(transaction['date'] as DateTime)}
Tipe: ${transaction['type'] == 'income' ? 'Pemasukan' : 'Pengeluaran'}
''';

    // In real app, use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berbagi: ${transaction['description']}')),
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) {
    setState(() {
      _allTransactions.removeWhere((t) => t['id'] == transaction['id']);
    });
    _applyFiltersAndSort();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaksi dihapus'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () {
            setState(() {
              _allTransactions.add(transaction);
            });
            _applyFiltersAndSort();
          },
        ),
      ),
    );
  }

  void _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
            'Hapus ${_selectedTransactions.length} transaksi yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _allTransactions.removeWhere(
            (transaction) => _selectedTransactions.contains(transaction['id']));
        _selectedTransactions.clear();
        _isSelectionMode = false;
      });
      _applyFiltersAndSort();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus')),
      );
    }
  }

  void _bulkExport() {
    final selectedTransactions = _allTransactions
        .where(
            (transaction) => _selectedTransactions.contains(transaction['id']))
        .toList();

    // In real app, export to CSV or other format
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Mengekspor ${selectedTransactions.length} transaksi')),
    );
  }

  void _exportAllTransactions() {
    // In real app, export all transactions to CSV or other format
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Mengekspor ${_filteredTransactions.length} transaksi')),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
