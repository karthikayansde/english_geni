import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

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



  Future<List<SubtitleTrack>> getSubtitleTracks(String videoPath) async {
    final resolvedPath = await _resolvePathForFFmpeg(videoPath);
    // Use getMediaInformation instead of raw ffprobe command
    final session = await FFprobeKit.getMediaInformation(resolvedPath);
    final info = session.getMediaInformation();

    if (info == null) {
      debugPrint("MediaInformation is null for: $videoPath");
      // Fallback: try raw ffprobe command without quotes
      return await _getTracksViaRawCommand(resolvedPath);
    }

    final streams = info.getStreams();
    if (streams.isEmpty) {
      debugPrint("No streams found");
      return [];
    }

    final subtitleTracks = <SubtitleTrack>[];

    for (final stream in streams) {
      final type = stream.getType();
      final properties = stream.getAllProperties() ?? {};
      debugPrint("Stream type: $type, codec: ${stream.getCodec()}, properties: $properties");

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

    debugPrint("Found ${subtitleTracks.length} subtitle tracks");
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
    debugPrint("Raw ffprobe output: $output");

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
      debugPrint("Error parsing ffprobe output: $e");
      return [];
    }
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

    // Check if it's a supported video format
    if (!['.mkv', '.mp4', '.mov', '.m4v', '.webm'].contains(ext)) {
      return false;
    }

    // Accept any of these subtitle codecs in any supported container
    return c == 'subrip' || c == 'srt' ||
        c == 'webvtt' || c == 'vtt' ||
        c == 'ass'    || c == 'ssa' ||
        c == 'mov_text';
  }

  Future<List<SubtitleTrack>> extractAllSubtitles(
    String videoPath,
    List<SubtitleTrack> tracks, {
    String? customFileName,
  }) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = customFileName ?? p.basenameWithoutExtension(videoPath);
    final resolvedPath = await _resolvePathForFFmpeg(videoPath);
    
    for (final track in tracks) {
      // skip unsupported codec/container combos
      if (!_isSupportedCodec(track.codec, videoPath)) {
        debugPrint("Skipping unsupported track ${track.index} (${track.codec})");
        continue;
      }
      final ext = _extensionForCodec(track.codec);
      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\-_.]'), '_');
      final outputPath = p.join(
        tempDir.path,
        "${cleanFileName}_track${track.index}_${track.language ?? 'unknown'}.$ext",
      );

      debugPrint("Extracting track ${track.index} (${track.codec}) -> $outputPath");

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
        final logs = await session.getLogs();
        for (final log in logs) debugPrint(log.getMessage());
        if (ReturnCode.isSuccess(returnCode)) track.outputPath = outputPath;
        continue;
      }

      // WebVTT: use packet parsing since FFmpeg build lacks WebVTT decoder
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
          if (probeOutput == null || probeOutput.trim().isEmpty) {
            debugPrint("No probe output for track ${track.index}");
            continue;
          }

          final data = jsonDecode(probeOutput) as Map<String, dynamic>;
          final packets = data['packets'] as List<dynamic>? ?? [];
          if (packets.isEmpty) {
            debugPrint("No packets for track ${track.index}");
            continue;
          }

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
            debugPrint("WebVTT extracted via packets: $cueIndex cues");
          }
        } catch (e) {
          debugPrint("WebVTT packet parse error: $e");
        }
        continue;
      }

      // subrip, ass, ssa, mov_text — direct FFmpeg extraction, NO quotes
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
        final logs = await session.getLogs();
        for (final log in logs) debugPrint(log.getMessage());

        if (ReturnCode.isSuccess(returnCode)) {
          track.outputPath = outputPath;
          debugPrint("Extracted ${track.codec} track ${track.index} successfully");
        } else {
          debugPrint("FFmpeg failed for track ${track.index}");
        }
      } catch (e) {
        debugPrint("FFmpeg error for track ${track.index}: $e");
      }
    }

    return tracks.where((t) => t.outputPath != null).toList();
  }

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
}
