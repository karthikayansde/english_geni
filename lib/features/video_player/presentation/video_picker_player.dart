import 'package:get/get.dart';
import 'dart:ui' show ImageFilter;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import '../../../core/constants/app_dimensions.dart';
import '../state_management/video_screen_controller.dart';
import 'package:english_geni/shared/widgets/smart_form_fields/smart_buttons.dart';
import 'package:go_router/go_router.dart';

class VideoPickerPlayer extends StatelessWidget {
  const VideoPickerPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoScreenController());

    return Scaffold(
      body:
      Obx(() {
        if (controller.videoPath.isEmpty) {
          final theme = Theme.of(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.scaffoldPaddingHorizontal,
                  vertical: AppDimensions.scaffoldPaddingHorizontal),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.onSurface, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '🎥',
                            style: TextStyle(
                              fontSize: 64,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "English video with interactive subtitles",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            "Watch English videos and tap any word in the subtitles to see its definition instantly.",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SmartPrimaryButton(
                          label: "Open Video",
                          onPressed: () => controller.pickAndPlayVideo(context),
                          icon: Icons.add_rounded,
                          width: 220,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            // Video Player
            Center(
              child: GestureDetector(
                onTap: controller.toggleControls,
                onDoubleTap: controller.togglePlayPause,
                child: Obx(() => Video(
                  aspectRatio: controller.getAspectRatio(context),
                  fit: controller.getBoxFit(),
                  controller: controller.videoController!,
                  controls: NoVideoControls,
                  subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
                )),
              ),
            ),

            // Gesture Detectors for Volume, Brightness, Play/Pause, Rewind & Forward
            Row(
              children: [
                // Left 30%: Brightness + Double Tap Rewind 5s
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) => controller.handleVerticalDrag(details, true),
                    onTap: controller.toggleControls,
                    onDoubleTap: () => controller.rewindSeconds(5),
                    onLongPressStart: (_) => controller.startLongPressSpeed(),
                    onLongPressEnd: (_) => controller.endLongPressSpeed(),
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Center 40%: Double Tap Toggle Play/Pause
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: controller.toggleControls,
                    onDoubleTap: controller.togglePlayPause,
                    onLongPressStart: (_) => controller.startLongPressSpeed(),
                    onLongPressEnd: (_) => controller.endLongPressSpeed(),
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Right 30%: Volume + Double Tap Fast Forward 5s
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) => controller.handleVerticalDrag(details, false),
                    onTap: controller.toggleControls,
                    onDoubleTap: () => controller.fastForwardSeconds(5),
                    onLongPressStart: (_) => controller.startLongPressSpeed(),
                    onLongPressEnd: (_) => controller.endLongPressSpeed(),
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),

            // Double Tap Action Indicator Overlay
            Obx(() {
              final icon = controller.activeDoubleTapIcon.value;
              if (icon == null) return const SizedBox.shrink();
              return IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              );
            }),

            // Brightness indicator
            if (controller.showBrightnessIndicator.value)
              _buildIndicator(
                Icons.brightness_6,
                controller.currentBrightness.value,
              ),

            // Volume indicator
            if (controller.showVolumeIndicator.value)
              _buildIndicator(
                Icons.volume_up,
                controller.currentVolume.value,
              ),

            // // Speed indicator
            // Obx(() {
            //   if (controller.isFastForwarding.value) {
            //     return Positioned(
            //       top: 50,
            //       left: 0,
            //       right: 0,
            //       child: Center(
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //           decoration: BoxDecoration(
            //             color: Colors.black54,
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           child: Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               const Icon(Icons.fast_forward, color: Colors.white),
            //               const SizedBox(width: 8),
            //               Text(
            //                 "${controller.playbackRate.value}x",
            //                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     );
            //   }
            //   return const SizedBox.shrink();
            // }),

            // Long Press 2X Speed Indicator at the Center Top
            Obx(() {
              if (!controller.isLongPressSpeeding.value) return const SizedBox.shrink();
              return Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fast_forward_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "2X Speed",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Custom UI Controls (Overlay)
            AnimatedOpacity(
              opacity: controller.showControls.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !controller.showControls.value,
                child: Stack(
                  children: [


                    // Top Bar (File Name + CC + Audio Tracks selection with blur bg)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            padding: const EdgeInsets.only(top: 40, bottom: 12, left: 16, right: 16),
                            color: Colors.black.withOpacity(0.45),
                            child: Row(
                              children: [
                                if (context.canPop()) ...[
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                                    onPressed: () => context.pop(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      controller.fileName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => controller.showAudioTracksDialog(context),
                                  icon: const Icon(Icons.audiotrack_rounded, color: Colors.white, size: 26),
                                  tooltip: 'Audio Tracks',
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => controller.showTracksSelectionDialog(context),
                                  icon: const Icon(Icons.closed_caption_rounded, color: Colors.white, size: 28),
                                  tooltip: 'Subtitles & Captions',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),



                    // Bottom Bar (Progress + Controls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
                        color: Colors.black.withOpacity(0.65),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildProgressBar(controller, context),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildControls(controller),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Builder(
                                        builder: (buttonContext) {
                                          return IconButton(
                                            onPressed: () {
                                              showPopover(
                                                context: buttonContext,
                                                bodyBuilder: (popoverContext) {
                                                  final options = [
                                                    'original',
                                                    '16:9',
                                                    '18:9',
                                                    '4:3',
                                                    'fit to screen',
                                                  ];
                                                  return Container(
                                                    color: const Color(0xFF1E1E2E),
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: options.map((option) {
                                                          return Obx(() {
                                                            final isSelected = controller.selectedAspectRatio.value == option;
                                                            return ListTile(
                                                              dense: true,
                                                              leading: Icon(
                                                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                                                color: isSelected ? Colors.blueAccent : Colors.white54,
                                                                size: 18,
                                                              ),
                                                              title: Text(
                                                                option == 'original'
                                                                    ? 'Original'
                                                                    : option == 'fit to screen'
                                                                    ? 'Fit Screen'
                                                                    : option,
                                                                style: TextStyle(
                                                                  color: isSelected ? Colors.white : Colors.white70,
                                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                controller.selectedAspectRatio.value = option;
                                                                Navigator.of(popoverContext).pop();
                                                              },
                                                            );
                                                          });
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                direction: PopoverDirection.top,
                                                width: 180,
                                                height: 250,
                                                backgroundColor: const Color(0xFF1E1E2E),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.aspect_ratio_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            tooltip: 'Aspect Ratio',
                                          );
                                        }
                                    ),
                                    Builder(
                                        builder: (buttonContext) {
                                          return IconButton(
                                            onPressed: () {
                                              showPopover(
                                                context: buttonContext,
                                                bodyBuilder: (popoverContext) {
                                                  final options = [
                                                    {'value': 'auto', 'label': 'Auto (Sensor)'},
                                                    {'value': 'landscape_left', 'label': 'Landscape Left'},
                                                    {'value': 'landscape_right', 'label': 'Landscape Right'},
                                                    {'value': 'portrait', 'label': 'Portrait Lock'},
                                                  ];
                                                  return Container(
                                                    color: const Color(0xFF1E1E2E),
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: options.map((option) {
                                                          return Obx(() {
                                                            final val = option['value']!;
                                                            final isSelected = controller.orientationMode.value == val;
                                                            return ListTile(
                                                              dense: true,
                                                              leading: Icon(
                                                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                                                color: isSelected ? Colors.blueAccent : Colors.white54,
                                                                size: 18,
                                                              ),
                                                              title: Text(
                                                                option['label']!,
                                                                style: TextStyle(
                                                                  color: isSelected ? Colors.white : Colors.white70,
                                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                controller.setOrientationMode(val);
                                                                Navigator.of(popoverContext).pop();
                                                              },
                                                            );
                                                          });
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                direction: PopoverDirection.top,
                                                width: 200,
                                                height: 200,
                                                backgroundColor: const Color(0xFF1E1E2E),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.screen_rotation,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            tooltip: 'Rotate Screen',
                                          );
                                        }
                                    ),
                                    Builder(
                                      builder: (buttonContext) {
                                        return IconButton(
                                          onPressed: () {
                                            showPopover(
                                              context: buttonContext,
                                              bodyBuilder: (popoverContext) {
                                                final speedValues = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0];
                                                return Container(
                                                  color: const Color(0xFF1E1E2E),
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Obx(() => Text(
                                                        "Speed: ${controller.playbackRate.value}x",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      )),
                                                      const SizedBox(height: 12),
                                                      Obx(() {
                                                        final currentIdx = speedValues.indexOf(controller.playbackRate.value);
                                                        final double sliderVal = (currentIdx == -1 ? 1 : currentIdx).toDouble();
                                                        return SliderTheme(
                                                          data: SliderTheme.of(popoverContext).copyWith(
                                                            activeTrackColor: Colors.blueAccent,
                                                            inactiveTrackColor: Colors.white24,
                                                            thumbColor: Colors.blueAccent,
                                                            overlayColor: Colors.blueAccent.withOpacity(0.2),
                                                            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                                                            showValueIndicator: ShowValueIndicator.always,
                                                          ),
                                                          child: Slider(
                                                            value: sliderVal,
                                                            min: 0.0,
                                                            max: 5.0,
                                                            divisions: 5,
                                                            onChanged: (val) {
                                                              controller.setPlaybackRate(speedValues[val.toInt()]);
                                                            },
                                                          ),
                                                        );
                                                      }),
                                                      const SizedBox(height: 8),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: speedValues.map((s) {
                                                            return Obx(() {
                                                              final isSelected = controller.playbackRate.value == s;
                                                              return Text(
                                                                "${s}x",
                                                                style: TextStyle(
                                                                  color: isSelected ? Colors.blueAccent : Colors.white54,
                                                                  fontSize: 10,
                                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                                ),
                                                              );
                                                            });
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              direction: PopoverDirection.top,
                                              width: 280,
                                              height: 140,
                                              backgroundColor: const Color(0xFF1E1E2E),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.speed_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          tooltip: 'Playback Speed',
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Subtitle Overlay
            Obx(() {
              if (controller.currentSubtitleText.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Positioned(
                bottom: controller.showControls.value ? 130.0 : 40.0,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.subtitleBgColor.value,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SubtitleDisplay(
                      text: controller.currentSubtitleText.value,
                      onTap: () => controller.player?.pause(),
                      onSelectionCompleted: (selectedText) {
                        controller.player?.pause();
                        // Trigger analysis immediately
                        controller.analyzeSelectedText(selectedText);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (bottomSheetContext) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.7,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              builder: (context, scrollController) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Obx(() {
                                    if (controller.isAnalyzing.value) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircularProgressIndicator(color: Colors.blue),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Analyzing '$selectedText'...",
                                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: [
                                        // Handle
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 10),
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),

                                        // Header
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedText,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                                                    onPressed: () => controller.speakText(selectedText),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      controller.player?.play();
                                                      Navigator.of(bottomSheetContext).pop();
                                                    },
                                                    icon: const Icon(Icons.close, color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(),

                                        // Content
                                        Expanded(
                                          child: ListView(
                                            controller: scrollController,
                                            padding: const EdgeInsets.all(16),
                                            children: controller.analysisType.value == 0
                                                ? _buildWordAnalysisUI(controller.analysisResult)
                                                : _buildSentenceAnalysisUI(controller.analysisResult),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildIndicator(IconData icon, double value) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(VideoScreenController controller, BuildContext context) {
    return Obx(() {
      final position = controller.position.value;
      final duration = controller.duration.value;

      return Row(
        children: [
          Text(
            controller.formatDuration(position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                min: 0,
                max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0),
                onChanged: (value) => controller.seekTo(value),
                activeColor: Colors.red,
                inactiveColor: Colors.white30,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.toggleTimeDisplayMode,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                controller.showRemainingTime.value
                    ? '-${controller.formatDuration(duration - position < Duration.zero ? Duration.zero : duration - position)}'
                    : controller.formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildControls(VideoScreenController controller) {
    return Obx(() {
      final isPlaying = controller.isPlaying.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => controller.seekBy(-10),
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: controller.togglePlayPause,
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () => controller.seekBy(10),
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
          ),
        ],
      );
    });
    }

  List<Widget> _buildWordAnalysisUI(Map<String, dynamic> data) {
    if (data.isEmpty) return [const Center(child: Text('No data'))];

    return [
      _buildSection('📝 Word', data['word'] ?? ''),
      _buildSection('🔊 Pronunciation', data['pronunciation']?['ipa'] ?? ''),
      _buildSection('💡 Meaning', data['meaning_simple'] ?? ''),
      _buildSection('🌐 Tamil Translation', data['translation']?['ta'] ?? ''),
      _buildSection('📚 Part of Speech', data['part_of_speech'] ?? ''),
      _buildSection('✍️ Example', data['example_sentence'] ?? ''),
      _buildListSection('🔗 Collocations', data['collocations']),
      _buildListSection('🔄 Synonyms', data['synonyms']),
      _buildListSection('↔️ Antonyms', data['antonyms']),
      _buildWordFormsSection(data['word_forms']),
      _buildListSection('⚠️ Common Mistakes', data['common_mistakes']),
      _buildSection('📊 Frequency Level', data['frequency_level'] ?? ''),
    ];
  }

  List<Widget> _buildSentenceAnalysisUI(Map<String, dynamic> data) {
    if (data.isEmpty) return [const Center(child: Text('No data'))];

    return [
      _buildSection('💬 Sentence', data['sentence'] ?? ''),
      _buildSection('💡 Meaning', data['meaning_simple'] ?? ''),
      _buildSection('🌐 Tamil Translation', data['translation']?['ta'] ?? ''),
      _buildContextSection(data['context']),
      _buildListSection('🔄 Similar Sentences', data['similar_sentences']),
      _buildAlternativesSection(data['alternatives']),
      _buildDialogueSection(data['example_dialogue']),
    ];
  }

  Widget _buildSpeedButton(VideoScreenController controller, double speed) {
    return Obx(() {
      final isSelected = controller.playbackRate.value == speed;
      return GestureDetector(
        onTap: () => controller.setPlaybackRate(isSelected ? 1.0 : speed),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            "${speed}x",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, dynamic items) {
    if (items == null || (items is List && items.isEmpty)) {
      return const SizedBox.shrink();
    }

    List<String> itemList = items is List ? items.cast<String>() : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          ...itemList.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 15)),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 15)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWordFormsSection(dynamic wordForms) {
    if (wordForms == null) return const SizedBox.shrink();

    List<Widget> formWidgets = [];
    (wordForms as Map<String, dynamic>).forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        formWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${key.toString().toUpperCase()}: $value',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        );
      }
    });

    if (formWidgets.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Word Forms',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          ...formWidgets,
        ],
      ),
    );
  }

  Widget _buildContextSection(dynamic context) {
    if (context == null) return const SizedBox.shrink();
    final ctx = context as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎭 Context',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          if (ctx['situation'] != null && ctx['situation'].toString().isNotEmpty)
            Text('Situation: ${ctx['situation']}', style: const TextStyle(fontSize: 15)),
          if (ctx['tone'] != null && ctx['tone'].toString().isNotEmpty)
            Text('Tone: ${ctx['tone']}', style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildAlternativesSection(dynamic alternatives) {
    if (alternatives == null) return const SizedBox.shrink();
    final alts = alternatives as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Alternatives',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          if (alts['formal'] != null)
            ...['Formal:', ...(alts['formal'] as List)].map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8),
              child: Text(e.startsWith('Formal:') ? e : '• $e', style: const TextStyle(fontSize: 15)),
            )),
          const SizedBox(height: 8),
          if (alts['casual'] != null)
            ...['Casual:', ...(alts['casual'] as List)].map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8),
              child: Text(e.startsWith('Casual:') ? e : '• $e', style: const TextStyle(fontSize: 15)),
            )),
        ],
      ),
    );
  }

  Widget _buildDialogueSection(dynamic dialogue) {
    if (dialogue == null || (dialogue is List && dialogue.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ Example Dialogue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 8),
          ...(dialogue as List).map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${line['speaker']}: ${line['text']}',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          )),
        ],
      ),
    );
  }
}

class SubtitleDisplay extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Function(String) onSelectionCompleted;

  const SubtitleDisplay({
    super.key,
    required this.text,
    required this.onTap,
    required this.onSelectionCompleted,
  });

  @override
  State<SubtitleDisplay> createState() => _SubtitleDisplayState();
}

class _SubtitleDisplayState extends State<SubtitleDisplay> {
  final LayerLink _layerLink = LayerLink();
  String _currentSelection = '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoScreenController>();

    return Listener(
      onPointerUp: (_) {
        if (_currentSelection.trim().isNotEmpty) {
          final textToReport = _currentSelection;
          widget.onSelectionCompleted(textToReport);
          _currentSelection = ''; 
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Obx(() => SelectableText(
          widget.text,
          style: TextStyle(
            color: controller.subtitleTextColor.value,
            fontSize: controller.subtitleFontSize.value,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          contextMenuBuilder: (context, editableTextState) {
            return const SizedBox.shrink();
          },
          onSelectionChanged: (selection, cause) {
            if (selection.start != -1 && selection.end != -1) {
              final text = widget.text;
              final start = selection.start.clamp(0, text.length);
              final end = selection.end.clamp(0, text.length);
              
              if (start < end) {
                _currentSelection = text.substring(start, end);
              } else {
                _currentSelection = '';
              }
            }
          },
          onTap: widget.onTap,
        )),
      ),
    );
  }
}
