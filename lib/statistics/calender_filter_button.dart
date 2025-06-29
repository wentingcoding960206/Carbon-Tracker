// calendar_filter_button.dart
import 'package:flutter/material.dart';

class CalendarFilterButton extends StatelessWidget {
  const CalendarFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.calendar_today),
        offset: const Offset(0, 45),
        onSelected: (value) {
          print('Selected: $value');
          
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'day', child: Text('Day')),
          const PopupMenuItem(value: 'week', child: Text('Week')),
          const PopupMenuItem(value: 'month', child: Text('Month')),
          const PopupMenuItem(value: 'custom', child: Text('Custom')),
        ],
      ),
    );
  }
}
