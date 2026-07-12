import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' hide SubtitleTrack;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:subtitle/subtitle.dart' hide SubtitleParser;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:english_geni/shared/widgets/smart_form_fields/smart_buttons.dart';
import 'package:english_geni/core/services/smart_dialogs.dart';
import 'package:english_geni/core/services/smart_snack_bars.dart';
import '../services/subtitle_service.dart';
import '../models/subtitle_track.dart';
import '../services/subtitle_parser.dart';

class VideoScreenController extends GetxController {
  final SubtitleService _subtitleService = SubtitleService();
  var probedTracks = <SubtitleTrack>[].obs;
  var selectedTrack = Rxn<SubtitleTrack>();
  var isProbing = false.obs;
  var isExtracting = false.obs;

  var activeDoubleTapIcon = Rxn<IconData>();
  Timer? _doubleTapIconTimer;

  void showDoubleTapIcon(IconData icon) {
    _doubleTapIconTimer?.cancel();
    activeDoubleTapIcon.value = icon;
    _doubleTapIconTimer = Timer(const Duration(milliseconds: 1000), () {
      activeDoubleTapIcon.value = null;
    });
  }

  var isLongPressSpeeding = false.obs;
  double _previousSpeed = 1.0;

  void startLongPressSpeed() {
    if (player == null) return;
    _previousSpeed = playbackRate.value;
    setPlaybackRate(2.0);
    isLongPressSpeeding.value = true;
  }

  void endLongPressSpeed() {
    if (player == null) return;
    setPlaybackRate(_previousSpeed);
    isLongPressSpeeding.value = false;
  }

  var videoPath = ''.obs;
  var isFullScreen = false.obs;
  var subtitlePath = ''.obs;

  // Subtitles
  var subtitles = <Subtitle>[].obs;
  var currentSubtitleText = ''.obs;
  var subtitleSyncOffset = Duration.zero.obs;

  String get fileName => videoPath.value.split(Platform.isWindows ? '\\' : '/').last;
  var orientationMode = 'auto'.obs;
  var showRemainingTime = false.obs;

  Player? player;
  VideoController? videoController;

  // Track playback state for UI updates
  var position = Duration.zero.obs;
  var duration = Duration.zero.obs;
  var isPlaying = false.obs;

  // Volume and Brightness
  var currentVolume = 0.5.obs;
  var currentBrightness = 0.5.obs;
  var showVolumeIndicator = false.obs;
  var showBrightnessIndicator = false.obs;
  var selectedAspectRatio = 'original'.obs;
  var audioTracks = <AudioTrack>[].obs;
  var selectedAudioTrack = Rxn<AudioTrack>();

  // Playback Speed
  var playbackRate = 1.0.obs;
  var isFastForwarding = false.obs;

  // UI Visibility
  var showControls = true.obs;
  DateTime? _lastInteraction;

  // Vocabulary Analysis
  var isAnalyzing = false.obs;
  var analysisResult = <String, dynamic>{}.obs;
  var analysisType = 0.obs; // 0: Word, 1: Sentence

  final List<String> _modelsList = [
    "gemini-3-pro-preview",
    "gemini-3-flash-preview",
    "gemini-2.5-flash",
    "gemini-2.5-flash-preview-09-2025",
    "gemini-2.5-flash-lite",
    "gemini-2.5-flash-lite-preview-09-2025"
  ];
  int _currentModelIndex = 0;

  GenerativeModel? _geminiModel;
  final FlutterTts flutterTts = FlutterTts();
  final String _apiKey = 'AIzaSyBwG_w5rZr2k9ZfqnjRE6vYBB-MzqNtphU'; // Keeping this as provided

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DeviceOrientation? _currentSensorOrientation;
  AccelerometerEvent? _lastAccelerometerEvent;

  var subtitleFontSize = 20.0.obs;
  var subtitleTextColor = const Color(0xFFFFFFFF).obs;
  var subtitleBgColor = const Color(0x8A000000).obs;

  void resetSubtitleStyle() {
    subtitleFontSize.value = 20.0;
    subtitleTextColor.value = const Color(0xFFFFFFFF);
    subtitleBgColor.value = const Color(0x8A000000);
  }

  @override
  void onInit() {
    super.onInit();
    
    // Set system UI based on initial showControls state (true)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    
    // Reactively toggle status bar visibility together with player controls
    ever(showControls, (bool visible) {
      if (visible) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });

    _initializePlayer();
    _initializeVolumeBrightness();
    _initializeAIAndTTS();
    if (Platform.isAndroid || Platform.isIOS) {
      _initAccelerometer();
    }
    setOrientationMode('auto');
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      _lastAccelerometerEvent = event;
      if (orientationMode.value != 'auto') return;
      _applyOrientationFromEvent(event);
    });
  }

  void _applyOrientationFromEvent(AccelerometerEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double absX = x.abs();
    final double absY = y.abs();

    DeviceOrientation? targetOrientation;

    // Determine device position based on acceleration due to gravity
    if (absY > absX) {
      if (y > 5.0) {
        targetOrientation = DeviceOrientation.portraitUp;
      } else if (y < -5.0) {
        targetOrientation = DeviceOrientation.portraitDown;
      }
    } else if (absX > absY) {
      if (x > 5.0) {
        targetOrientation = DeviceOrientation.landscapeLeft;
      } else if (x < -5.0) {
        targetOrientation = DeviceOrientation.landscapeRight;
      }
    }

    if (targetOrientation != null && targetOrientation != _currentSensorOrientation) {
      _currentSensorOrientation = targetOrientation;
      SystemChrome.setPreferredOrientations([targetOrientation]);
    }
  }
  void _initializePlayer() {
    player = Player();
    videoController = VideoController(player!);

    player!.stream.position.listen((p) {
      position.value = p;
      _updateSubtitle(p);
    });
    player!.stream.duration.listen((d) => duration.value = d);
    player!.stream.playing.listen((p) => isPlaying.value = p);
    player!.stream.tracks.listen((t) {
      audioTracks.value = t.audio;
    });
    player!.stream.track.listen((t) {
      selectedAudioTrack.value = t.audio;
    });
  }
  Future<void> _initializeVolumeBrightness() async {
    try {
      currentVolume.value = await FlutterVolumeController.getVolume() ?? 0.5;
      currentBrightness.value = await ScreenBrightness().application;
    } catch (e) {
      debugPrint('Error initializing volume/brightness: $e');
    }
  }
  Future<void> _initializeAIAndTTS() async {
    _initGemini();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }
  void _initGemini() {
    if (_currentModelIndex < _modelsList.length) {
      debugPrint("Initializing Gemini with model: ${_modelsList[_currentModelIndex]}");
      _geminiModel = GenerativeModel(
          model: _modelsList[_currentModelIndex], apiKey: _apiKey);
    }
  }

  Future<void> pickAndPlayVideo(BuildContext context) async {
    try {
      SmartDialogs.showLoading(message: "Opening video...");
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.video,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await playVideoPath(context, path);
      } else {
        SmartDialogs.hideLoading();
      }
    } catch (e) {
      SmartDialogs.hideLoading();
      debugPrint("Error picking video: $e");
      SmartSnackBars.show(message: "Failed to pick video", type: NotificationType.error);
    }
  }

  Future<void> playVideoPath(BuildContext context, String path) async {
    videoPath.value = path;
    SmartDialogs.showLoading(message: "Probing video file...");
    try {
      probedTracks.value = await _subtitleService.getSubtitleTracks(path);

      if (player != null) {
        await player!.stop();
      }
      await player!.open(Media(path));
      await player!.pause();

      SmartDialogs.hideLoading();

      _showTracksSelectionDialogPrivate(context, path);
    } catch (e) {
      SmartDialogs.hideLoading();
      debugPrint("Error playing video path: $e");
      SmartSnackBars.show(message: "Failed to play video", type: NotificationType.error);
    }
  }

  void setVolume(double value) {
    _resetControlTimer();
    currentVolume.value = value.clamp(0.0, 1.0);
    FlutterVolumeController.setVolume(currentVolume.value);

    showVolumeIndicator.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      showVolumeIndicator.value = false;
    });
  }

  Future<void> speakText(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> analyzeSelectedText(String text) async {
    isAnalyzing.value = true;
    analysisResult.clear();

    analysisType.value = text.trim().contains(' ') ? 1 : 0;

    final prompt = analysisType.value == 0
        ? _buildWordPrompt(text)
        : _buildSentencePrompt(text);
    final content = [Content.text(prompt)];

    bool success = false;
    String? lastError;

    while (!success && _currentModelIndex < _modelsList.length) {
      try {
        if (_geminiModel == null) _initGemini();

        final response = await _geminiModel!.generateContent(content);

        String responseText = response.text ?? '';

        responseText = responseText.trim();
        if (responseText.startsWith('```json')) {
          responseText = responseText.substring(7);
        } else if (responseText.startsWith('```')) {
          responseText = responseText.substring(3);
        }
        if (responseText.endsWith('```')) {
          responseText = responseText.substring(0, responseText.length - 3);
        }
        responseText = responseText.trim();

        analysisResult.value = jsonDecode(responseText);
        success = true;
      } catch (e) {
        lastError = e.toString();
        debugPrint("Gemini Analysis Error on model ${_modelsList[_currentModelIndex]}: $e");
        
        if (e.toString().contains("API key not valid")) {
          break;
        }

        debugPrint("Switching to next model...");
        _currentModelIndex++;
        if (_currentModelIndex < _modelsList.length) {
             _initGemini();
             continue; 
        }
        break;
      }
    }

    if (!success) {
       debugPrint("Final Analysis Failed: $lastError");
        if (_currentModelIndex >= _modelsList.length) {
          SmartSnackBars.show(message: "All AI models are currently busy. Please try again later.", type: NotificationType.error);
          _currentModelIndex = 0; 
          _initGemini();
        } else {
          SmartSnackBars.show(message: "Failed to analyze text", type: NotificationType.error);
        }
    }

    isAnalyzing.value = false;
  }

  String _buildWordPrompt(String word) {
    return '''
Analyze the following English word: "$word"

Return ONLY valid JSON. Do not include explanations, markdown, or extra text.

{
  "word": "$word",
  "pronunciation": {
    "ipa": ""
  },
  "meaning_simple": "",
  "translation": {
    "ta": ""
  },
  "part_of_speech": "",
  "example_sentence": "",
  "collocations": [],
  "synonyms": [],
  "antonyms": [],
  "word_forms": {
    "noun": "",
    "verb": "",
    "adjective": "",
    "adverb": ""
  },
  "common_mistakes": [],
  "frequency_level": ""
}
''';
  }

  String _buildSentencePrompt(String sentence) {
    return '''
Analyze the following English sentence: "$sentence"

Return ONLY valid JSON. Do not add explanations or markdown.

{
  "sentence": "$sentence",
  "meaning_simple": "",
  "translation": {
    "ta": ""
  },
  "context": {
    "situation": "",
    "tone": ""
  },
  "similar_sentences": [],
  "alternatives": {
    "formal": [],
    "casual": []
  },
  "example_dialogue": [
    { "speaker": "A", "text": "" },
    { "speaker": "B", "text": "" }
  ]
}
''';
  }

  void rewindSeconds(int seconds) {
    if (player == null) return;
    _resetControlTimer();
    final current = player!.state.position;
    final target = current - Duration(seconds: seconds);
    player!.seek(target < Duration.zero ? Duration.zero : target);
    showDoubleTapIcon(Icons.replay_5_rounded);
  }

  void fastForwardSeconds(int seconds) {
    if (player == null) return;
    _resetControlTimer();
    final current = player!.state.position;
    final target = current + Duration(seconds: seconds);
    final maxDuration = player!.state.duration;
    player!.seek(target > maxDuration ? maxDuration : target);
    showDoubleTapIcon(Icons.forward_5_rounded);
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      _resetControlTimer();
    }
  }

  void setOrientationMode(String mode) {
    _resetControlTimer();
    orientationMode.value = mode;
    switch (mode) {
      case 'auto':
        _currentSensorOrientation = null;
        SystemChrome.setPreferredOrientations([]);
        if (_lastAccelerometerEvent != null) {
          _applyOrientationFromEvent(_lastAccelerometerEvent!);
        }
        break;
      case 'landscape_left':
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
        break;
      case 'landscape_right':
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
        ]);
        break;
      case 'portrait':
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        break;
    }
  }

  void toggleTimeDisplayMode() {
    _resetControlTimer();
    showRemainingTime.value = !showRemainingTime.value;
  }

  void _resetControlTimer() {
    _lastInteraction = DateTime.now();
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastInteraction != null &&
          DateTime.now().difference(_lastInteraction!) >= const Duration(seconds: 3)) {
        showControls.value = false;
      }
    });
  }

  void _updateSubtitle(Duration currentPosition) {
    if (subtitles.isEmpty) {
      if (currentSubtitleText.value.isNotEmpty) currentSubtitleText.value = '';
      return;
    }
    
    final effectiveMs = (currentPosition - subtitleSyncOffset.value).inMilliseconds;
    
    final subtitle = subtitles.firstWhereOrNull(
      (s) => effectiveMs >= s.start.inMilliseconds && effectiveMs <= s.end.inMilliseconds,
    );

    if (subtitle != null) {
      if (currentSubtitleText.value != subtitle.data) {
        currentSubtitleText.value = subtitle.data;
      }
    } else {
      if (currentSubtitleText.value.isNotEmpty) {
        currentSubtitleText.value = '';
      }
    }
  }

  void adjustSubtitleSync(Duration delta) {
    subtitleSyncOffset.value += delta;
    _updateSubtitle(position.value);
  }

  void resetSubtitleSync() {
    subtitleSyncOffset.value = Duration.zero;
    _updateSubtitle(position.value);
  }

  Future<void> pickSubtitle() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa'],
      allowMultiple: false
    );
    
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    subtitlePath.value = result.files.single.path!;
    
    try {
      final content = await file.readAsString();
      final parsed = SubtitleParser.parse(content);
      subtitles.value = parsed;
      
      final fileName = result.files.single.name;
      final ext = result.files.single.extension ?? "srt";
      final newTrack = SubtitleTrack(
        index: 1000 + probedTracks.length,
        title: "Uploaded: $fileName",
        language: "User",
        codec: ext,
        outputPath: result.files.single.path,
      );
      probedTracks.add(newTrack);
      selectedTrack.value = newTrack;
      
      SmartSnackBars.show(message: "Subtitles loaded successfully", type: NotificationType.success);
      await player!.play();
    } catch (e) {
      debugPrint("Error parsing subtitles: $e");
      SmartSnackBars.show(message: "Failed to load subtitles", type: NotificationType.error);
    }
  }

  void setBrightness(double value) {
    _resetControlTimer();
    currentBrightness.value = value.clamp(0.0, 1.0);
    ScreenBrightness().setApplicationScreenBrightness(currentBrightness.value);

    showBrightnessIndicator.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      showBrightnessIndicator.value = false;
    });
  }

  void showAudioTracksDialog(BuildContext context) {
    if (player != null) {
      player!.pause();
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Audio Track',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Obx(() {
                    if (audioTracks.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "No audio tracks found",
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: audioTracks.map((track) {
                        final isSelected = selectedAudioTrack.value?.id == track.id;
                        final lang = track.language?.toUpperCase() ?? "UNKNOWN";
                        final title = track.title ?? "Track ${track.id}";
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? Colors.blueAccent : Colors.white54,
                            size: 20,
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            "Language: $lang | Codec: ${track.codec?.toUpperCase() ?? 'Auto'}",
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                          onTap: () async {
                            await player!.setAudioTrack(track);
                            Navigator.of(dialogContext).pop();
                            SmartSnackBars.show(
                              message: "Switched audio to ${track.title ?? track.id}",
                              type: NotificationType.success,
                            );
                          },
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showTracksSelectionDialog(BuildContext context) {
    if (player != null) {
      player!.pause();
    }
    _showTracksSelectionDialogPrivate(context, videoPath.value);
  }

  void _showTracksSelectionDialogPrivate(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (probedTracks.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.subtitles_off_rounded, size: 48, color: Colors.orangeAccent),
                      const SizedBox(height: 16),
                      const Text(
                        "No Subtitles Found",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "This video does not contain any internal subtitle tracks.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      SmartPrimaryButton(
                        label: "Upload Subtitle File",
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await pickSubtitle();
                        },
                        icon: Icons.upload_file_rounded,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              player!.play();
                            },
                            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              pickAndPlayVideo(context);
                            },
                            child: const Text("Choose Another Video", style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      )
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Subtitle Track",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.settings_suggest_rounded, color: Colors.blueAccent),
                              tooltip: 'Subtitle Settings',
                              onPressed: () {
                                _showSubtitleCustomizationDialog(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                player!.play();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select an embedded subtitle track, or upload your own file:",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),

                    // "None" option as first item
                    ListTile(
                      title: const Text(
                        "None",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        "Play video without subtitles",
                        style: TextStyle(color: Colors.white70),
                      ),
                      leading: Icon(
                        selectedTrack.value == null && subtitles.isEmpty
                            ? Icons.check_circle_rounded
                            : Icons.block_rounded,
                        color: selectedTrack.value == null && subtitles.isEmpty ? Colors.green : Colors.white38,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                      tileColor: selectedTrack.value == null && subtitles.isEmpty
                          ? Colors.blueAccent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        subtitles.clear();
                        currentSubtitleText.value = '';
                        subtitlePath.value = '';
                        selectedTrack.value = null;
                        player!.play();
                        SmartSnackBars.show(message: "Subtitles disabled", type: NotificationType.info);
                      },
                    ),
                    const SizedBox(height: 8),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: probedTracks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final track = probedTracks[index];
                        final lang = track.language?.toUpperCase() ?? "UNKNOWN";
                        final codec = track.codec?.toUpperCase() ?? "SRT";
                        final isSelected = selectedTrack.value?.index == track.index &&
                                          selectedTrack.value?.language == track.language;
                        return ListTile(
                          title: Text(
                            track.title ?? "Track ${track.index}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Language: $lang  Format: $codec",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          leading: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.subtitles_rounded,
                            color: isSelected ? Colors.green : Colors.blueAccent,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                          tileColor: isSelected ? Colors.blueAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: isSelected
                                ? const BorderSide(color: Colors.blueAccent, width: 1.5)
                                : BorderSide.none,
                          ),
                          onTap: () async {
                            Navigator.of(dialogContext).pop();
                            if (track.outputPath != null) {
                              subtitlePath.value = track.outputPath!;
                              selectedTrack.value = track;
                              final file = File(track.outputPath!);
                              final content = await file.readAsString();
                              subtitles.value = SubtitleParser.parse(content);
                              await player!.play();
                              SmartSnackBars.show(message: "Subtitles loaded successfully", type: NotificationType.success);
                            } else {
                              await _extractAndPlayTrack(context, path, track);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SmartPrimaryButton(
                      label: "Upload Subtitle File",
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await pickSubtitle();
                      },
                      icon: Icons.upload_file_rounded,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            player!.play();
                          },
                          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            pickAndPlayVideo(context);
                          },
                          child: const Text("Choose Another Video", style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    if (subtitles.isNotEmpty) ...[
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Subtitle Sync Delay",
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                          ),

                          IconButton(
                            onPressed: resetSubtitleSync,
                            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: "Reset Delay",
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildDialogSyncButton(Icons.remove_circle_outline, () => adjustSubtitleSync(const Duration(milliseconds: -500))),
                                const SizedBox(width: 8),
                                _buildDialogSyncButton(Icons.remove, () => adjustSubtitleSync(const Duration(milliseconds: -100))),
                              ],
                            ),
                            Obx(() => Text(
                              "${subtitleSyncOffset.value.inMilliseconds} ms",
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                            )),
                            Row(
                              children: [
                                _buildDialogSyncButton(Icons.add, () => adjustSubtitleSync(const Duration(milliseconds: 100))),
                                const SizedBox(width: 8),
                                _buildDialogSyncButton(Icons.add_circle_outline, () => adjustSubtitleSync(const Duration(milliseconds: 500))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  void _showSubtitleCustomizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (customContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Subtitle Style Settings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(customContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Font Size Slider
                  const Text(
                    "Font Size",
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: subtitleFontSize.value,
                          min: 14.0,
                          max: 32.0,
                          divisions: 18,
                          onChanged: (val) {
                            subtitleFontSize.value = val;
                          },
                        ),
                      ),
                      Text(
                        "${subtitleFontSize.value.round()} px",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),

                  // Text Color Option
                  const Text(
                    "Text Color",
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Color(0xFFFFFFFF), // White
                      const Color(0xFFFFEB3B), // Yellow
                      const Color(0xFF4CAF50), // Green
                      const Color(0xFF00BCD4), // Cyan
                      const Color(0xFFF44336), // Red
                    ].map((color) {
                      return Obx(() {
                        final isSelected = subtitleTextColor.value.value == color.value;
                        return GestureDetector(
                          onTap: () => subtitleTextColor.value = color,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: color,
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: color == const Color(0xFFFFFFFF) || color == const Color(0xFFFFEB3B)
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Background Box Color Option
                  const Text(
                    "Background Shadow Color",
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Color(0x00000000), // Transparent
                      const Color(0x8A000000), // Translucent Black
                      const Color(0xFF000000), // Solid Black
                      const Color(0x8A9E9E9E), // Translucent Grey
                      const Color(0x8A3F51B5), // Translucent Blue
                    ].map((color) {
                      return Obx(() {
                        final isSelected = subtitleBgColor.value.value == color.value;
                        return GestureDetector(
                          onTap: () => subtitleBgColor.value = color,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: color.value == 0
                                ? Colors.grey.withOpacity(0.2)
                                : color.withOpacity(1.0), // force solid display in picker
                            child: color.value == 0
                                ? const Text("None", style: TextStyle(fontSize: 10, color: Colors.white70))
                                : isSelected
                                    ? const Icon(Icons.check, color: Colors.white)
                                    : null,
                          ),
                        );
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          resetSubtitleStyle();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
                        label: const Text("Reset Default", style: TextStyle(color: Colors.orangeAccent)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        onPressed: () => Navigator.of(customContext).pop(),
                        child: const Text("Done", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogSyncButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Future<void> _extractAndPlayTrack(BuildContext context, String path, SubtitleTrack track) async {
    SmartDialogs.showLoading(message: "Extracting subtitle track...");
    isExtracting.value = true;
    try {
      final extractedTracks = await _subtitleService.extractAllSubtitles(path, [track]);
      if (extractedTracks.isNotEmpty && extractedTracks.first.outputPath != null) {
        final srtPath = extractedTracks.first.outputPath!;
        subtitlePath.value = srtPath;
        selectedTrack.value = track;
        
        final file = File(srtPath);
        final content = await file.readAsString();
        final parsed = SubtitleParser.parse(content);
        subtitles.value = parsed;
        
        SmartDialogs.hideLoading();
        isExtracting.value = false;
        await player!.play();
        SmartSnackBars.show(message: "Subtitles loaded successfully", type: NotificationType.success);
      } else {
        SmartDialogs.hideLoading();
        isExtracting.value = false;
        SmartSnackBars.show(message: "Failed to extract subtitle track", type: NotificationType.error);
        await player!.play();
      }
    } catch (e) {
      SmartDialogs.hideLoading();
      isExtracting.value = false;
      debugPrint("Error extracting subtitle: $e");
      SmartSnackBars.show(message: "Failed to parse extracted subtitle", type: NotificationType.error);
      await player!.play();
    }
  }

  void togglePlayPause() {
    _resetControlTimer();
    if (isPlaying.value) {
      player!.pause();
      showDoubleTapIcon(Icons.pause_rounded);
    } else {
      player!.play();
      showDoubleTapIcon(Icons.play_arrow_rounded);
    }
  }

  double? getAspectRatio(BuildContext context) {
    final aspect = selectedAspectRatio.value;
    if (aspect == '16:9') return 16 / 9;
    if (aspect == '18:9') return 18 / 9;
    if (aspect == '4:3') return 4 / 3;
    if (aspect == 'fit to screen') {
      return MediaQuery.of(context).size.aspectRatio;
    }
    return null; 
  }

  BoxFit getBoxFit() {
    final aspect = selectedAspectRatio.value;
    if (aspect == 'fit to screen') {
      return BoxFit.cover;
    }
    return BoxFit.contain;
  }



  void handleVerticalDrag(DragUpdateDetails details, bool isBrightness) {
    final delta = details.primaryDelta ?? 0;
    final change = -delta / 200.0;
    if (isBrightness) {
      setBrightness((currentBrightness.value + change).clamp(0.0, 1.0));
    } else {
      setVolume((currentVolume.value + change).clamp(0.0, 1.0));
    }
  }

  void seekTo(double value) {
    _resetControlTimer();
    player!.seek(Duration(seconds: value.toInt()));
  }

  void seekBy(double seconds) {
    _resetControlTimer();
    final target = position.value + Duration(seconds: seconds.toInt());
    Duration finalTarget = target;
    if (finalTarget < Duration.zero) {
      finalTarget = Duration.zero;
    } else if (finalTarget > duration.value) {
      finalTarget = duration.value;
    }
    player!.seek(finalTarget);
  }

  void setPlaybackRate(double speed) {
    _resetControlTimer();
    playbackRate.value = speed;
    player!.setRate(speed);
    isFastForwarding.value = speed != 1.0;
  }

  String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void onClose() {
    _accelerometerSubscription?.cancel();
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    player?.dispose();
    super.onClose();
  }
}
