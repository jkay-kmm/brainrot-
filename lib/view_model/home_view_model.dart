import 'package:flutter/material.dart';

import '../data/model/app_usage_info.dart';
import '../data/services/real_app_usage_service.dart';

class HomeViewModel extends ChangeNotifier {
  final RealAppUsageService _appUsageService = RealAppUsageService();

  List<AppUsageInfo> _appUsageList = [];
  bool _isLoading = false;
  String? _errorMessage;
  Duration _totalUsage = Duration.zero;

  // Getters
  List<AppUsageInfo> get appUsageList => _appUsageList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration get totalUsage => _totalUsage;

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

      // Check permission first
      bool hasPermission = await _appUsageService.hasUsagePermission();
      if (!hasPermission) {
        bool granted = await _appUsageService.requestUsagePermission();
        if (!granted) {
          _setError('Permission denied. Please grant usage access permission.');
          return;
        }
      }

      // Load usage data
      final usageList = await loadFunction();
      
      _appUsageList = usageList;
      _totalUsage = _appUsageService.getTotalUsage(usageList);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load app usage data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current data
  Future<void> refresh() async {
    // Reload today's usage data
    await loadTodayUsage();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get app usage percentage for a specific app
  double getUsagePercentage(AppUsageInfo app) {
    return app.getUsagePercentage(_totalUsage);
  }

  /// Get color for usage level
  Color getUsageColor(AppUsageInfo app) {
    final percentage = getUsagePercentage(app);
    
    if (percentage >= 20) {
      return Colors.red; // High usage
    } else if (percentage >= 10) {
      return Colors.orange; // Medium usage
    } else {
      return Colors.green; // Low usage
    }
  }

  /// Check if user has excessive screen time (more than 8 hours)
  bool get hasExcessiveScreenTime {
    return _totalUsage.inHours >= 8;
  }

  /// Get screen time category
  String get screenTimeCategory {
    final hours = _totalUsage.inHours;
    
    if (hours < 2) {
      return 'Light Usage';
    } else if (hours < 4) {
      return 'Moderate Usage';
    } else if (hours < 6) {
      return 'Heavy Usage';
    } else {
      return 'Excessive Usage';
    }
  }

  /// Get screen time category color
  Color get screenTimeCategoryColor {
    final hours = _totalUsage.inHours;
    
    if (hours < 2) {
      return Colors.green;
    } else if (hours < 4) {
      return Colors.blue;
    } else if (hours < 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
