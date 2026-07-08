import 'package:flutter/material.dart';
import '../../core/theme/app_color_schemes.dart';
import '../../core/theme/app_text_styles.dart';

class PracticeCard extends StatelessWidget {
  final Map<String, dynamic> card;
  final int index;

  const PracticeCard({
    super.key,
    required this.card,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final styles = AppTextStyles(theme.textTheme, colors);
    final ext = theme.extension<AppColorsExtension>()!;

    // 5 cyclic background colors
    final colorsList = [
      ext.featureOrange,
      ext.featureBlue,
      ext.featurePink,
      ext.featurePurple,
      ext.featureMint,
    ];
    // Safeguard index checking for safe fallback
    final cardBgColor = colorsList[index % 5] ?? ext.featurePurple ?? colors.secondaryContainer;

    final name = card['name'] as String;
    final desc = card['desc'] as String?;
    final hasDesc = desc != null && desc.isNotEmpty;

    final lastUsed = card['lastUsed'] as String?;
    final duration = card['duration'] as String?;
    final hasLastUsed = lastUsed != null && lastUsed.isNotEmpty;
    final hasDuration = duration != null && duration.isNotEmpty;
    final showFooter = hasLastUsed || hasDuration;
    final tags = card['tags'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: cardBgColor,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(56),
          side: BorderSide(
            color: colors.outlineVariant.withOpacity(0.25),
            width: 1,
          ),
        ),
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(47),
          ),
        ),
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
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.onSurface.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag.toString().toUpperCase(),
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
                    name,
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
