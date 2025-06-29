import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _notificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListTile(
        title: const Text(
          'Enable Notifications',
          style: TextStyle(
            fontSize: 20, // bigger text
          ),
        ),
        trailing: CupertinoSwitch(
          value: _notificationEnabled,
          activeTrackColor: Colors.deepPurple, // customize color if you want
          onChanged: (bool value) {
            setState(() {
              _notificationEnabled = value;
            });
          },
        ),
      ),
    );
  }
}
