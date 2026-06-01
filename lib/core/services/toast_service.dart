import 'package:flutter/material.dart';

abstract class IToastService {
  void showSuccess(String message);
  void showError(String message);
  void showInfo(String message);
  void showWarning(String message);
}

class ToastService implements IToastService {
  ToastService({required GlobalKey<ScaffoldMessengerState> messengerKey})
    : _messengerKey = messengerKey;

  final GlobalKey<ScaffoldMessengerState> _messengerKey;

  @override
  void showSuccess(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF6B8E5A),
      icon: Icons.check_circle,
    );
  }

  @override
  void showError(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFB85C4A),
      icon: Icons.error,
    );
  }

  @override
  void showInfo(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF4A7FA5),
      icon: Icons.info,
    );
  }

  @override
  void showWarning(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFD4A047),
      icon: Icons.warning,
    );
  }

  void _showToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
