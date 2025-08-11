import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LineGraph extends StatefulWidget {
  const LineGraph({super.key});

  @override
  _LineGraphState createState() => _LineGraphState();
}

class _LineGraphState extends State<LineGraph> {
  // List of 7 values, one per day, default 0
  List<double> emissionsLast7Days = List.filled(7, 0);
  List<String> weekdayLabels = [];

  @override
  void initState() {
    super.initState();
    _loadEmissions();
    _generateWeekdayLabels();
  }

  void _generateWeekdayLabels() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final todayWeekdayIndex =
        today.weekday - 1; // 0-based index for weekdays list

    // We want last label = today, so labels are previous days + today.
    // To do this, rotate the weekdays so that today is at the end:
    // E.g. if today is Friday (index 4),
    // weekdayLabels = weekdays[(5)%7], weekdays[(6)%7], ..., weekdays[4]

    weekdayLabels = List.generate(7, (i) {
      // (todayWeekdayIndex - 6 + i) mod 7 to get last 7 days with today at the end
      int index = (todayWeekdayIndex - 6 + i) % 7;
      if (index < 0) index += 7; // handle negative modulus
      return weekdays[index];
    });
  }

  Future<void> _loadEmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    List<double> emissions = [];

    for (int i = 6; i >= 0; i--) {
      // Get date for each of the last 7 days (6 days ago to today)
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      final List<String> activitiesJsonList =
          prefs.getStringList('activities-$dateKey') ?? [];

      double totalCarbon = 0;

      for (var activityJson in activitiesJsonList) {
        try {
          final Map<String, dynamic> activity = Map<String, dynamic>.from(
            await Future.value(
              activityJson.isNotEmpty ? jsonDecode(activityJson) : {},
            ),
          );
          // Extract carbonEmission field which is string like "0.255 kg CO₂"
          final carbonEmissionStr =
              activity['carbonEmission'] as String? ?? '0';

          // Extract number from string
          final numberStr =
              RegExp(r'[\d\.]+').stringMatch(carbonEmissionStr) ?? '0';

          totalCarbon += double.tryParse(numberStr) ?? 0;
        } catch (_) {
          // Ignore parse errors
        }
      }
      print('Date: $dateKey, Total Carbon: $totalCarbon');
      emissions.add(totalCarbon);
    }

    setState(() {
      emissionsLast7Days = emissions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = weekdayLabels;

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[index]),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 40,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY:
                  emissionsLast7Days.reduce((a, b) => a > b ? a : b) +
                  10, // add some padding on top
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    emissionsLast7Days.length,
                    (index) =>
                        FlSpot(index.toDouble(), emissionsLast7Days[index]),
                  ),
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: Colors.deepPurple,
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Carbon Emissions (kg CO₂)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
