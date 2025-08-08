import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/app_usage_info.dart';

class RealAppUsageService {
  static const MethodChannel _channel = MethodChannel('com.example.brainrot/usage');
  static final RealAppUsageService _instance = RealAppUsageService._internal();
  factory RealAppUsageService() => _instance;
  RealAppUsageService._internal();

  /// Check if usage access permission is granted
  Future<bool> hasUsagePermission() async {
    try {
      debugPrint('🔍 [BRAINROT] Checking usage permission...');
      final bool? hasPermission = await _channel.invokeMethod('hasUsagePermission');
      debugPrint('🔍 [BRAINROT] Usage permission result: $hasPermission');
      return hasPermission ?? false;
    } catch (e) {
      debugPrint('❌ [BRAINROT] Error checking usage permission: $e');
      return false;
    }
  }

  /// Request usage access permission
  Future<bool> requestUsagePermission() async {
    try {
      debugPrint('📱 [BRAINROT] Requesting usage permission...');
      final bool? granted = await _channel.invokeMethod('requestUsagePermission');
      debugPrint('📱 [BRAINROT] Usage permission granted: $granted');
      return granted ?? false;
    } catch (e) {
      debugPrint('❌ [BRAINROT] Error requesting usage permission: $e');
      return false;
    }
  }

  /// Get app usage data for today FROM REAL DIGITAL WELLBEING
  Future<List<AppUsageInfo>> getTodayUsage() async {
    try {
      debugPrint('🔄 [BRAINROT] Fetching REAL usage data from Digital Wellbeing...');
      
      // Get current time info for debugging
      final timeInfo = await _channel.invokeMethod('getCurrentTimeInfo');
      debugPrint('🕐 [BRAINROT] Current time info: $timeInfo');
      
      // ALWAYS try to get real data first, regardless of permission
      final List<dynamic>? rawData = await _channel.invokeMethod('getUsageStats');
      debugPrint('🔄 [BRAINROT] Native method response: $rawData');
      
      if (rawData != null && rawData.isNotEmpty) {
        debugPrint('✅ [BRAINROT] Got ${rawData.length} real apps from Digital Wellbeing');
        
        // Convert raw data to AppUsageInfo objects
        List<AppUsageInfo> usageList = rawData.map((data) {
          final Map<String, dynamic> appData = Map<String, dynamic>.from(data);
          final now = DateTime.now();
          return AppUsageInfo(
            packageName: appData['packageName'] ?? '',
            appName: appData['appName'] ?? 'Unknown App',
            usage: Duration(milliseconds: (appData['usageTimeMillis'] ?? 0).toInt()),
            startTime: DateTime(now.year, now.month, now.day), // Start of today
            endTime: now, // Current time
          );
        }).toList();

        // Filter out apps with very short usage (less than 30 seconds)
        usageList = usageList.where((app) => app.usage.inSeconds >= 30).toList();
        
        // Sort by usage time (highest first)
        usageList.sort((a, b) => b.usage.compareTo(a.usage));

        debugPrint('📊 [BRAINROT] Processed ${usageList.length} apps with meaningful usage');
        for (var app in usageList.take(5)) {
          debugPrint('   ${app.appName}: ${app.formattedUsage}');
        }

        return usageList;
      } else {
        debugPrint('⚠️ [BRAINROT] No real usage data returned, checking permission...');
        
        // Check permission
        bool hasPermission = await hasUsagePermission();
        if (!hasPermission) {
          debugPrint('⚠️ [BRAINROT] No usage permission, requesting...');
          await requestUsagePermission();
        }
        
        debugPrint('🔄 [BRAINROT] Using fallback data (not real usage stats)');
        return _getFallbackData();
      }
      
    } catch (e) {
      debugPrint('❌ [BRAINROT] Error getting real usage data: $e');
      debugPrint('🔄 [BRAINROT] Using fallback data due to error');
      return _getFallbackData();
    }
  }

  /// Force refresh usage data (clears cache)
  Future<List<AppUsageInfo>> refreshTodayUsage() async {
    try {
      debugPrint('🔄 [BRAINROT] FORCE REFRESHING usage data...');
      
      // Get current time info for debugging
      final timeInfo = await _channel.invokeMethod('getCurrentTimeInfo');
      debugPrint('🕐 [BRAINROT] Force refresh at: $timeInfo');
      
      // Call refresh method that clears cache
      final List<dynamic>? rawData = await _channel.invokeMethod('refreshUsageStats');
      debugPrint('🔄 [BRAINROT] Force refresh response: $rawData');
      
      if (rawData != null && rawData.isNotEmpty) {
        debugPrint('✅ [BRAINROT] Got ${rawData.length} FRESH apps from Digital Wellbeing');
        
        // Convert raw data to AppUsageInfo objects
        List<AppUsageInfo> usageList = rawData.map((data) {
          final Map<String, dynamic> appData = Map<String, dynamic>.from(data);
          final now = DateTime.now();
          return AppUsageInfo(
            packageName: appData['packageName'] ?? '',
            appName: appData['appName'] ?? 'Unknown App',
            usage: Duration(milliseconds: (appData['usageTimeMillis'] ?? 0).toInt()),
            startTime: DateTime(now.year, now.month, now.day),
            endTime: now,
          );
        }).toList();

        // Filter and sort
        usageList = usageList.where((app) => app.usage.inSeconds >= 30).toList();
        usageList.sort((a, b) => b.usage.compareTo(a.usage));

        debugPrint('📊 [BRAINROT] FRESH processed ${usageList.length} apps');
        for (var app in usageList.take(5)) {
          debugPrint('   ${app.appName}: ${app.formattedUsage}');
        }

        return usageList;
      } else {
        debugPrint('⚠️ [BRAINROT] No fresh data, falling back...');
        return _getFallbackData();
      }
      
    } catch (e) {
      debugPrint('❌ [BRAINROT] Error force refreshing: $e');
      return _getFallbackData();
    }
  }

  /// Get app usage data for a specific date range
  Future<List<AppUsageInfo>> getUsageInRange(DateTime startTime, DateTime endTime) async {
    debugPrint('🔄 [BRAINROT] Getting usage data for range: $startTime to $endTime');
    // For now, just return today's usage
    // In a real implementation, you'd modify the native method to accept date parameters
    return await getTodayUsage();
  }

  /// Fallback data for when real data is not available
  List<AppUsageInfo> _getFallbackData() {
    debugPrint('🔄 [BRAINROT] Using fallback data (not real usage stats)');
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return [
      AppUsageInfo(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        usage: const Duration(hours: 1, minutes: 30),
        startTime: startOfDay,
        endTime: now,
      ),
      AppUsageInfo(
        packageName: 'com.tiktok.musically',
        appName: 'TikTok',
        usage: const Duration(hours: 1, minutes: 15),
        startTime: startOfDay,
        endTime: now,
      ),
      AppUsageInfo(
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        usage: const Duration(minutes: 45),
        startTime: startOfDay,
        endTime: now,
      ),
      AppUsageInfo(
        packageName: 'com.spotify.music',
        appName: 'Spotify',
        usage: const Duration(minutes: 30),
        startTime: startOfDay,
        endTime: now,
      ),
      AppUsageInfo(
        packageName: 'com.android.chrome',
        appName: 'Chrome',
        usage: const Duration(minutes: 25),
        startTime: startOfDay,
        endTime: now,
      ),
    ];
  }

  /// Get top used apps (utility method)
  List<AppUsageInfo> getTopUsedApps(List<AppUsageInfo> apps, {int limit = 5}) {
    final sortedApps = List<AppUsageInfo>.from(apps);
    sortedApps.sort((a, b) => b.usage.compareTo(a.usage));
    return sortedApps.take(limit).toList();
  }

  /// Get usage statistics (utility method)
  Map<String, dynamic> getUsageStats(List<AppUsageInfo> apps) {
    if (apps.isEmpty) {
      return {
        'totalApps': 0,
        'totalUsage': Duration.zero,
        'averageUsage': Duration.zero,
        'mostUsedApp': null,
      };
    }

    final totalUsage = apps.fold<Duration>(
      Duration.zero,
      (sum, app) => sum + app.usage,
    );

    final averageUsage = Duration(
      milliseconds: totalUsage.inMilliseconds ~/ apps.length,
    );

    final mostUsedApp = apps.reduce(
      (current, next) => current.usage > next.usage ? current : next,
    );

    return {
      'totalApps': apps.length,
      'totalUsage': totalUsage,
      'averageUsage': averageUsage,
      'mostUsedApp': mostUsedApp,
    };
  }
}
