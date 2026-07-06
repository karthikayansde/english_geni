import 'package:english_geni/shared/widgets/smart_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

class TopHeadImage extends StatelessWidget {
  const TopHeadImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 0.60,
          child: RotatedBox(
            quarterTurns: 2,
            child: SmartImage.assetRaster(
              path: AppAssets.mascot3,
              height: 350.0,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
