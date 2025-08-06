import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> insertMockData() async {
  final prefs = await SharedPreferences.getInstance();

  // 模擬資料的日期 key
  final dateKey = '2025-08-03'; // 可修改為你想測試的日期

  final mockActivities = [
    {
      'startTime': '08:00',
      'endTime': '08:30',
      'transport': '騎腳踏車',
      'duration': '30 分鐘',
      'carbonEmission': '0.1 kg CO₂',
    },
    {
      'startTime': '09:00',
      'endTime': '09:45',
      'transport': '搭捷運',
      'duration': '45 分鐘',
      'carbonEmission': '0.5 kg CO₂',
    },
    {
      'startTime': '18:00',
      'endTime': '18:30',
      'transport': '開車',
      'duration': '30 分鐘',
      'carbonEmission': '2.3 kg CO₂',
    },
  ];

  // 將資料轉成 JSON 字串清單
  final jsonStringList = mockActivities.map((activity) => jsonEncode(activity)).toList();

  // 寫入 SharedPreferences
  await prefs.setStringList('activities-$dateKey', jsonStringList);
}
