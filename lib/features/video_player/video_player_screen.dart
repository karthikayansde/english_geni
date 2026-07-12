import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/video_picker_player.dart';
import 'state_management/video_screen_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  static int _activeScreens = 0;
  late final VideoScreenController _controller;

  bool _isValidVideoPath(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    final trimmed = path.trim();
    
    // Check for the unique long dummy key
    if (trimmed == 'DEFAULT_blueto_EMPTY_DUMMY_PLACEHOLDER_vinothas_VIDEO_PATH_KEY_987654321_abc_sunnitha_xyz') {
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
    _activeScreens++;
    _controller = Get.put(VideoScreenController());

    if (_isValidVideoPath(widget.videoPath)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.playVideoPath(context, widget.videoPath);
      });
    }
  }

  @override
  void dispose() {
    _activeScreens--;
    if (_activeScreens == 0) {
      Get.delete<VideoScreenController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const VideoPickerPlayer();
  }
}
