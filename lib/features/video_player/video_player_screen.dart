import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import 'models/subtitle_track.dart';
import 'services/subtitle_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  final SubtitleService _subtitleService = SubtitleService();
  String? _currentVideoPath;
  List<SubtitleTrack> _tracks = [];
  bool _isLoading = false;
  bool _isExtracting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // If a video path was passed from deep link / external intent, extract immediately
    if (widget.videoPath.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processVideo(widget.videoPath);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.video, // Restrict to only video files
        allowMultiple: false,
      );

      print("result: $result");
      if (result != null && result.files.single.path != null) {
        _processVideo(result.files.single.path!);
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e", isError: true);
    }
  }

  String _getDisplayNameWithoutExtension(String path) {
    try {
      final decoded = Uri.decodeFull(path);
      final uri = Uri.parse(decoded);
      if (uri.pathSegments.isNotEmpty) {
        final name = uri.pathSegments.last;
        return p.basenameWithoutExtension(name);
      }
    } catch (e) {
      print("Error extracting name from path: $e");
    }
    return p.basenameWithoutExtension(path);
  }

  String _getDisplayName(String path) {
    try {
      final decoded = Uri.decodeFull(path);
      final uri = Uri.parse(decoded);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (e) {
      print("Error extracting name from path: $e");
    }
    return p.basename(path);
  }

  Future<void> _processVideo(String path) async {
    setState(() {
      _isLoading = true;
      _tracks = [];
      _currentVideoPath = path;
    });

    try {
      final displayNameWithoutExtension = _getDisplayNameWithoutExtension(path);

      final tracks = await _subtitleService.getSubtitleTracks(path);
      setState(() {
        _tracks = tracks;
      });

      if (tracks.isNotEmpty) {
        setState(() => _isExtracting = true);
        final extracted = await _subtitleService.extractAllSubtitles(
          path,
          tracks,
          customFileName: displayNameWithoutExtension,
        );
        setState(() {
          _tracks = extracted;
        });
      }
      _animationController.forward(from: 0.0);
    } catch (e) {
      _showSnackBar("Error processing video: $e", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _isExtracting = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen content
    Widget bodyContent;
    if (_isLoading || _isExtracting) {
      bodyContent = _buildLoadingState();
    } else if (_currentVideoPath == null || _currentVideoPath!.isEmpty) {
      bodyContent = _buildEmptyState();
    } else {
      bodyContent = _buildTrackList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F16), // Premium deep dark color
      appBar: AppBar(
        title: const Text(
          "SubSplitter",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
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
          if (_currentVideoPath != null && !_isLoading && !_isExtracting)
            IconButton(
              icon: const Icon(Icons.video_collection_outlined),
              onPressed: _pickVideo,
              tooltip: "Change Video",
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: bodyContent,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isLoading ? "Probing video file..." : "Extracting subtitle tracks...",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This may take a moment depending on the file size",
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.movie_filter_outlined,
              size: 80,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Video Selected",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "Select a video file to extract and preview its subtitle tracks.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              "Select Video File",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    if (_tracks.isEmpty) {
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
            const Text(
              "No Subtitles Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "This video file doesn't seem to contain any extractable subtitle tracks.",
                style: TextStyle(color: Colors.grey[400], height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Another File"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      );
    }

    final String baseName = _getDisplayName(_currentVideoPath!);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.video_file_outlined, size: 32, color: Color(0xFF6366F1)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Extracted ${_tracks.length} subtitle track(s)",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Extracted Tracks",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _tracks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildTrackCard(_tracks[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(SubtitleTrack track) {
    final formatExtension = track.outputPath != null
        ? p.extension(track.outputPath!).replaceFirst('.', '').toUpperCase()
        : (track.codec ?? 'SRT').toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.subtitles_rounded, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title ?? "Track ${track.index}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (track.language != null) "Language: ${track.language!.toUpperCase()}",
                          if (track.codec != null) "Format: ${track.codec!.toUpperCase()}",
                        ].join(' · '),
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                // Format Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatExtension,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF818CF8),
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
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                      foregroundColor: const Color(0xFF818CF8),
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
                      foregroundColor: const Color(0xFF34D399),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          const Divider(height: 1, color: Colors.white12),

          // Preview Section
          _buildSubtitlePreview(track),
        ],
      ),
    );
  }

  Widget _buildSubtitlePreview(SubtitleTrack track) {
    if (track.outputPath == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            Text(
              "Extraction failed or codec unsupported",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<String>(
      future: File(track.outputPath!).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          );
        }

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: SingleChildScrollView(
            child: Text(
              snapshot.data!,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
