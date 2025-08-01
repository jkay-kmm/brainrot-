class AppUsageInfo {
  final String packageName;
  final String appName;
  final Duration usage;
  final DateTime startTime;
  final DateTime endTime;

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.usage,
    required this.startTime,
    required this.endTime,
  });

  // Format duration to readable string
  String get formattedUsage {
    final hours = usage.inHours;
    final minutes = usage.inMinutes.remainder(60);
    final seconds = usage.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Get usage percentage relative to total usage
  double getUsagePercentage(Duration totalUsage) {
    if (totalUsage.inMilliseconds == 0) return 0.0;
    return (usage.inMilliseconds / totalUsage.inMilliseconds) * 100;
  }

  @override
  String toString() {
    return 'AppUsageInfo(packageName: $packageName, appName: $appName, usage: $formattedUsage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUsageInfo &&
        other.packageName == packageName &&
        other.appName == appName &&
        other.usage == usage;
  }

  @override
  int get hashCode {
    return packageName.hashCode ^ appName.hashCode ^ usage.hashCode;
  }
}
