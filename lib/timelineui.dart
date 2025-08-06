import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_TW');
  runApp(MaterialApp(home: TimelineUI()));
}

class TimelineUI extends StatefulWidget {
  const TimelineUI({super.key});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelineUI> {
  DateTime selectedDate = DateTime.now();

  Future<List<Activity>> _loadActivitiesForDate(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('activities-$dateKey') ?? [];
    return jsonList.map((jsonStr) {
      final data = jsonDecode(jsonStr);
      return Activity(
        startTime: data['startTime'],
        endTime: data['endTime'],
        transport: data['transport'],
        duration: data['duration'],
        carbonEmission: data['carbonEmission'],
      );
    }).toList();
  }

  void _previousDay() => setState(() => selectedDate = selectedDate.subtract(Duration(days: 1)));
  void _nextDay() => setState(() => selectedDate = selectedDate.add(Duration(days: 1)));

  void selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy年M月d日', 'zh_TW').format(selectedDate);
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('活動時間軸'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_left), onPressed: _previousDay),
                Text(formattedDate, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.arrow_right), onPressed: _nextDay),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Activity>>(
              future: _loadActivitiesForDate(dateKey),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }

                final activities = snapshot.data ?? [];
                if (activities.isEmpty) return Center(child: Text('這天沒有活動'));

                final totalCarbon = activities.fold<double>(
                  0,
                  (sum, a) => sum + (double.tryParse(a.carbonEmission.split(' ')[0]) ?? 0),
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final a = activities[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                '${a.startTime} 至 ${a.endTime}\n'
                                '${a.transport}\n'
                                '共 ${a.duration}，碳排量 ${a.carbonEmission}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '當日總碳排量：${totalCarbon.toStringAsFixed(2)} kg CO₂',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Activity {
  final String startTime;
  final String endTime;
  final String transport;
  final String duration;
  final String carbonEmission;

  Activity({
    required this.startTime,
    required this.endTime,
    required this.transport,
    required this.duration,
    required this.carbonEmission,
  });
}
