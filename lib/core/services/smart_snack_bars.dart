import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

enum NotificationType { success, error, warning, info }

class SmartSnackBars {
  // 1. Global Key to access ScaffoldMessenger without Context
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show({
    required String message,
    NotificationType type = NotificationType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.context != null) {
      showOverlay(
        Get.context!,
        message: message,
        type: type,
        duration: duration,
      );
      return;
    }

    final messenger = messengerKey.currentState;

    // Clear any existing snackbars immediately
    messenger?.removeCurrentSnackBar();

    messenger?.showSnackBar(
      SnackBar(
        duration: duration,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _getBgColor(type),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCloseIcon: true,
        content: Row(
          children: [
            Icon(_getIcon(type), color: AppColors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  // Helper to get Color based on type
  static Color _getBgColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.successGreen;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.infoBlue;
    }
  }

  // Helper to get Icon based on type
  static IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline_rounded;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  static void showOverlay(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 24,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SmartOverlayToast(
            message: message,
            type: type,
            duration: duration,
            onDismiss: () {
              try {
                overlayEntry.remove();
              } catch (_) {}
            },
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class SmartOverlayToast extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const SmartOverlayToast({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<SmartOverlayToast> createState() => _SmartOverlayToastState();
}

class _SmartOverlayToastState extends State<SmartOverlayToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after the duration (with animation fade out)
    final int fadeOutDelay = widget.duration.inMilliseconds - 250;
    Future.delayed(Duration(milliseconds: fadeOutDelay > 0 ? fadeOutDelay : 2750), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = SmartSnackBars._getBgColor(widget.type);
    final IconData iconData = SmartSnackBars._getIcon(widget.type);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                iconData,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) {
                    widget.onDismiss();
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alias to allow referencing as AppNotify
typedef AppNotify = SmartSnackBars;
