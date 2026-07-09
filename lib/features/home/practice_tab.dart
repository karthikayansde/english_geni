import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/practice_card_data.dart';
import '../../core/constants/practice_category.dart';
import '../../core/theme/app_color_schemes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../shared/widgets/practice_card.dart';

class PracticeTab extends StatefulWidget {
  const PracticeTab({super.key});

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  PracticeCategory? _selectedCategory; // null represents 'All'

  // Reference the centralized practice cards
  final List<Map<String, dynamic>> _cards = PracticeCardData.cards;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final styles = AppTextStyles(textStyle, colors);

        // Filter cards by matching the selected tag enum inside the tags list
        final filteredCards = _selectedCategory == null
            ? _cards
            : _cards.where((c) {
                final cardTags = c['tags'] as List<PracticeCategory>? ?? [];
                return cardTags.contains(_selectedCategory);
              }).toList();

        // Distribute cards into two columns dynamically
        final List<Widget> leftWidgets = [];
        final List<Widget> rightWidgets = [];

        for (var i = 0; i < filteredCards.length; i++) {
          final cardWidget = PracticeCard(card: filteredCards[i], index: i);
          if (i % 2 == 0) {
            leftWidgets.add(cardWidget);
          } else {
            rightWidgets.add(cardWidget);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Titles
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.scaffoldPaddingHorizontal,
                20,
                AppDimensions.scaffoldPaddingHorizontal,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Practice Suites", style: styles.homeHeadline),
                  const SizedBox(height: 4),
                  Text(
                    "Train your vocabulary, reading, and listening capabilities",
                    style: styles.homeCardBodyMuted,
                  ),
                ],
              ),
            ),

            // 2. Tab Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.scaffoldPaddingHorizontal - 8,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // 'All' Filter Chip
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedCategory == null ? colors.primary : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedCategory == null ? colors.primary : colors.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: _selectedCategory == null ? colors.onPrimary : colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Category Enum Chips
                  ...PracticeCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.outlineVariant.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category.displayName,
                          style: TextStyle(
                            color: isSelected ? colors.onPrimary : colors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 3. Cards Grid View
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.scaffoldPaddingHorizontal,
                  8,
                  AppDimensions.scaffoldPaddingHorizontal,
                  120, // offset bottom navigation bar overlay height
                ),
                children: [
                  Row(
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
