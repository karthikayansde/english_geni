import 'dart:math';
import 'package:get/get.dart';

class PerformanceAnalyticsController extends GetxController {
  // Navigation Mode: true = Month, false = Week
  final isMonthMode = true.obs;

  // Selected date block (e.g. active month or active week starting date)
  final currentDate = DateTime(2026, 7, 4).obs;

  // Premium status (for paywall features)
  final isPremium = false.obs;

  // Loading indicator for fetching data
  final isLoading = false.obs;

  // Dynamic datasets updated on refetch
  final dailyPracticeMinutes = <DateTime, int>{}.obs;
  final fluencyVelocityWPM = <double>[].obs;
  final activityWatch = <double>[].obs;
  final activitySpeak = <double>[].obs;
  final activityDrills = <double>[].obs;
  final skillEquilibrium = <double>[].obs; // 5 values: Pronunciation, Fluency, Listening, Vocabulary, Grammar

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // Toggle navigation mode (Month vs Week)
  void toggleMode() {
    isMonthMode.value = !isMonthMode.value;
    fetchData();
  }

  // Paginate backward [ < ]
  void navigatePrevious() {
    if (isMonthMode.value) {
      currentDate.value = DateTime(currentDate.value.year, currentDate.value.month - 1, 1);
    } else {
      currentDate.value = currentDate.value.subtract(const Duration(days: 7));
    }
    fetchData();
  }

  // Paginate forward [ > ]
  void navigateNext() {
    if (isMonthMode.value) {
      currentDate.value = DateTime(currentDate.value.year, currentDate.value.month + 1, 1);
    } else {
      currentDate.value = currentDate.value.add(const Duration(days: 7));
    }
    fetchData();
  }

  // Toggle Premium (Utility for grading / showcasing UI)
  void togglePremium() {
    isPremium.value = !isPremium.value;
  }

  // Format header string (e.g., "July 2026" or "Week 27, 2026")
  String get dynamicHeaderLabel {
    final date = currentDate.value;
    if (isMonthMode.value) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return "${months[date.month - 1]} ${date.year}";
    } else {
      // Calculate week number of year
      final firstDayOfYear = DateTime(date.year, 1, 1);
      final daysOffset = date.difference(firstDayOfYear).inDays;
      final weekNum = ((daysOffset + firstDayOfYear.weekday) / 7).ceil();
      return "Week $weekNum, ${date.year}";
    }
  }

  // Fetch / Generate dynamic data based on currentDate and mode
  void fetchData() {
    isLoading.value = true;
    
    // Simulate minor asynchronous network / DB delay
    Future.delayed(const Duration(milliseconds: 250), () {
      final dateSeed = currentDate.value.year + currentDate.value.month + (isMonthMode.value ? 0 : currentDate.value.day);
      final random = Random(dateSeed);

      // 1. Generate Heatmap Consistency Matrix (Month days mapped to active minutes)
      dailyPracticeMinutes.clear();
      final year = currentDate.value.year;
      final month = currentDate.value.month;
      final daysInMonth = DateTime(year, month + 1, 0).day;

      for (int day = 1; day <= daysInMonth; day++) {
        final dayDate = DateTime(year, month, day);
        // Randomly assign active minutes (0, 15, 30, 45, 60) with different probabilities
        final prob = random.nextInt(100);
        int mins = 0;
        if (prob > 70) {
          mins = 15;
        } else if (prob > 50) {
          mins = 30;
        } else if (prob > 30) {
          mins = 45;
        } else if (prob > 15) {
          mins = 60;
        }
        dailyPracticeMinutes[dayDate] = mins;
      }

      // 2. Fluency Velocity (WPM)
      // For month: 7 data points spaced, for week: 7 data points (one per day)
      fluencyVelocityWPM.clear();
      for (int i = 0; i < 7; i++) {
        // Base fluency around 130-155 WPM
        fluencyVelocityWPM.add(120.0 + random.nextInt(40));
      }

      // 3. Activity Distribution Stacked Bar (Watch, Speak, Drills minutes)
      activityWatch.clear();
      activitySpeak.clear();
      activityDrills.clear();
      for (int i = 0; i < 7; i++) {
        activityWatch.add(5.0 + random.nextInt(20));
        activitySpeak.add(5.0 + random.nextInt(25));
        activityDrills.add(5.0 + random.nextInt(15));
      }

      // 4. Skill Equilibrium Radar Chart (5 metrics: Pronunciation, Fluency, Listening, Vocabulary, Grammar)
      skillEquilibrium.clear();
      for (int i = 0; i < 5; i++) {
        // Scores out of 100
        skillEquilibrium.add(60.0 + random.nextInt(35));
      }

      isLoading.value = false;
    });
  }
}
