import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carbon_tracker/SectionsSettings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  void _showEditDialog() {
    final TextEditingController controller = TextEditingController(
      text: _username,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter new username',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _username = newName;
                });
                _saveUsername(newName);
              }
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text(
          'Account Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔽 Username Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: _showEditDialog,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔽 Sections
              SectionsSettings(
                nameSectionsSettings: 'Personal Information',
                iconsSectionsSettings: Icons.person_2_outlined,
                onPressed: () => print("Personal Infomation"),
              ),
              SectionsSettings(
                nameSectionsSettings: 'Notifications',
                iconsSectionsSettings: Icons.notification_add_outlined,
                onPressed: () => print("Notifications"),
              ),
              SectionsSettings(
                nameSectionsSettings: 'Order History',
                iconsSectionsSettings: Icons.history,
                onPressed: () => print("Order History"),
              ),
              SectionsSettings(
                nameSectionsSettings: 'About Us & Attributes',
                iconsSectionsSettings: Icons.info_outline,
                onPressed: () => print("Attributes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
