import 'package:carbon_tracker/settings_screen/sections_settings.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = '';

  void _showEditDialog() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempName = '';
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter new name'),
            onChanged: (value) {
              tempName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(tempName),
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _userName = newName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          'Account Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        '/Users/wangwenting/carbon_tracker/assets/images/person_icon.png',
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: _showEditDialog,
                          icon: Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),

              SectionsSettings(
                nameSectionsSettings: 'Privacy & Sharing',
                onPressed: () {
                  print('Privacy and Sharing');
                },
                textColor: Colors.black,
              ),

              SectionsSettings(
                nameSectionsSettings: 'Notifications',
                onPressed: () {
                  print('Notifications');
                },
                textColor: Colors.black,
              ),

              SectionsSettings(
                nameSectionsSettings: 'Statistics',
                onPressed: () {
                  print('Statistics');
                },
                textColor: Colors.black,
              ),

              SectionsSettings(
                nameSectionsSettings: 'Sign Out',
                onPressed: () {
                  print('Sign Out');
                },
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
