import 'package:path/path.dart' as p;

class SubtitleTrack {
  final int index;
  final String? language;
  final String? title;
  final String? codec;
  String? outputPath;

  SubtitleTrack({
    required this.index,
    this.language,
    this.title,
    this.codec,
    this.outputPath,
  });

  String get outputFileName => outputPath != null ? p.basename(outputPath!) : '';

  @override
  String toString() {
    String label = "Track $index";
    if (language != null) label += " [${language!.toUpperCase()}]";
    if (title != null) label += " ($title)";
    if (codec != null) label += " - $codec";
    return label;
  }
}
