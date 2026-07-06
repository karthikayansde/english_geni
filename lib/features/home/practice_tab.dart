import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_color_schemes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';

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
        final ext = theme.extension<AppColorsExtension>()!;

        // Filter cards by selected category
        final filteredCards = _selectedCategory == 'All'
            ? _cards
            : _cards.where((c) => c['category'] == _selectedCategory).toList();

        // Distribute cards into two columns dynamically
        final List<Widget> leftWidgets = [];
        final List<Widget> rightWidgets = [];

        for (var i = 0; i < filteredCards.length; i++) {
          final cardWidget = _buildStaggeredCard(filteredCards[i], i, ext, colors, styles);
          if (i % 2 == 0) {
            leftWidgets.add(cardWidget);
          } else {
            rightWidgets.add(cardWidget);
          }
        }

        return SafeArea(
          bottom: false,
          child: Column(
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
          ),
        );
      },
    );
  }

  Widget _buildStaggeredCard(
    Map<String, dynamic> card,
    int index,
    AppColorsExtension ext,
    ColorScheme colors,
    AppTextStyles styles,
  ) {
    // 5 cyclic background colors
    final colorsList = [
      ext.featureOrange,
      ext.featureBlue,
      ext.featurePink,
      ext.featurePurple,
      ext.featureMint,
    ];
    final cardBgColor = colorsList[index % 5];

    final desc = card['desc'] as String?;
    final hasDesc = desc != null && desc.isNotEmpty;

    final lastUsed = card['lastUsed'] as String?;
    final duration = card['duration'] as String?;
    final hasLastUsed = lastUsed != null && lastUsed.isNotEmpty;
    final hasDuration = duration != null && duration.isNotEmpty;
    final showFooter = hasLastUsed || hasDuration;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // Watermark background emoji (partially overflowing from bottom right)
            Positioned(
              right: -16,
              bottom: -16,
              child: Opacity(
                opacity: 0.16, // premium blend watermark
                child: Text(
                  card['emoji'] ?? '',
                  style: const TextStyle(
                    fontSize: 72,
                  ),
                ),
              ),
            ),
            
            // Foreground content column
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top tag row (miniature capability chips)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (card['tags'] as List<String>).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          color: colors.onSurface.withOpacity(0.7),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Name of the Card
                  Text(
                    card['name'] as String,
                    style: styles.homeCardTitleBold?.copyWith(
                      color: colors.onSurface,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),

                  // Description (if present)
                  if (hasDesc) ...[
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: TextStyle(
                        color: colors.onSurfaceVariant.withOpacity(0.85),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],

                  if (showFooter) ...[
                    const SizedBox(height: 16),
                    // Footer (Last Used / Duration tag)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 11,
                          color: colors.onSurfaceVariant.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${hasLastUsed ? lastUsed : ''}${hasLastUsed && hasDuration ? ' • ' : ''}${hasDuration ? duration : ''}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
