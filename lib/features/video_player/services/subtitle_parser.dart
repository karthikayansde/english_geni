import 'package:subtitle/subtitle.dart' hide SubtitleParser;

class SubtitleParser {
  static List<Subtitle> parse(String content) {
    final trimmed = content.trim();

    if (trimmed.startsWith('WEBVTT')) {
      return parseVtt(trimmed);
    } else if (trimmed.contains('[Script Info]') ||
        trimmed.contains('[V4+ Styles]') ||
        trimmed.contains('[V4 Styles]')) {
      return parseAss(trimmed);
    } else {
      return parseSrt(trimmed);
    }
  }

  // ── SRT ────────────────────────────────────────────────────
  static List<Subtitle> parseSrt(String content) {
    final subtitles = <Subtitle>[];
    final normalized = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    final blocks = normalized.split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      final index = int.tryParse(lines[0].trim());
      if (index == null) continue;

      final times = _parseSrtTimeLine(lines[1].trim());
      if (times == null) continue;

      final text = _stripHtmlTags(lines.sublist(2).join('\n').trim());
      if (text.isEmpty) continue;

      subtitles.add(Subtitle(
        index: index,
        start: times.$1,
        end: times.$2,
        data: text,
      ));
    }
    return subtitles;
  }

  // ── VTT ────────────────────────────────────────────────────
  static List<Subtitle> parseVtt(String content) {
    final subtitles = <Subtitle>[];
    final normalized = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    final lines = normalized.split('\n');
    final filtered = <String>[];
    bool skipNote = false;

    for (final line in lines) {
      if (line.startsWith('WEBVTT')) continue;
      if (line.startsWith('NOTE')) {
        skipNote = true;
        continue;
      }
      if (skipNote && line.trim().isEmpty) {
        skipNote = false;
        continue;
      }
      if (skipNote) continue;
      filtered.add(line);
    }

    final blocks = filtered.join('\n').split(RegExp(r'\n\s*\n'));
    int autoIndex = 1;

    for (final block in blocks) {
      final blockLines = block.trim().split('\n');
      if (blockLines.isEmpty) continue;

      int timeLineIndex = 0;
      int? index;

      if (!blockLines[0].contains('-->')) {
        index = int.tryParse(blockLines[0].trim()) ?? autoIndex;
        timeLineIndex = 1;
      } else {
        index = autoIndex;
      }

      if (timeLineIndex >= blockLines.length) continue;
      if (!blockLines[timeLineIndex].contains('-->')) continue;

      final times = _parseVttTimeLine(blockLines[timeLineIndex].trim());
      if (times == null) continue;

      final text = _stripVttTags(
        blockLines.sublist(timeLineIndex + 1).join('\n').trim(),
      );
      if (text.isEmpty) continue;

      subtitles.add(Subtitle(
        index: index,
        start: times.$1,
        end: times.$2,
        data: text,
      ));

      autoIndex++;
    }

    return subtitles;
  }

  // ── ASS / SSA ──────────────────────────────────────────────
  static List<Subtitle> parseAss(String content) {
    final subtitles = <Subtitle>[];
    final normalized = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final lines = normalized.split('\n');

    bool inEvents = false;
    List<String> format = [];
    int autoIndex = 1;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed == '[Events]') {
        inEvents = true;
        continue;
      }

      if (inEvents && trimmed.startsWith('[')) {
        inEvents = false;
        continue;
      }

      if (inEvents && trimmed.startsWith('Format:')) {
        format = trimmed
            .substring(7)
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .toList();
        continue;
      }

      if (inEvents && trimmed.startsWith('Dialogue:') && format.isNotEmpty) {
        final values = trimmed.substring(9).split(',');
        if (values.length < format.length) continue;

        final startIdx = format.indexOf('start');
        final endIdx = format.indexOf('end');
        final textIdx = format.indexOf('text');

        if (startIdx == -1 || endIdx == -1 || textIdx == -1) continue;

        final start = _parseAssTime(values[startIdx].trim());
        final end = _parseAssTime(values[endIdx].trim());
        if (start == null || end == null) continue;

        final rawText = values.sublist(textIdx).join(',').trim();
        final cleanText = _stripAssTags(rawText);
        if (cleanText.isEmpty) continue;

        subtitles.add(Subtitle(
          index: autoIndex++,
          start: start,
          end: end,
          data: cleanText,
        ));
      }
    }

    subtitles.sort((a, b) => a.compareTo(b));
    return subtitles;
  }

  // ── TIME PARSERS ───────────────────────────────────────────

  static (Duration, Duration)? _parseSrtTimeLine(String line) {
    final parts = line.split('-->');
    if (parts.length != 2) return null;
    final start = _parseSrtTime(parts[0].trim());
    final end = _parseSrtTime(parts[1].trim());
    if (start == null || end == null) return null;
    return (start, end);
  }

  static Duration? _parseSrtTime(String time) {
    final match = RegExp(
      r'(\d+):(\d{2}):(\d{2})[,.](\d{3})',
    ).firstMatch(time);
    if (match == null) return null;
    return Duration(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      milliseconds: int.parse(match.group(4)!),
    );
  }

  static (Duration, Duration)? _parseVttTimeLine(String line) {
    final arrowIndex = line.indexOf('-->');
    if (arrowIndex == -1) return null;
    final startStr = line.substring(0, arrowIndex).trim();
    final rest = line.substring(arrowIndex + 3).trim();
    final endStr = rest.split(' ').first;
    final start = _parseVttTime(startStr);
    final end = _parseVttTime(endStr);
    if (start == null || end == null) return null;
    return (start, end);
  }

  static Duration? _parseVttTime(String time) {
    final match = RegExp(
      r'(?:(\d+):)?(\d{2}):(\d{2})[,.](\d{3})',
    ).firstMatch(time);
    if (match == null) return null;
    return Duration(
      hours: int.tryParse(match.group(1) ?? '0') ?? 0,
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      milliseconds: int.parse(match.group(4)!),
    );
  }

  static Duration? _parseAssTime(String time) {
    final match = RegExp(
      r'(\d+):(\d{2}):(\d{2})\.(\d{2})',
    ).firstMatch(time);
    if (match == null) return null;
    return Duration(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      milliseconds: int.parse(match.group(4)!) * 10,
    );
  }

  // ── TAG STRIPPERS ──────────────────────────────────────────

  static String _stripHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static String _stripVttTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static String _stripAssTags(String text) {
    return text
        .replaceAll(RegExp(r'\{[^}]*\}'), '')
        .replaceAll(r'\N', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\h', ' ')
        .trim();
  }
}
