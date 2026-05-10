import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.connectionState,
    required this.hasError,
    required this.isEmpty,
    required this.child,
    this.errorMessage,
    this.emptyMessage = 'No data available',
  });

  final ConnectionState connectionState;
  final bool hasError;
  final bool isEmpty;
  final Widget child;
  final String? errorMessage;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return Center(
        child: Text(
          errorMessage ?? 'Failed to load data',
          style: const TextStyle(color: Color(AppColors.danger)),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (isEmpty) return Center(child: Text(emptyMessage));
    return child;
  }
}
