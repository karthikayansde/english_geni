import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import 'controllers/video_player_controller.dart';
import 'models/subtitle_track.dart';
import '../../shared/widgets/smart_form_fields/smart_buttons.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late final VideoPlayerController _controller;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late final Worker _loadingWorker;
  late final Worker _extractingWorker;

  bool _isValidVideoPath(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    final trimmed = path.trim();
    
    // Check for the unique long dummy key
    if (trimmed == 'DEFAULT_EMPTY_DUMMY_PLACEHOLDER_VIDEO_PATH_KEY_987654321_abc_xyz') {
      return false;
    }
    
    // Valid video paths must be absolute local paths or content URIs
    if (!trimmed.startsWith('/') && 
        !trimmed.startsWith('content://') && 
        !trimmed.startsWith('file://') &&
        !trimmed.contains(':\\') && 
        !trimmed.contains(':/')) {
      return false;
    }
    
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.put(VideoPlayerController());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Trigger animation when loading or extracting completes and tracks exist
    _loadingWorker = ever(_controller.isLoading, (isLoading) {
      if (mounted && !isLoading && !_controller.isExtracting.value && _controller.tracks.isNotEmpty) {
        _animationController.forward(from: 0.0);
      }
    });
    _extractingWorker = ever(_controller.isExtracting, (isExtracting) {
      if (mounted && !isExtracting && !_controller.isLoading.value && _controller.tracks.isNotEmpty) {
        _animationController.forward(from: 0.0);
      }
    });

    // If a video path was passed from deep link / external intent, extract immediately
    if (_isValidVideoPath(widget.videoPath)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.processVideo(widget.videoPath);
      });
    }
  }

  @override
  void dispose() {
    _loadingWorker.dispose();
    _extractingWorker.dispose();
    _animationController.dispose();
    Get.delete<VideoPlayerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "SubSplitter",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          Obx(() {
            final hasVideo = _isValidVideoPath(_controller.currentVideoPath.value);
            final active = !_controller.isLoading.value && !_controller.isExtracting.value;
            if (hasVideo && active) {
              return IconButton(
                icon: const Icon(Icons.video_collection_outlined),
                onPressed: _controller.pickVideo,
                tooltip: "Change Video",
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(() {
          if (_controller.isLoading.value || _controller.isExtracting.value) {
            return _buildLoadingState();
          } else if (!_isValidVideoPath(_controller.currentVideoPath.value)) {
            return _buildEmptyState();
          } else {
            return _buildTrackList();
          }
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _controller.isLoading.value ? "Probing video file..." : "Extracting subtitle tracks...",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This may take a moment depending on the file size",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.onSurface,width: 2,),
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
            onPressed: _controller.pickVideo,
            icon: Icons.add_rounded,
            width: 220,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    final theme = Theme.of(context);
    if (_controller.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.subtitles_off_rounded, size: 64, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 20),
            Text(
              "No Subtitles Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "This video file doesn't seem to contain any extractable subtitle tracks.",
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _controller.pickVideo,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Another File"),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    final String baseName = _controller.getDisplayName(_controller.currentVideoPath.value!);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.video_file_outlined, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Extracted ${_controller.tracks.length} subtitle track(s)",
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Extracted Tracks",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _controller.tracks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildTrackCard(_controller.tracks[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(SubtitleTrack track) {
    final theme = Theme.of(context);
    final formatExtension = track.outputPath != null
        ? p.extension(track.outputPath!).replaceFirst('.', '').toUpperCase()
        : (track.codec ?? 'SRT').toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.subtitles_rounded, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title ?? "Track ${track.index}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (track.language != null) "Language: ${track.language!.toUpperCase()}",
                          if (track.codec != null) "Format: ${track.codec!.toUpperCase()}",
                        ].join(' · '),
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Format Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatExtension,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // File Name and Actions
          if (track.outputPath != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      track.outputFileName,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => Share.shareXFiles([XFile(track.outputPath!)]),
                    icon: const Icon(Icons.share_rounded, size: 14),
                    label: const Text("Share", style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => OpenFilex.open(track.outputPath!),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text("Open", style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.greenAccent[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          Divider(height: 1, color: theme.colorScheme.outlineVariant),

          // Preview Section
          _buildSubtitlePreview(track),
        ],
      ),
    );
  }

  Widget _buildSubtitlePreview(SubtitleTrack track) {
    final theme = Theme.of(context);
    if (track.outputPath == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            Text(
              "Extraction failed or codec unsupported",
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<String>(
      future: File(track.outputPath!).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.trim().isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "No subtitle preview available",
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          );
        }

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: SingleChildScrollView(
            child: Text(
              snapshot.data!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
