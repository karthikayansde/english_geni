import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

typedef ScaffoldWrapperBuilder = Widget Function(
    BuildContext context,
    ThemeData theme,
    TextTheme textStyle,
    ColorScheme colors,
    AppColors appColors,
    AppDimensions appDimensions,
    AppStrings appStrings,
    AppAssets appAssets,
    );

class ScaffoldWrapper extends StatelessWidget {
  final ScaffoldWrapperBuilder builder;

  const ScaffoldWrapper({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return builder(
      context,
      theme,
      theme.textTheme,
      theme.colorScheme,
      AppColors.instance,
      AppDimensions.instance,
      AppStrings.instance,
      AppAssets.instance,
    );
  }
}

class CommonScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  final bool safeArea;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool safeAreaLeft;
  final bool safeAreaRight;
  final EdgeInsetsGeometry? padding;
  final bool wrapWithScrollView;

  const CommonScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
    this.padding,
    this.wrapWithScrollView = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? bodyWidget = body;

    if (bodyWidget != null) {
      if (wrapWithScrollView) {
        bodyWidget = SingleChildScrollView(
          child: bodyWidget,
        );
      }

      if (padding != null) {
        bodyWidget = Padding(
          padding: padding!,
          child: bodyWidget,
        );
      }

      if (safeArea) {
        bodyWidget = SafeArea(
          top: safeAreaTop,
          bottom: safeAreaBottom,
          left: safeAreaLeft,
          right: safeAreaRight,
          child: bodyWidget,
        );
      }
    }

    return Scaffold(
      appBar: appBar,
      body: bodyWidget,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}