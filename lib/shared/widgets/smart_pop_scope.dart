import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_strings.dart';

class SmartPopScope extends StatefulWidget {
  final Widget child;
  final bool canPop;
  final VoidCallback? onPopInvoked;
  final String exitMessage;
  final bool doublePress;

  const SmartPopScope({
    super.key,
    required this.child,
    this.canPop = false,
    this.onPopInvoked,
    this.exitMessage = AppStrings.backPressExit,
    this.doublePress = true,
  });

  @override
  State<SmartPopScope> createState() => _SmartPopScopeState();
}

class _SmartPopScopeState extends State<SmartPopScope> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (!widget.doublePress) {
          if (widget.onPopInvoked != null) {
            widget.onPopInvoked!();
          } else {
            SystemNavigator.pop();
          }
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.exitMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (widget.onPopInvoked != null) {
            widget.onPopInvoked!();
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: widget.child,
    );
  }
}
