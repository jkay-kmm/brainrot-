package com.example.brainrot

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.HashMap

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.brainrot/usage"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    requestUsageStatsPermission()
                    result.success(true)
                }
                "getUsageStats" -> {
                    val usageData = getTodayUsageStats()
                    result.success(usageData)
                }
                "refreshUsageStats" -> {
                    // Force refresh by getting fresh data
                    val usageData = getTodayUsageStats()
                    result.success(usageData)
                }
                "getCurrentTimeInfo" -> {
                    val currentTime = System.currentTimeMillis()
                    val calendar = Calendar.getInstance()
                    calendar.timeInMillis = currentTime
                    
                    result.success(mapOf(
                        "currentTime" to currentTime,
                        "hour" to calendar.get(Calendar.HOUR_OF_DAY),
                        "minute" to calendar.get(Calendar.MINUTE),
                        "day" to calendar.get(Calendar.DAY_OF_MONTH),
                        "month" to calendar.get(Calendar.MONTH) + 1,
                        "year" to calendar.get(Calendar.YEAR)
                    ))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
    
    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.data = android.net.Uri.parse("package:$packageName")
        startActivity(intent)
    }
    
    private fun getTodayUsageStats(): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) {
            return emptyList()
        }

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val packageManager = packageManager

        // Get today's start and end time
        val calendar = Calendar.getInstance()
        val currentTime = System.currentTimeMillis()
        
        // Reset to start of today (00:00:00)
        calendar.timeInMillis = currentTime
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        // Use INTERVAL_DAILY for today's data
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            currentTime
        )

        val result = mutableListOf<Map<String, Any>>()

        for (usageStat in usageStats) {
            // Only include apps with at least 1 minute of usage today
            if (usageStat.totalTimeInForeground > 60000 && usageStat.lastTimeUsed >= startTime) {
                try {
                    val appInfo = packageManager.getApplicationInfo(usageStat.packageName, 0)
                    val appName = packageManager.getApplicationLabel(appInfo).toString()
                    
                    result.add(mapOf(
                        "packageName" to usageStat.packageName,
                        "appName" to appName,
                        "usageTimeMillis" to usageStat.totalTimeInForeground,
                        "lastTimeUsed" to usageStat.lastTimeUsed,
                        "firstTimeStamp" to usageStat.firstTimeStamp
                    ))
                } catch (e: PackageManager.NameNotFoundException) {
                    // App might be uninstalled, skip
                }
            }
        }

        // Sort by usage time descending
        return result.sortedByDescending { it["usageTimeMillis"] as Long }
    }
}
