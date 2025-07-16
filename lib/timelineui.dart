import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_TW');
  runApp(MaterialApp(
    home: TimelineUI(),
  ));
}


/*void main() {
  runApp(MaterialApp(
    home: TimelineUI(),
  ));
}*/




class TimelineUI extends StatefulWidget {
  const TimelineUI({super.key});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelineUI> {
  DateTime selectedDate = DateTime(2025, 7, 2);

  final Map<String, List<Activity>> mockData = {
    '2025-07-02': [
      Activity(
        startTime: '08:00',
        endTime: '08:45',
        transport: '步行',
        duration: '45 分鐘',
        carbonEmission: '0.1 kg CO₂',
      ),
      Activity(
        startTime: '09:00',
        endTime: '09:30',
        transport: '捷運',
        duration: '30 分鐘',
        carbonEmission: '0.3 kg CO₂',
      ),
      Activity(
        startTime: '17:30',
        endTime: '18:10',
        transport: '公車',
        duration: '40 分鐘',
        carbonEmission: '0.5 kg CO₂',
      ),
    ],
  };

  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
  }

  void changeDate(int offset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offset));
    });
  }

  void selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yyyy年M月d日', 'zh_TW').format(selectedDate);
    final String dataKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    final activities = mockData[dataKey] ?? [];

    double totalCarbon = 0;
    for (final a in activities) {
      final carbon = double.tryParse(a.carbonEmission.split(' ')[0]) ?? 0;
      totalCarbon += carbon;
    }

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
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: _previousDay,
                ),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: _nextDay,
                ),
              ],
            ),
          ),
          Expanded(
            child: activities.isEmpty
                ? Center(child: Text('這天沒有活動'))
                : ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '${activity.startTime} 至 ${activity.endTime}\n'
                            '${activity.transport}\n'
                            '共 ${activity.duration}，碳排量 ${activity.carbonEmission}',
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
          )
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


