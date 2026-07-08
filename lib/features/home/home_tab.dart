import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_color_schemes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/practice_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Weekly calendar mock data
  final List<Map<String, dynamic>> _weekDays = [
    {'day': '22', 'weekday': 'Sun', 'percent': 100},
    {'day': '23', 'weekday': 'Mon', 'percent': 0},
    {'day': '24', 'weekday': 'Tue', 'percent': 75},
    {'day': '25', 'weekday': 'Wed', 'percent': 85},
    {'day': '26', 'weekday': 'Thu', 'percent': 0},
    {'day': '27', 'weekday': 'Fri', 'percent': 90},
    {'day': '28', 'weekday': 'Sat', 'percent': 60},
  ];

  // Matches the PracticeTab cards list
  final List<Map<String, dynamic>> _practiceCards = [
    {
      'name': 'English video with interactive subtitles',
      'category': 'Listen',
      'desc': 'Watch English videos and tap any word in the subtitles to see its definition instantly.',
      'lastUsed': 'Just now',
      'duration': '5m',
      'tags': ['Listen', 'Subtitles'],
      'emoji': '🎥',
    },
    {
      'name': 'Speed Reading',
      'category': 'Read',
      'desc': 'Train your eyes to scan text and summarize chapters faster.',
      'lastUsed': '2 days ago',
      'duration': '12m',
      'tags': ['Read'],
      'emoji': '📖',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final styles = AppTextStyles(textStyle, colors);

        // Distribute cards into two columns dynamically
        final List<Widget> leftWidgets = [];
        final List<Widget> rightWidgets = [];

        for (var i = 0; i < _practiceCards.length; i++) {
          final cardWidget = PracticeCard(card: _practiceCards[i], index: i);
          if (i % 2 == 0) {
            leftWidgets.add(cardWidget);
          } else {
            rightWidgets.add(cardWidget);
          }
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Custom Header
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppDimensions.scaffoldPaddingHorizontal,
                right: AppDimensions.scaffoldPaddingHorizontal,
                top: AppDimensions.lg,
                bottom: AppDimensions.sm
              ),
              sliver: SliverToBoxAdapter(
                child: Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Align(alignment: AlignmentGeometry.centerLeft,child:
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.outlineVariant, width: 1.5),
                        gradient: LinearGradient(
                          colors: [
                            theme.extension<AppColorsExtension>()?.featurePurple ?? const Color(0xFFE8D5FF),
                            theme.extension<AppColorsExtension>()?.featureYellow ?? const Color(0xFFFFF0B3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Transform.translate(
                          offset: const Offset(6, 4), // move it a little down
                          child: Transform.scale(
                            scale: 1, // zoom that image
                            child: Image.asset(
                              AppAssets.mascot1,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),),
                    Column(
                      children: [
                        Text(
                          "Hello, ${AppTheme.instance.storage.read<String>('userName') ?? 'Sandra'}",
                          style: styles.homeGreeting,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Today 25 Nov",
                          style: styles.homeDate,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // const Align(
                    //   alignment: AlignmentGeometry.centerRight,
                    //   child: NetworkStatusPill(),
                    // ),
                  ],
                ),
              ),
            ),

            // 2. Daily Challenge Card
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.scaffoldPaddingHorizontal),
              sliver: SliverToBoxAdapter(
                child: Stack(
                  alignment: AlignmentGeometry.bottomCenter,
                  children: [
                    Align(
                      alignment: AlignmentGeometry.bottomCenter,
                      child: Container(
                        height: 150,
                        padding: const EdgeInsets.all(20),
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.extension<AppColorsExtension>()?.featureLavender ?? colors.primary.withOpacity(0.8),
                              theme.extension<AppColorsExtension>()?.featurePurple ?? colors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(56),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Be Consistent",
                              style: styles.challengeTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Average of past 6 days is",
                              style: styles.challengeSubtitle,
                            ),
                            Text(
                              "10mins",
                              style: styles.calendarDayUnselected?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildOverlapAvatar(AppAssets.mascot3, 0),
                                _buildOverlapAvatar(AppAssets.mascot4, -8),
                                _buildOverlapAvatar(AppAssets.mascot1, -16),
                                Transform.translate(
                                  offset: const Offset(-24, 0),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: colors.onSurface.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "+4",
                                      style: TextStyle(
                                        color: colors.onSurface,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: Image.asset(
                        AppAssets.mascot4,
                        height: 176,
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Week Calendar Selector
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.scaffoldPaddingHorizontal, vertical: AppDimensions.md,),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekDays.indexed.map((e) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: (e.$1 == 6)?0:AppDimensions.xxs, left: (e.$1 == 0)?0:AppDimensions.xxs),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            color: e.$1 == 6 ? colors.primary : colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: e.$1 == 6 ? colors.primary : colors.outlineVariant.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (e.$2['percent'] > 0) ...[
                                const SizedBox(height: 1),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: e.$1 == 6? colors.onPrimary.withOpacity(0.85) : colors.outlineVariant,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                e.$2['weekday']!,
                                style: e.$1 == 6 ? styles.calendarWeekdaySelected : styles.calendarWeekdayUnselected,
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      value: (e.$2['percent'] as num) / 100.0,
                                      strokeWidth: 2,
                                      backgroundColor: e.$1 == 6
                                          ? colors.onPrimary.withOpacity(0.2)
                                          : colors.outlineVariant.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        e.$1 == 6 ? colors.onPrimary : colors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    e.$2['day']!,
                                    style: e.$1 == 6 ? styles.calendarDaySelected : styles.calendarDayUnselected,
                                  ),
                                ],
                              ),
                            ],
                          ),))
                    )).toList()
                  ),
                ),
              ),
            ),
            SliverPadding(padding: EdgeInsetsGeometry.only(top: AppDimensions.md)),
            // 4. "Jump Back In" Title
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.scaffoldPaddingHorizontal),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Jump Back In",
                  style: styles.homeHeadline,
                ),
              ),
            ),

            // 5. Jump Back In Practice Card List (2-column layout)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.scaffoldPaddingHorizontal,
                12,
                AppDimensions.scaffoldPaddingHorizontal,
                120, // Offset bottom navigation bar
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: leftWidgets,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: rightWidgets,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverlapAvatar(String assetPath, double leftOffset) {
    return Transform.translate(
      offset: Offset(leftOffset, 0),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).cardColor, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
