import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4B5),
      appBar: AppBar(
        title: const Text(
          'brainrot apps',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFE4B5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apps row
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAppIcon('3DV', Colors.green),
                  const SizedBox(width: 15),
                  _buildAppIcon('', Colors.grey, isPlaceholder: true),
                  const SizedBox(width: 15),
                  _buildAppIcon('', Colors.grey, isPlaceholder: true),
                  const SizedBox(width: 15),
                  _buildAppIcon('FN', Colors.black),
                  const SizedBox(width: 15),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        '+63',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // All rules section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'all rules',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Warning message
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'no rules active right now - you should set some!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Time limits section
            _buildRuleSection('time limits', '(1)', [
              _buildRuleItem('2h daily limit', '⏰ 120 minutes daily', false),
            ]),

            const SizedBox(height: 20),

            // Schedules section
            _buildRuleSection('schedules', '(2)', [
              _buildRuleItem(
                'evening focus mode',
                '📅 every day 20:00-23:59',
                false,
              ),
              _buildRuleItem(
                'work focus mode',
                '📅 weekdays 09:00-17:00',
                false,
              ),
            ]),

            const SizedBox(height: 20),

            // All day blocks section
            _buildRuleSection('all day blocks', '(1)', [
              _buildRuleItem('social media block', '🌙 all day', false),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(String text, Color color, {bool isPlaceholder = false}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color:
            isPlaceholder
                ? Colors.grey.withOpacity(0.3)
                : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border:
            isPlaceholder
                ? Border.all(color: Colors.grey, style: BorderStyle.solid)
                : null,
      ),
      child: Center(
        child:
            isPlaceholder
                ? Icon(Icons.apps, color: Colors.grey, size: 30)
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
      ),
    );
  }

  Widget _buildRuleSection(String title, String count, List<Widget> rules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getRuleSectionIcon(title),
              color: _getRuleSectionColor(title),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5),
            Text(
              count,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            const Icon(Icons.expand_more, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 15),
        ...rules,
      ],
    );
  }

  Widget _buildRuleItem(String title, String description, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              // Handle toggle
              setState(() {
                // Update rule state
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  IconData _getRuleSectionIcon(String title) {
    switch (title) {
      case 'time limits':
        return Icons.access_time;
      case 'schedules':
        return Icons.schedule;
      case 'all day blocks':
        return Icons.block;
      default:
        return Icons.settings;
    }
  }

  Color _getRuleSectionColor(String title) {
    switch (title) {
      case 'time limits':
        return Colors.orange;
      case 'schedules':
        return Colors.blue;
      case 'all day blocks':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Stats & Blocking Help'),
            content: const Text(
              'This screen shows your installed apps and blocking rules. '
              'You can set time limits, schedules, and all-day blocks to manage your screen time. '
              'Toggle rules on/off using the switches.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }
}
