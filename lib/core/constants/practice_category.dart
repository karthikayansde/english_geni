enum PracticeCategory {
  read,
  write,
  listen,
  speak,
  grammar;

  /// User-facing capitalized name
  String get displayName {
    switch (this) {
      case PracticeCategory.read:
        return 'Read';
      case PracticeCategory.write:
        return 'Write';
      case PracticeCategory.listen:
        return 'Listen';
      case PracticeCategory.speak:
        return 'Speak';
      case PracticeCategory.grammar:
        return 'Grammar';
    }
  }

  /// Default emoji representation
  String get emoji {
    switch (this) {
      case PracticeCategory.read:
        return '📖';
      case PracticeCategory.write:
        return '✍️';
      case PracticeCategory.listen:
        return '🎥';
      case PracticeCategory.speak:
        return '🗣️';
      case PracticeCategory.grammar:
        return '📝';
    }
  }
}
