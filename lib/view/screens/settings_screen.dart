import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/app_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _screenTimeGoal = 2.0; // hours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4B5),
      appBar: AppBar(
        title: const Text(
          'settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFE4B5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen time goal section
            const Text(
              'screen time goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'daily screen time goal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'set a daily limit for healthy screen usage',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Goal slider
                  Row(
                    children: [
                      Text(
                        '${_screenTimeGoal.toInt()} hours',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.orange,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.white,
                      overlayColor: Colors.orange.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: _screenTimeGoal,
                      min: 1,
                      max: 8,
                      divisions: 7,
                      onChanged: (value) {
                        setState(() {
                          _screenTimeGoal = value;
                        });
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1h', style: TextStyle(color: Colors.grey[600])),
                      Text('8h', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Support & Feedback section
            const Text(
              'support & feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildSettingsItem(
              Icons.help_outline,
              'help & support',
              Colors.blue,
              () => _showComingSoon(context, 'Help & Support'),
            ),
            const SizedBox(height: 10),

            _buildSettingsItem(
              Icons.lightbulb_outline,
              'feature requests',
              Colors.orange,
              () => _showComingSoon(context, 'Feature Requests'),
            ),
            const SizedBox(height: 10),

            _buildSettingsItem(
              Icons.star_outline,
              'leave a review',
              Colors.amber,
              () => _showComingSoon(context, 'Leave a Review'),
            ),
            const SizedBox(height: 10),

            _buildSettingsItem(
              Icons.email_outlined,
              'contact us',
              Colors.green,
              () => _showComingSoon(context, 'Contact Us'),
            ),

            const SizedBox(height: 30),

            // Legal section
            const Text(
              'legal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildSettingsItem(
              Icons.privacy_tip_outlined,
              'privacy policy',
              Colors.purple,
              () => _showComingSoon(context, 'Privacy Policy'),
            ),

            const SizedBox(height: 30),

            // App theme toggle
            Consumer<AppViewModel>(
              builder: (context, appViewModel, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          appViewModel.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: Colors.indigo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Switch between light and dark theme',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: appViewModel.themeMode == ThemeMode.dark,
                        onChanged: (value) => appViewModel.toggleTheme(),
                        activeColor: Colors.indigo,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // App version
            Center(
              child: Text(
                'Brainrot App v1.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(feature),
            content: Text('$feature is coming soon! Stay tuned for updates.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
