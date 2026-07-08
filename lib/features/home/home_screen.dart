import 'package:english_geni/core/services/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import 'home_tab.dart';
import 'practice_tab.dart';
import 'progress_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                InternetWrapper(
                  child: PageView(
                    controller: _pageController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: const [
                      HomeTab(),
                      PracticeTab(),
                      ProgressTab(),
                      ProfileTab(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  child: _buildFloatingNavBar(context, colors, isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, ColorScheme colors, bool isDark) {
    // 1. BG of nav bar
    final navBarBgColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    // 2. Circle color
    final circleColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // 3. Icon color (opposite from circle for selected, readable contrast for unselected)
    final activeIconColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final inactiveIconColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      height: 70,
      // width: (70 * 4 + 4 * 3) - 10,
      width: (70*4+4*3)+2,
      decoration: BoxDecoration(
        color: navBarBgColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background sliding white circle indicator
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const spacing = AppDimensions.xs;
                final slotWidth = (width - (3 * spacing)) / 4;
                const circleWidth = 67.0;
                final leftPadding = (slotWidth - circleWidth) / 2;
                final leftPos = leftPadding + (_pageOffset * (slotWidth + spacing));

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: leftPos,
                      child: Container(
                        width: circleWidth,
                        height: circleWidth,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Foreground icons
          Row(
            children: [
              _buildNavItem(0, AppAssets.icHome, activeIconColor, inactiveIconColor),
              const SizedBox(width: AppDimensions.xs),
              _buildNavItem(1, AppAssets.icCategory, activeIconColor, inactiveIconColor),
              const SizedBox(width: AppDimensions.xs),
              _buildNavItem(2, AppAssets.icProgress, activeIconColor, inactiveIconColor),
              const SizedBox(width: AppDimensions.xs),
              _buildNavItem(3, AppAssets.icProfile, activeIconColor, inactiveIconColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String assetPath, Color activeColor, Color inactiveColor) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? activeColor : inactiveColor;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic, // Beautiful, fluid ease-out animation
          );
        },
        child: SizedBox(
          height: 70,
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}
