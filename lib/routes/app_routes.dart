import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/category_management/category_management.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';
import '../presentation/add_transaction/add_transaction.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/data_import/data_import_screen.dart';
import '../presentation/receipt_scanner/receipt_scanner_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String categoryManagement = '/category-management';
  static const String dashboardHome = '/dashboard-home';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String addTransaction = '/add-transaction';
  static const String transactionHistory = '/transaction-history';
  static const String dataImport = '/data-import';
  static const String receiptScanner = '/receipt-scanner';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    categoryManagement: (context) => const CategoryManagement(),
    dashboardHome: (context) => const DashboardHome(),
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    addTransaction: (context) => const AddTransaction(),
    transactionHistory: (context) => const TransactionHistory(),
    dataImport: (context) => const DataImportScreen(),
    receiptScanner: (context) => const ReceiptScannerScreen(),
    // TODO: Add your other routes here
  };
}
