import 'package:flutter/material.dart';

/// Utility class for common UI operations
class UIUtils {
  /// Shows a success snackbar with green background
  static void showSuccessSnackBar(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Shows an error snackbar with red background
  static void showErrorSnackBar(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 6),
      ),
    );
  }

  /// Shows a warning snackbar with orange background
  static void showWarningSnackBar(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration ?? const Duration(seconds: 5),
      ),
    );
  }

  /// Shows an info snackbar with blue background
  static void showInfoSnackBar(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}