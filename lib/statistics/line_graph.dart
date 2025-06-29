import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineGraph extends StatelessWidget {
  const LineGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,

          height: 250, // height of the graph
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
                      final labels = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8, //SPACE ON TOP OF THE TEXT TO MOVE IT LOWER
                          ),
                          child: Text(labels[value.toInt()]),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 30,
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
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 10),
                    FlSpot(1, 50),
                    FlSpot(2, 45),
                    FlSpot(3, 65),
                    FlSpot(4, 30),
                    FlSpot(5, 88),
                    FlSpot(6, 75),
                  ],
                  isCurved: true,
                  color: Colors.deepPurple,
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15), // spacing between chart and title
        const Text(
          'Carbon Emissions (g)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
