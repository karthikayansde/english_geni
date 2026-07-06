import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import 'smart_form_field_theme.dart';

class SmartPrimaryButton extends StatefulWidget {
  final String label;
  final Future<void> Function()? onPressed;
  final bool autoLoading;
  final bool isLoading; // Only respected when autoLoading = false
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final bool isDisable;
  final bool clearFocus;
  final bool isOutlined;
  final String? heroTag;

  SmartPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.autoLoading = false,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.isDisable = false,
    this.clearFocus = false,
    this.isOutlined = false,
    this.heroTag
  }) {
    assert(
    !(autoLoading && isLoading),
    'Do not use both autoLoading and isLoading together.',
    );
  }

  @override
  State<SmartPrimaryButton> createState() => _SmartPrimaryButtonState();
}

class _SmartPrimaryButtonState extends State<SmartPrimaryButton> {
  bool _internalLoading = false;

  // Resolves which loading state to show:
  // - autoLoading=true  → use internal _internalLoading
  // - autoLoading=false → use parent-controlled widget.isLoading
  bool get _effectiveLoading =>
      widget.autoLoading ? _internalLoading : widget.isLoading;

  Future<void> _handlePress() async {
    if (widget.clearFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (widget.autoLoading) {
      setState(() => _internalLoading = true);
      try {
        await widget.onPressed?.call();
      } finally {
        // Always reset loading even if onPressed throws
        if (mounted) setState(() => _internalLoading = false);
      }
    } else {
      await widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final effectiveTextColor = widget.isOutlined
        ? effectiveBackgroundColor
        : theme.colorScheme.onPrimary;

    final bool isButtonDisabled = _effectiveLoading || widget.isDisable || widget.onPressed == null;

    final borderRadius =
    BorderRadius.circular(SmartFormFieldTheme.radius);

    final shape = RoundedRectangleBorder(borderRadius: borderRadius);

    final buttonStyle = widget.isOutlined
        ? OutlinedButton.styleFrom(
      foregroundColor: effectiveTextColor,
      disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.4),
      side: BorderSide(
        color: isButtonDisabled
            ? effectiveBackgroundColor.withValues(alpha: 0.4)
            : effectiveBackgroundColor,
      ),
      shape: shape,
      padding: const EdgeInsets.symmetric(horizontal: 24),
    )
        : ElevatedButton.styleFrom(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveTextColor,
      disabledBackgroundColor: effectiveBackgroundColor.withValues(alpha: 0.4),
      disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.6),
      shape: shape,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24),
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: widget.icon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(widget.icon, size: 20),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _effectiveLoading
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );

    final Widget button = SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: widget.isOutlined
          ? OutlinedButton(
        onPressed: isButtonDisabled ? null : _handlePress,
        style: buttonStyle,
        child: child,
      )
          : ElevatedButton(
        onPressed: isButtonDisabled ? null : _handlePress,
        style: buttonStyle,
        child: child,
      ),
    );

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: button,
      );
    }

    return button;
  }
}

//----------------------------------------------------------------------------------------------------------

class StyledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double iconSize;
  final double? buttonSize;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsets? padding;
  final bool isOutlined;
  const StyledIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize = 24,
    this.buttonSize = AppDimensions.iconLg,
    this.borderRadius = AppDimensions.radiusLg,
    this.backgroundColor,
    this.iconColor,
    this.padding,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: isOutlined
            ? Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: Icon(
              icon,
              color: Theme.of(context).textTheme.bodyLarge!.color,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

//----------------------------------------------------------------------------------------------------------

class SmartFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? heroTag;
  final Color? backgroundColor;
  final Widget child;
  const SmartFAB({super.key, required this.onPressed, required this.heroTag, this.backgroundColor, required this.child});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}