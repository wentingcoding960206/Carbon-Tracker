import 'package:carbon_tracker/calender_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pie_chart.dart';
import 'line_graph.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int selectedIndex = 1; // 0 = Pie Chart, 1 = Line Graph

  Future<void> debugPrintAllSavedData() async {
  final prefs = await SharedPreferences.getInstance();

  // Print all saved routes
  final jsonList = prefs.getStringList('routes') ?? [];
  debugPrint('Saved routes count: ${jsonList.length}');
  for (var i = 0; i < jsonList.length; i++) {
    debugPrint('Route $i: ${jsonList[i]}');
  }

  // Print all saved activities keys and content
  final keys = prefs.getKeys();
  final activityKeys = keys.where((key) => key.startsWith('activities-')).toList();
  debugPrint('Saved activities keys: $activityKeys');
  for (var key in activityKeys) {
    final list = prefs.getStringList(key) ?? [];
    debugPrint('Activities for $key count: ${list.length}');
    for (var item in list) {
      debugPrint(item);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color.fromARGB(255, 0, 0, 0);
    final unselectedColor = const Color.fromARGB(255, 171, 169, 169);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CalendarFilterButton(
                  onCalendarPressed: () {
                    debugPrintAllSavedData();
                  },
                ),

                const SizedBox(width: 15),
                /*GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pie Chart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == 0
                              ? selectedColor
                              : unselectedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: 75,
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),*/
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Line Graph',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == 1
                              ? selectedColor
                              : unselectedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: 80,
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            selectedIndex == 0 ? const PieChartWidget() : const LineGraph(),
          ],
        ),
      ),
    );
  }
}
