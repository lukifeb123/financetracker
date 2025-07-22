import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/app_version_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingText = 'Memulai aplikasi...';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Initialize offline database
      await _initializeDatabase();

      // Load user preferences
      await _loadUserPreferences();

      // Check authentication status
      await _checkAuthenticationStatus();

      // Initialize currency formatting
      await _initializeCurrencyFormatting();

      // Prepare offline financial data
      await _prepareOfflineData();

      setState(() {
        _isInitialized = true;
      });

      // Navigate after initialization
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      _handleInitializationError();
    }
  }

  Future<void> _initializeDatabase() async {
    setState(() {
      _loadingText = 'Menyiapkan database offline...';
    });

    // Simulate Hive database initialization
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock database setup for offline financial data
    final Map<String, dynamic> mockDatabaseSetup = {
      "database_version": "1.0.0",
      "tables": ["transactions", "categories", "budgets", "goals"],
      "offline_ready": true,
      "last_sync": DateTime.now().toIso8601String(),
    };

    // Simulate successful database initialization
    if (mockDatabaseSetup["offline_ready"] == true) {
      setState(() {
        _loadingText = 'Database siap digunakan';
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    setState(() {
      _loadingText = 'Memuat preferensi pengguna...';
    });

    await Future.delayed(const Duration(milliseconds: 400));

    // Mock user preferences loading
    final Map<String, dynamic> mockPreferences = {
      "theme_mode": "light",
      "currency": "IDR",
      "biometric_enabled": true,
      "notifications_enabled": true,
      "first_time_user": false,
    };

    // Simulate preference loading
    if (mockPreferences.isNotEmpty) {
      setState(() {
        _loadingText = 'Preferensi dimuat';
      });
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    setState(() {
      _loadingText = 'Memeriksa status autentikasi...';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    // Mock authentication check
    final Map<String, dynamic> mockAuthStatus = {
      "is_authenticated": true,
      "biometric_available": true,
      "last_login":
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      "session_valid": true,
    };

    if (mockAuthStatus["session_valid"] == true) {
      setState(() {
        _loadingText = 'Autentikasi berhasil';
      });
    }
  }

  Future<void> _initializeCurrencyFormatting() async {
    setState(() {
      _loadingText = 'Menyiapkan format mata uang...';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    // Mock Indonesian Rupiah formatting setup
    final Map<String, dynamic> mockCurrencySetup = {
      "currency_code": "IDR",
      "symbol": "Rp",
      "decimal_separator": ",",
      "thousand_separator": ".",
      "format_pattern": "Rp #.###.###,##",
      "locale": "id_ID",
    };

    if (mockCurrencySetup["currency_code"] == "IDR") {
      setState(() {
        _loadingText = 'Format Rupiah siap';
      });
    }
  }

  Future<void> _prepareOfflineData() async {
    setState(() {
      _loadingText = 'Menyiapkan data offline...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Mock offline data preparation
    final Map<String, dynamic> mockOfflineData = {
      "cached_transactions": 150,
      "categories_loaded": 12,
      "budgets_synced": 5,
      "goals_active": 3,
      "offline_mode_ready": true,
    };

    if (mockOfflineData["offline_mode_ready"] == true) {
      setState(() {
        _loadingText = 'Siap digunakan offline 24/7';
      });
    }
  }

  void _navigateToNextScreen() {
    // Mock navigation logic based on user status
    final bool isFirstTimeUser = false; // Mock value
    final bool isAuthenticated = true; // Mock value
    final bool biometricEnabled = true; // Mock value

    if (isFirstTimeUser) {
      // Navigate to onboarding (not implemented in this scope)
      Navigator.pushReplacementNamed(context, '/dashboard-home');
    } else if (isAuthenticated && !biometricEnabled) {
      // Navigate directly to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard-home');
    } else if (isAuthenticated && biometricEnabled) {
      // Navigate to biometric authentication (fallback to dashboard)
      Navigator.pushReplacementNamed(context, '/dashboard-home');
    } else {
      // Navigate to login (fallback to dashboard)
      Navigator.pushReplacementNamed(context, '/dashboard-home');
    }
  }

  void _handleInitializationError() {
    setState(() {
      _loadingText = 'Terjadi kesalahan, mencoba lagi...';
    });

    // Show recovery modal or retry initialization
    Future.delayed(const Duration(milliseconds: 1000), () {
      _navigateToNextScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            const BackgroundGradientWidget(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  const AnimatedLogoWidget(),

                  SizedBox(height: 8.h),

                  // Loading indicator
                  LoadingIndicatorWidget(
                    loadingText: _loadingText,
                  ),
                ],
              ),
            ),

            // App version info
            const AppVersionWidget(),
          ],
        ),
      ),
    );
  }
}
