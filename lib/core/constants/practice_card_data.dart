import 'practice_category.dart';

class PracticeCardData {
  PracticeCardData._();

  // 'lastUsed': '2 days ago',
  // 'duration': '12m',
  /// Shared list of practice cards utilized across Home and Practice tabs
  static const List<Map<String, dynamic>> cards = [
    {
      'id': 'interactive_subtitles',
      'name': 'English video with interactive subtitles',
      'desc': 'Watch English videos and tap any word in the subtitles to see its definition instantly.',
      'tags': [PracticeCategory.listen],
      'emoji': '🎥',

      'lastUsed': '2 days ago',
      'duration': '12m',
    },
    {
      'id': 'speed_reading',
      'name': 'Speed Reading',
      'desc': 'Train your eyes to scan text and summarize chapters faster.',
      'tags': [PracticeCategory.read],
      'emoji': '📖',
    },
  ];
}
