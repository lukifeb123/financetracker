import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gemini_service.dart';
import './widgets/ai_insights_widget.dart';
import './widgets/balance_card_widget.dart';
import './widgets/budget_progress_widget.dart';
import './widgets/expense_income_chart_widget.dart';
import './widgets/month_navigation_widget.dart';
import './widgets/quick_transaction_bottom_sheet.dart';
import './widgets/recent_transactions_widget.dart';
import './widgets/top_categories_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime _currentDate = DateTime.now();
  bool _isBalanceVisible = true;
  bool _showAIInsights = false;

  // Sample transactions data (replace mock data with real data from Gemini)
  final List<Map<String, dynamic>> _transactions = [
    {
      "id": 1,
      "type": "expense",
      "amount": 45000.0,
      "category": "Makanan",
      "description": "Makan siang di restoran",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "type": "income",
      "amount": 2500000.0,
      "category": "Gaji",
      "description": "Gaji bulan ini",
      "date": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 3,
      "type": "expense",
      "amount": 25000.0,
      "category": "Transportasi",
      "description": "Ongkos ojek online",
      "date": DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      "id": 4,
      "type": "expense",
      "amount": 150000.0,
      "category": "Belanja",
      "description": "Belanja bulanan",
      "date": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 5,
      "type": "expense",
      "amount": 75000.0,
      "category": "Hiburan",
      "description": "Nonton bioskop",
      "date": DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  final List<Map<String, dynamic>> _monthlyData = [
    {"income": 2500000.0, "expense": 800000.0},
    {"income": 2300000.0, "expense": 950000.0},
    {"income": 2700000.0, "expense": 750000.0},
    {"income": 2600000.0, "expense": 1200000.0},
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      "name": "Makanan",
      "amount": 450000.0,
      "percentage": 35.0,
      "transactionCount": 15,
    },
    {
      "name": "Transportasi",
      "amount": 300000.0,
      "percentage": 23.0,
      "transactionCount": 8,
    },
    {
      "name": "Belanja",
      "amount": 250000.0,
      "percentage": 19.0,
      "transactionCount": 5,
    },
    {
      "name": "Hiburan",
      "amount": 200000.0,
      "percentage": 15.0,
      "transactionCount": 4,
    },
    {
      "name": "Kesehatan",
      "amount": 100000.0,
      "percentage": 8.0,
      "transactionCount": 2,
    },
  ];

  final List<Map<String, dynamic>> _budgets = [
    {
      "category": "Makanan",
      "budgetAmount": 500000.0,
      "spentAmount": 450000.0,
    },
    {
      "category": "Transportasi",
      "budgetAmount": 300000.0,
      "spentAmount": 280000.0,
    },
    {
      "category": "Hiburan",
      "budgetAmount": 200000.0,
      "spentAmount": 195000.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeGeminiService();
  }

  void _initializeGeminiService() {
    try {
      final geminiService = GeminiService();
      setState(() {
        _showAIInsights = true;
      });
    } catch (e) {
      print('Gemini AI not available: $e');
      // AI insights will be hidden if Gemini is not properly configured
    }
  }

  double get _totalBalance {
    double income = 0;
    double expense = 0;

    for (final transaction in _transactions) {
      final amount = transaction['amount'] as double;
      if ((transaction['type'] as String) == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
    }

    return income - expense;
  }

  double get _totalIncome {
    return (_transactions
        .where((t) => (t['type'] as String) == 'income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double)));
  }

  double get _totalExpense {
    return (_transactions
        .where((t) => (t['type'] as String) == 'expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double)));
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/transaction-history');
        break;
      case 2:
        Navigator.pushNamed(context, '/analytics-dashboard');
        break;
      case 3:
        Navigator.pushNamed(context, '/category-management');
        break;
      case 4:
        // Profile - show menu
        _showProfileMenu();
        break;
    }
  }

  void _showProfileMenu() {
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
              'Menu Tambahan',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_upload',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Import Data CSV/Excel'),
              subtitle: Text('Impor transaksi dari file'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/data-import');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'document_scanner',
                color: AppTheme.getAccentColor(true),
                size: 6.w,
              ),
              title: Text('Scan Struk'),
              subtitle: Text('Auto-deteksi transaksi dari struk'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/receipt-scanner');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });

    HapticFeedback.lightImpact();
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  void _onTransactionTap(Map<String, dynamic> transaction) {
    // Navigate to transaction detail or edit
    Navigator.pushNamed(context, '/add-transaction');
  }

  void _onEditTransaction(Map<String, dynamic> transaction) {
    Navigator.pushNamed(context, '/add-transaction');
  }

  void _onDuplicateTransaction(Map<String, dynamic> transaction) {
    final duplicatedTransaction = Map<String, dynamic>.from(transaction);
    duplicatedTransaction['id'] = DateTime.now().millisecondsSinceEpoch;
    duplicatedTransaction['date'] = DateTime.now();

    setState(() {
      _transactions.insert(0, duplicatedTransaction);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil diduplikasi'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _onDeleteTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _transactions.removeWhere((t) => t['id'] == transaction['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaksi berhasil dihapus'),
                  backgroundColor: AppTheme.errorLight,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/analytics-dashboard');
  }

  void _onBudgetTap(Map<String, dynamic> budget) {
    Navigator.pushNamed(context, '/analytics-dashboard');
  }

  void _showQuickTransactionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => QuickTransactionBottomSheet(
        onTransactionAdded: (transaction) {
          setState(() {
            _transactions.insert(0, transaction);
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Refresh data here
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // Sticky Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: MonthNavigationWidget(
                    currentDate: _currentDate,
                    onPreviousMonth: _navigateToPreviousMonth,
                    onNextMonth: _navigateToNextMonth,
                  ),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Balance Card
                    BalanceCardWidget(
                      totalBalance: _totalBalance,
                      onPrivacyToggle: _toggleBalanceVisibility,
                      isBalanceVisible: _isBalanceVisible,
                    ),

                    // AI Insights (only show if Gemini is configured)
                    if (_showAIInsights)
                      AIInsightsWidget(
                        transactions: _transactions,
                        currentMonth: _currentDate,
                      ),

                    // Recent Transactions
                    RecentTransactionsWidget(
                      transactions: _transactions,
                      onTransactionTap: _onTransactionTap,
                      onEditTransaction: _onEditTransaction,
                      onDuplicateTransaction: _onDuplicateTransaction,
                      onDeleteTransaction: _onDeleteTransaction,
                    ),

                    SizedBox(height: 2.h),

                    // Expense vs Income Chart
                    ExpenseIncomeChartWidget(
                      totalIncome: _totalIncome,
                      totalExpense: _totalExpense,
                      monthlyData: _monthlyData,
                    ),

                    // Top Categories
                    TopCategoriesWidget(
                      categories: _categories,
                      onCategoryTap: _onCategoryTap,
                    ),

                    // Budget Progress
                    BudgetProgressWidget(
                      budgets: _budgets,
                      onBudgetTap: _onBudgetTap,
                    ),

                    SizedBox(height: 10.h), // Bottom padding for FAB
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'receipt_long',
              color: _currentIndex == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: _currentIndex == 2
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Analitik',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'category',
              color: _currentIndex == 3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 4
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Menu',
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickTransactionBottomSheet,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Tambah',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 12.h;

  @override
  double get maxExtent => 12.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
