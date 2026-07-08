import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
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
  String _selectedCategory = 'All';

  // Category options
  final List<String> _categories = ['All', 'Read', 'Write', 'Listen', 'Speak'];

  // Mock list of 25 practice cards with simplified fields
  final List<Map<String, dynamic>> _cards = [
    {
      'name': 'English video with interactive subtitles',
      'category': 'Listen',
      'desc': 'Watch English videos and tap any word in the subtitles to see its definition instantly.',
      'lastUsed': 'Just now',
      'duration': '5m',
      'tags': ['Listen', 'Subtitles'],
      'emoji': '🎥',
    },
    // Read Category (6 items)
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

        // Filter cards by selected category
        final filteredCards = _selectedCategory == 'All'
            ? _cards
            : _cards.where((c) => c['category'] == _selectedCategory).toList();

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
                children: _categories.map((category) {
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
                        category,
                        style: TextStyle(
                          color: isSelected ? colors.onPrimary : colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
