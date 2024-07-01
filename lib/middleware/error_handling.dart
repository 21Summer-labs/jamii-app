// lib/middleware/error_handling.dart

import 'package:flutter/material.dart';

class ErrorHandlingMiddleware {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static Future<T> handleFuture<T>(
    BuildContext context,
    Future<T> future,
    {String errorMessage = 'An error occurred'}) async {
    try {
      return await future;
    } catch (e) {
      showError(context, '$errorMessage: $e');
      rethrow;
    }
  }
}