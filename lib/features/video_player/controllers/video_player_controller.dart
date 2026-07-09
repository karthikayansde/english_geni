import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import '../models/subtitle_track.dart';
import '../services/subtitle_service.dart';
import '../../../core/services/smart_dialogs.dart';

class VideoPlayerController extends GetxController {
  final SubtitleService _subtitleService = SubtitleService();

  final currentVideoPath = RxnString();
  final tracks = <SubtitleTrack>[].obs;
  final isLoading = false.obs;
  final isExtracting = false.obs;

  String getDisplayNameWithoutExtension(String path) {
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

  String getDisplayName(String path) {
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

  Future<void> pickVideo() async {
    try {
      SmartDialogs.showLoading(message: "Probing video file...");
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await processVideo(result.files.single.path!);
      }else{
        SmartDialogs.hideLoading();

      }
    } catch (e) {
      _showSnackBar("Error picking file: $e", isError: true);
    }
  }

  Future<void> processVideo(String path) async {
    SmartDialogs.showLoading();
    isLoading.value = true;
    tracks.clear();
    currentVideoPath.value = path;
    isExtracting.value = false;

    try {
      final displayNameWithoutExtension = getDisplayNameWithoutExtension(path);

      final loadedTracks = await _subtitleService.getSubtitleTracks(path);
      tracks.value = loadedTracks;

      if (loadedTracks.isNotEmpty) {
        isExtracting.value = true;
        final extracted = await _subtitleService.extractAllSubtitles(
          path,
          loadedTracks,
          customFileName: displayNameWithoutExtension,
        );
        tracks.value = extracted;
      }
    } catch (e) {
      _showSnackBar("Error processing video: $e", isError: true);
    } finally {
      SmartDialogs.hideLoading();
      isLoading.value = false;
      isExtracting.value = false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent[700]!,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
