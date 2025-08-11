import 'package:flutter/material.dart';

class CalendarFilterButton extends StatelessWidget {
  final VoidCallback onCalendarPressed;

  const CalendarFilterButton({
    super.key,
    required this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PopupMenuButton<String>(
        icon: GestureDetector(
          onTap: () {
            onCalendarPressed();  // Call the passed function here
          },
          child: const Icon(Icons.calendar_today),
        ),
        offset: const Offset(0, 45),
        onSelected: (value) {
          print('Selected: $value');
          // Your existing selection logic here
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
