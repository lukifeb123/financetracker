import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BackgroundGradientWidget extends StatelessWidget {
  const BackgroundGradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            AppTheme.lightTheme.colorScheme.secondary,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
