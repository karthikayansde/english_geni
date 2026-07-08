import 'package:flutter/material.dart';
import '../../core/utils/u_device_helper.dart';

typedef ScaffoldWrapperBuilder = Widget Function(
    BuildContext context,
    ThemeData theme,
    TextTheme textStyle,
    ColorScheme colors,);

class ScaffoldWrapper extends StatelessWidget {
  final ScaffoldWrapperBuilder builder;
  const ScaffoldWrapper({super.key, required this.builder});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    UDeviceHelper.setStatusBarColor(context);
    return builder(
      context,
      theme,
      theme.textTheme,
      theme.colorScheme,
    );
  }
}