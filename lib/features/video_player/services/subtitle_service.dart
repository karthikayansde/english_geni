import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/subtitle_track.dart';

class SubtitleService {
  Future<String> _resolvePathForFFmpeg(String path) async {
    if (path.startsWith('content://')) {
      final safPath = await FFmpegKitConfig.getSafParameterForRead(path);
      if (safPath == null) {
        throw Exception('Could not resolve content URI via SAF');
      }
      return safPath;
    }
    return path;
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

  Future<List<SubtitleTrack>> getSubtitleTracks(String videoPath) async {
    final resolvedPath = await _resolvePathForFFmpeg(videoPath);
    // Use getMediaInformation instead of raw ffprobe command
    final session = await FFprobeKit.getMediaInformation(resolvedPath);
    final info = session.getMediaInformation();

    if (info == null) {
      print("MediaInformation is null for: $videoPath");
      // Fallback: try raw ffprobe command without quotes
      return await _getTracksViaRawCommand(resolvedPath);
    }

    final streams = info.getStreams();
    if (streams.isEmpty) {
      print("No streams found");
      return [];
    }

    final subtitleTracks = <SubtitleTrack>[];

    for (final stream in streams) {
      final type = stream.getType();
      final properties = stream.getAllProperties() ?? {};
      print("Stream type: $type, codec: ${stream.getCodec()}, properties: $properties");

      if (type?.toLowerCase() == 'subtitle') {
        final tags = stream.getTags();
        final index = properties['index'];

        String? codec = stream.getCodec();
        if (codec == null || codec.isEmpty || codec.toLowerCase() == 'none' || codec == '[0][0][0][0]') {
          // Try to resolve the codec from other properties
          final codecName = properties['codec_name']?.toString();
          final codecId = properties['codec_id']?.toString();
          final codecTag = properties['codec_tag_string']?.toString();
          
          if (codecName != null && codecName.toLowerCase() != 'none') {
            codec = codecName;
          } else if (codecId != null && codecId.toLowerCase() != 'none') {
            codec = codecId;
          } else if (codecTag != null && codecTag.toLowerCase() != 'none' && codecTag != '[0][0][0][0]') {
            codec = codecTag;
          } else {
            // Default completely unrecognized MKV subtitle streams to 'webvtt'
            codec = 'webvtt';
          }
        }

        subtitleTracks.add(SubtitleTrack(
          index: index is int ? index : int.tryParse(index?.toString() ?? '0') ?? 0,
          language: tags?['language'] as String?,
          title: tags?['title'] as String?,
          codec: codec,
        ));
      }
    }

    print("Found ${subtitleTracks.length} subtitle tracks");
    return subtitleTracks;
  }

  // Fallback method using raw command
  Future<List<SubtitleTrack>> _getTracksViaRawCommand(String videoPath) async {
    final session = await FFprobeKit.executeWithArguments([
      '-v',
      'quiet',
      '-print_format',
      'json',
      '-show_streams',
      '-select_streams',
      's',
      videoPath,
    ]);

    final output = await session.getOutput();
    print("Raw ffprobe output: $output");

    if (output == null || output.trim().isEmpty) return [];

    try {
      final data = jsonDecode(output) as Map<String, dynamic>;
      final streams = data['streams'] as List<dynamic>? ?? [];

      return streams.map((s) {
        final tags = s['tags'] as Map<String, dynamic>?;
        return SubtitleTrack(
          index: s['index'] as int? ?? 0,
          language: tags?['language'] as String?,
          title: tags?['title'] as String?,
          codec: s['codec_name'] as String?,
        );
      }).toList();
    } catch (e) {
      print("Error parsing ffprobe output: $e");
      return [];
    }
  }

  Future<String?> extractSubtitle(String videoPath, SubtitleTrack track) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = _getDisplayNameWithoutExtension(videoPath);
    final String outputPath = p.join(
      tempDir.path,
      "${fileName}_track${track.index}_${track.language ?? 'unknown'}.srt",
    );

    final resolvedPath = await _resolvePathForFFmpeg(videoPath);

    // For image-based subtitles we still need FFmpeg
    if (track.codec == 'hdmv_pgs_subtitle' || track.codec == 'dvd_subtitle') {
      final session = await FFmpegKit.executeWithArguments([
        '-y',
        '-i',
        resolvedPath,
        '-map',
        '0:${track.index}',
        outputPath,
      ]);
      final returnCode = await session.getReturnCode();
      return ReturnCode.isSuccess(returnCode) ? outputPath : null;
    }

    // For WebVTT/text subtitles: parse packets directly since
    // this FFmpeg build lacks the WebVTT decoder
    try {
      final probeSession = await FFprobeKit.executeWithArguments([
        '-v',
        'error',
        '-show_packets',
        '-show_data',
        '-select_streams',
        '${track.index}',
        '-of',
        'json',
        resolvedPath,
      ]);
      final probeOutput = await probeSession.getOutput();
      if (probeOutput == null || probeOutput.trim().isEmpty) {
        print("No packet output from ffprobe");
        return null;
      }

      final data = jsonDecode(probeOutput) as Map<String, dynamic>;
      final packets = data['packets'] as List<dynamic>? ?? [];

      if (packets.isEmpty) {
        print("No packets found for stream ${track.index}");
        return null;
      }

      final buffer = StringBuffer();
      int cueIndex = 1;

      for (final packet in packets) {
        final ptsMs = (packet['pts'] as num?)?.toInt() ?? 0;
        final durationMs = (packet['duration'] as num?)?.toInt() ?? 0;
        final endMs = ptsMs + durationMs;

        // Parse the hex dump from the 'data' field to get subtitle text
        final String? rawData = packet['data'] as String?;
        if (rawData == null) continue;

        final String text = _parsePacketData(rawData);
        if (text.trim().isEmpty) continue;

        // Format timestamps as SRT: HH:MM:SS,mmm
        final String start = _msToSrtTimestamp(ptsMs);
        final String end = _msToSrtTimestamp(endMs);

        buffer.writeln(cueIndex);
        buffer.writeln('$start --> $end');
        buffer.writeln(text);
        buffer.writeln();
        cueIndex++;
      }

      final srtContent = buffer.toString();
      print("Built SRT from packets: $cueIndex cues, ${srtContent.length} chars");

      await File(outputPath).writeAsString(srtContent, encoding: utf8);
      return outputPath;
    } catch (e) {
      print("Error building SRT from packets: $e");
      return null;
    }
  }

  /// Extracts plain text from ffprobe's hex dump format:
  /// "00000000: 4d65 616e  Meanwhile\n..."
  String _parsePacketData(String rawData) {
    final lines = rawData.split('\n');
    final bytes = <int>[];

    for (final line in lines) {
      final colonIdx = line.indexOf(':');
      if (colonIdx < 0) continue;

      final afterColon = line.substring(colonIdx + 1).trim();
      final parts = afterColon.split(RegExp(r'\s{2,}'));
      if (parts.isEmpty) continue;

      final hexPart = parts[0].trim();
      for (final hex in hexPart.split(RegExp(r'\s+'))) {
        if (hex.length == 4) {
          final b1 = int.tryParse(hex.substring(0, 2), radix: 16);
          final b2 = int.tryParse(hex.substring(2, 4), radix: 16);
          if (b1 != null) bytes.add(b1);
          if (b2 != null) bytes.add(b2);
        } else if (hex.length == 2) {
          final b = int.tryParse(hex, radix: 16);
          if (b != null) bytes.add(b);
        }
      }
    }

    return utf8.decode(bytes, allowMalformed: true);
  }

  String _msToSrtTimestamp(int ms) {
    final h = ms ~/ 3600000;
    final m = (ms % 3600000) ~/ 60000;
    final s = (ms % 60000) ~/ 1000;
    final millis = ms % 1000;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')},'
        '${millis.toString().padLeft(3, '0')}';
  }

  String _extensionForCodec(String? codec) {
    switch (codec?.toLowerCase()) {
      case 'subrip':
      case 'srt':
        return 'srt';
      case 'webvtt':
      case 'vtt':
        return 'vtt';
      case 'ass':
      case 'ssa':
        return 'ass';
      case 'mov_text':
        return 'srt';
      default:
        return 'srt';
    }
  }
  bool _isSupportedCodec(String? codec, String videoPath) {
    final ext = p.extension(videoPath).toLowerCase();
    final c = codec?.toLowerCase();

    // Accept typical formats: MKV, MP4, MOV, WebM, M4V, AVI, 3GP, etc.
    final List<String> supportedExtensions = [
      '.mkv', '.mp4', '.mov', '.m4v', '.webm', '.avi', '.3gp'
    ];

    final isUriBased = videoPath.startsWith('content://') ||
        videoPath.startsWith('file://') ||
        videoPath.startsWith('saf:');

    if (!isUriBased && !supportedExtensions.contains(ext)) {
      // Still attempt if it's a path without an extension
      if (ext.isNotEmpty && ext.length < 5) return false;
    }

    // Accept common text & basic image subtitle formats
    return c == 'subrip' || c == 'srt' ||
        c == 'webvtt' || c == 'vtt' ||
        c == 'ass'    || c == 'ssa' ||
        c == 'mov_text' || c == 'hdmv_pgs_subtitle' || c == 'dvd_subtitle';
  }

  Future<List<SubtitleTrack>> extractAllSubtitles(
    String videoPath,
    List<SubtitleTrack> tracks, {
    String? customFileName,
  }) async
  {
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = customFileName ?? p.basenameWithoutExtension(videoPath);
    
    for (final track in tracks) {
      if (!_isSupportedCodec(track.codec, videoPath)) {
        print("Skipping unsupported track ${track.index} (${track.codec})");
        continue;
      }
      
      final ext = _extensionForCodec(track.codec);
      // Clean up special characters from filename
      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\-_.]'), '_');
      final outputPath = p.join(
        tempDir.path,
        "${cleanFileName}_track${track.index}_${track.language ?? 'unknown'}.$ext",
      );

      print("Extracting track ${track.index} (${track.codec}) -> $outputPath");

      final resolvedPath = await _resolvePathForFFmpeg(videoPath);

      // Image-based subtitles
      if (track.codec == 'hdmv_pgs_subtitle' || track.codec == 'dvd_subtitle') {
        final session = await FFmpegKit.executeWithArguments([
          '-y',
          '-i',
          resolvedPath,
          '-map',
          '0:${track.index}',
          outputPath,
        ]);
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          track.outputPath = outputPath;
        }
        continue;
      }

      // WebVTT: packet parsing fallback
      if (track.codec == 'webvtt') {
        try {
          final probeSession = await FFprobeKit.executeWithArguments([
            '-v',
            'error',
            '-show_packets',
            '-show_data',
            '-select_streams',
            '${track.index}',
            '-of',
            'json',
            resolvedPath,
          ]);
          final probeOutput = await probeSession.getOutput();
          if (probeOutput != null && probeOutput.trim().isNotEmpty) {
            final data = jsonDecode(probeOutput) as Map<String, dynamic>;
            final packets = data['packets'] as List<dynamic>? ?? [];
            
            final buffer = StringBuffer();
            int cueIndex = 1;
            
            for (final packet in packets) {
              final ptsMs = (packet['pts'] as num?)?.toInt() ?? 0;
              final durationMs = (packet['duration'] as num?)?.toInt() ?? 0;
              final endMs = ptsMs + durationMs;
              final String? rawData = packet['data'] as String?;
              if (rawData == null) continue;
              final String text = _parsePacketData(rawData);
              if (text.trim().isEmpty) continue;
              buffer.writeln(cueIndex);
              buffer.writeln('${_msToSrtTimestamp(ptsMs)} --> ${_msToSrtTimestamp(endMs)}');
              buffer.writeln(text);
              buffer.writeln();
              cueIndex++;
            }

            final content = buffer.toString();
            if (content.trim().isNotEmpty) {
              await File(outputPath).writeAsString(content, encoding: utf8);
              track.outputPath = outputPath;
            }
          }
        } catch (e) {
          print("WebVTT packet parse error: $e");
        }
        continue;
      }

      // Text subtitles: subrip, ass, ssa, mov_text
      try {
        final session = await FFmpegKit.executeWithArguments([
          '-y',
          '-i',
          resolvedPath,
          '-map',
          '0:${track.index}',
          outputPath,
        ]);
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          track.outputPath = outputPath;
          print("Extracted ${track.codec} track ${track.index} successfully");
        } else {
          // If direct mapping fails, attempt packet parsing as fallback
          final extracted = await extractSubtitle(videoPath, track);
          if (extracted != null) {
            track.outputPath = extracted;
          }
        }
      } catch (e) {
        print("FFmpeg error for track ${track.index}: $e");
      }
    }

    return tracks.where((t) => t.outputPath != null).toList();
  }
}
