import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_color_schemes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import 'performance_analytics_controller.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the pre-initialized GetX Controller
    final controller = Get.find<PerformanceAnalyticsController>();

    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final styles = AppTextStyles(textStyle, colors);
        final ext = theme.extension<AppColorsExtension>()!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.scaffoldPaddingHorizontal,
            8,
            AppDimensions.scaffoldPaddingHorizontal,
            0,
          ),
          child: Column(
            children: [
              // 1. Header Titles
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  20,
                  0,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Performance Vault", style: styles.homeHeadline),
                    const SizedBox(height: 4),
                    Text(
                      "Train your vocabulary, reading, and listening capabilities",
                      style: styles.homeCardBodyMuted,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    // 1. Paginated Header Navigation and Toggle Mode
                    _buildPaginatedHeader(context, colors, styles, controller),
                    const SizedBox(height: 20),
                
                    // 2. Consistency Matrix Heatmap
                    _buildConsistencyMatrix(colors, styles, controller),
                    const SizedBox(height: 24),
                
                    // 3. Premium Paywalled Charts Section
                    Obx(() {
                      final isPro = controller.isPremium.value;
                
                      return Stack(
                        children: [
                          // Sub-list of charts (always rendered underneath)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFluencyWpmCard(colors, styles, controller),
                              const SizedBox(height: 20),
                              _buildActivityBarCard(colors, ext, styles, controller),
                              const SizedBox(height: 20),
                              _buildSkillRadarCard(colors, styles, controller),
                            ],
                          ),
                
                          // Paywall Overlay
                          if (!isPro)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Stack(
                                  children: [
                                    // Blur filter
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                        child: Container(
                                          color: colors.surfaceContainerHighest.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                
                                    // Paywall CTA card
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 24),
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: colors.outlineVariant.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.12),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: colors.primary.withOpacity(0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.analytics_rounded,
                                                size: 32,
                                                color: colors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Unlock Premium Analytics",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: colors.onSurface,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Unlock detailed speech velocity, skill radar models, and accent assessments.",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () => controller.togglePremium(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: colors.primary,
                                                foregroundColor: colors.onPrimary,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                "Unlock Now",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Month / Week Paginated Date Selector Header
  Widget _buildPaginatedHeader(
    BuildContext context,
    ColorScheme colors,
    AppTextStyles styles,
    PerformanceAnalyticsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Mode Selector (Month vs Week toggler)
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isMonth = controller.isMonthMode.value;
                  return Row(
                    children: [
                      _buildHeaderTabChip("Month", isMonth, () {
                        if (!isMonth) controller.toggleMode();
                      }, colors),
                      const SizedBox(width: 8),
                      _buildHeaderTabChip("Week", !isMonth, () {
                        if (isMonth) controller.toggleMode();
                      }, colors),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Pagination Controller row: [ < ] Month/Week label [ > ]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => controller.navigatePrevious(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                iconSize: 18,
                color: colors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary.withOpacity(0.1),
                  padding: const EdgeInsets.all(10),
                ),
              ),
              Obx(() => Text(
                    controller.dynamicHeaderLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  )),
              IconButton(
                onPressed: () => controller.navigateNext(),
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                iconSize: 18,
                color: colors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary.withOpacity(0.1),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTabChip(String label, bool isSelected, VoidCallback onTap, ColorScheme colors) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // The Consistency Matrix heat grid (Month Heatmap or Week progress)
  Widget _buildConsistencyMatrix(
    ColorScheme colors,
    AppTextStyles styles,
    PerformanceAnalyticsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Consistency Heatmap", style: styles.homeCardTitleBold),
              const Icon(Icons.grid_on_rounded, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Visual grid of daily learning contributions",
            style: styles.homeCardBodyMuted,
          ),
          const SizedBox(height: 20),

          // Monthly Calendar Grid
          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final items = controller.dailyPracticeMinutes;
            if (items.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(child: Text("No tracking data available")),
              );
            }

            final dayKeys = items.keys.toList()..sort();

            // Render weekdays layout header (Mon, Tue...)
            final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekdays.map((d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),

                // Heatmap Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayKeys.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final dayDate = dayKeys[index];
                    final minutes = items[dayDate] ?? 0;

                    // Heatmap colors based on contribution duration
                    Color tileColor;
                    if (minutes == 0) {
                      tileColor = colors.surfaceContainerHighest.withOpacity(0.2);
                    } else if (minutes <= 15) {
                      tileColor = colors.primary.withOpacity(0.25);
                    } else if (minutes <= 30) {
                      tileColor = colors.primary.withOpacity(0.5);
                    } else if (minutes <= 45) {
                      tileColor = colors.primary.withOpacity(0.75);
                    } else {
                      tileColor = colors.primary;
                    }

                    return Tooltip(
                      message: "${dayDate.day} ${dayDate.month}: $minutes mins",
                      child: Container(
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            "${dayDate.day}",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: minutes > 30 ? colors.onPrimary : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // WPM Line Chart Card
  Widget _buildFluencyWpmCard(
    ColorScheme colors,
    AppTextStyles styles,
    PerformanceAnalyticsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Fluency Velocity", style: styles.homeCardTitleBold),
          Text("User speech speed in Words Per Minute (WPM)", style: styles.homeCardBodyMuted),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              final wpmPoints = controller.fluencyVelocityWPM;
              if (wpmPoints.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return LineChart(
                LineChartData(
                  minY: 80,
                  maxY: 180,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 140,
                        color: colors.primary.withOpacity(0.4),
                        strokeWidth: 1.5,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          labelResolver: (line) => "Native Base (140 WPM)",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: wpmPoints.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: colors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primary.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Stacked Bar Chart Card
  Widget _buildActivityBarCard(
    ColorScheme colors,
    AppColorsExtension ext,
    AppTextStyles styles,
    PerformanceAnalyticsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Activity Distribution", style: styles.homeCardTitleBold),
          Text("Minutes spent across active modules", style: styles.homeCardBodyMuted),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              final watch = controller.activityWatch;
              final speak = controller.activitySpeak;
              final drills = controller.activityDrills;

              if (watch.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final watchVal = watch[i];
                    final speakVal = speak[i];
                    final drillsVal = drills[i];
                    final total = watchVal + speakVal + drillsVal;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: total,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                          rodStackItems: [
                            BarChartRodStackItem(0, watchVal, ext.featureBlue ?? Colors.blue),
                            BarChartRodStackItem(watchVal, watchVal + speakVal, ext.featureOrange ?? Colors.orange),
                            BarChartRodStackItem(watchVal + speakVal, total, ext.featurePurple ?? Colors.purple),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendTile("Watch", ext.featureBlue ?? Colors.blue),
              const SizedBox(width: 16),
              _buildLegendTile("Speak", ext.featureOrange ?? Colors.orange),
              const SizedBox(width: 16),
              _buildLegendTile("Drills", ext.featurePurple ?? Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendTile(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Radar Chart Card
  Widget _buildSkillRadarCard(
    ColorScheme colors,
    AppTextStyles styles,
    PerformanceAnalyticsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 320,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Skill Equilibrium", style: styles.homeCardTitleBold),
          Text("Pronunciation, fluency, grammar profile mapping", style: styles.homeCardBodyMuted),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final equilibrium = controller.skillEquilibrium;
              if (equilibrium.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RadarChart(
                RadarChartData(
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  gridBorderData: BorderSide(color: colors.outlineVariant.withOpacity(0.3), width: 1),
                  tickBorderData: BorderSide(color: colors.outlineVariant.withOpacity(0.3), width: 1),
                  ticksTextStyle: TextStyle(color: colors.onSurface.withOpacity(0.5), fontSize: 8),
                  titlePositionPercentageOffset: 0.15,
                  titleTextStyle: TextStyle(color: colors.onSurface, fontSize: 10, fontWeight: FontWeight.bold),
                  dataSets: [
                    RadarDataSet(
                      fillColor: colors.primary.withOpacity(0.18),
                      borderColor: colors.primary,
                      entryRadius: 3,
                      dataEntries: equilibrium.map((val) => RadarEntry(value: val)).toList(),
                    ),
                  ],
                  getTitle: (index, angle) {
                    const titles = ["Pronunciation", "Fluency", "Listening", "Vocabulary", "Grammar"];
                    return RadarChartTitle(text: titles[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
