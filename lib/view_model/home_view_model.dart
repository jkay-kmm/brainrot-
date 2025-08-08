import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/model/app_usage_info.dart';
import '../data/services/real_app_usage_service.dart';

class HomeViewModel extends ChangeNotifier {
  final RealAppUsageService _appUsageService = RealAppUsageService();

  List<AppUsageInfo> _appUsageList = [];
  bool _isLoading = false;
  String? _errorMessage;
  Duration _totalUsage = Duration.zero;
  double _currentScore = 100.0;
  DateTime _lastResetDate = DateTime.now();

  // Getters
  List<AppUsageInfo> get appUsageList => _appUsageList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration get totalUsage => _totalUsage;
  double get currentScore => _currentScore;

  // Get formatted total usage
  String get formattedTotalUsage {
    final hours = _totalUsage.inHours;
    final minutes = _totalUsage.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get top 5 most used apps
  List<AppUsageInfo> get topApps {
    return _appUsageService.getTopUsedApps(_appUsageList, limit: 5);
  }

  // Get usage statistics
  Map<String, dynamic> get usageStats {
    return _appUsageService.getUsageStats(_appUsageList);
  }

  // Check if it's excessive screen time
  bool get hasExcessiveScreenTime => _totalUsage.inMinutes > 180; // 3 hours

  // Get screen time category
  String get screenTimeCategory {
    final minutes = _totalUsage.inMinutes;
    if (minutes < 60) return 'Light';
    if (minutes < 120) return 'Moderate';
    if (minutes < 180) return 'Heavy';
    return 'Excessive';
  }

  // Get screen time category color
  Color get screenTimeCategoryColor {
    final minutes = _totalUsage.inMinutes;
    if (minutes < 60) return Colors.green;
    if (minutes < 120) return Colors.orange;
    if (minutes < 180) return Colors.red;
    return Colors.purple;
  }

  // Calculate brain health score based on current usage
  double calculateBrainHealthScore() {
    final totalMinutes = _totalUsage.inMinutes;
    final goalMinutes = 120; // 2 hours goal
    
    // Calculate impacts
    double preGoalImpact = 0.0;
    double postGoalImpact = 0.0;
    
    if (totalMinutes <= goalMinutes) {
      // Under goal - minimal impact
      preGoalImpact = (totalMinutes / goalMinutes) * 10.0; // Max 10 points deduction
    } else {
      // Over goal - heavy impact
      preGoalImpact = 10.0; // Full pre-goal impact
      final excessMinutes = totalMinutes - goalMinutes;
      postGoalImpact = (excessMinutes / 60.0) * 20.0; // 20 points per excess hour
    }
    
    final totalImpact = preGoalImpact + postGoalImpact;
    return (100 - totalImpact).clamp(0.0, 100.0);
  }

  // Check if need to reset for new day
  Future<void> _checkAndResetForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastResetDateString = prefs.getString('last_reset_date');
    
    if (lastResetDateString != null) {
      _lastResetDate = DateTime.parse(lastResetDateString);
    }

    // Check if it's a new day
    if (!_isSameDay(_lastResetDate, today)) {
      // Reset score to 100 for new day
      _currentScore = 100.0;
      _lastResetDate = today;
      
      // Save the reset date
      await prefs.setString('last_reset_date', today.toIso8601String());
      await prefs.setDouble('current_score', _currentScore);
      
      print('🌅 New day detected! Score reset to 100');
      notifyListeners();
    } else {
      // Load saved score for today
      _currentScore = prefs.getDouble('current_score') ?? 100.0;
    }
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Save current score
  Future<void> _saveCurrentScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('current_score', _currentScore);
  }

  /// Load today's app usage data
  Future<void> loadTodayUsage() async {
    await _loadUsage(() => _appUsageService.getTodayUsage());
  }

  /// Load app usage data for a specific date range
  Future<void> loadUsageInRange(DateTime startTime, DateTime endTime) async {
    await _loadUsage(() => _appUsageService.getUsageInRange(startTime, endTime));
  }

  /// Generic method to load usage data
  Future<void> _loadUsage(Future<List<AppUsageInfo>> Function() loadFunction) async {
    try {
      _setLoading(true);
      _clearError();

      // Check and reset for new day first
      await _checkAndResetForNewDay();

      // Check permission first
      bool hasPermission = await _appUsageService.hasUsagePermission();
      if (!hasPermission) {
        bool granted = await _appUsageService.requestUsagePermission();
        if (!granted) {
          _setError('Usage access permission is required to track screen time');
          return;
        }
      }

      // Load usage data
      final usageList = await loadFunction();
      _appUsageList = usageList;
      
      // Calculate total usage
      _totalUsage = Duration.zero;
      for (final app in _appUsageList) {
        _totalUsage += app.usage;
      }

      // Calculate and update current score based on usage
      _currentScore = calculateBrainHealthScore();
      await _saveCurrentScore();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load usage data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current data
  Future<void> refresh() async {
    await loadTodayUsage();
  }

  /// Force reset score to 100 (for testing or manual reset)
  Future<void> forceResetScore() async {
    _currentScore = 100.0;
    _lastResetDate = DateTime.now();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_reset_date', DateTime.now().toIso8601String());
    await prefs.setDouble('current_score', _currentScore);
    
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  double getUsagePercentage(AppUsageInfo app) {
    if (_totalUsage.inMilliseconds == 0) return 0.0;
    return (app.usage.inMilliseconds / _totalUsage.inMilliseconds) * 100;
  }

  Color getUsageColor(AppUsageInfo app) {
    final percentage = getUsagePercentage(app);
    if (percentage > 30) return Colors.red;
    if (percentage > 15) return Colors.orange;
    return Colors.green;
  }
}
