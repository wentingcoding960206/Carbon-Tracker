import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => Settings();
}

Future<void> _clearAllSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  debugPrint("✅ All SharedPreferences data has been deleted.");
}

class Settings extends State<SettingsPage> {
  bool isTrackingEnabled = true;
  bool isAnonymized = false;
  bool autoSaveEnabled = true;

  void _deleteTimelineData() {
    // Add your delete logic here
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Timeline Data"),
        content: const Text(
          "Are you sure you want to delete all timeline data? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _clearAllSharedPreferences(); // ← Deletes all stored data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Timeline data deleted.")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTimeline() async {
    final prefs = await SharedPreferences.getInstance();

    // Collect only timeline-related data (optional: collect everything)
    final keys = prefs.getKeys();
    final timelineKeys = keys
        .where((key) => key.startsWith('activities-'))
        .toList();

    StringBuffer buffer = StringBuffer();
    for (var key in timelineKeys) {
      buffer.writeln('--- $key ---');
      final list = prefs.getStringList(key) ?? [];
      for (var item in list) {
        buffer.writeln(item);
      }
      buffer.writeln('');
    }

    if (buffer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No timeline data to share.")),
      );
      return;
    }

    // Save text to a temporary file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/timeline.txt';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    // Share file
    await Share.shareXFiles([
      XFile(filePath),
    ], text: 'Here is my timeline data.');
  }

  void _viewPrivacyPolicy() {
    // Open webview or show content
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Privacy Policy"),
        content: SingleChildScrollView(
          child: Text(
            "We respect your privacy. This app collects location data to build your timeline, but data is stored locally and never shared unless you choose to. You can disable tracking or delete your data anytime.",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Privacy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Enable Timeline Tracking"),
            subtitle: const Text("Track and display your daily movements"),
            value: isTrackingEnabled,
            onChanged: (val) => setState(() => isTrackingEnabled = val),
          ),
          SwitchListTile(
            title: const Text("Anonymize Shared Data"),
            subtitle: const Text(
              "Hide personal details when exporting or sharing",
            ),
            value: isAnonymized,
            onChanged: (val) => setState(() => isAnonymized = val),
          ),
          SwitchListTile(
            title: const Text("Auto Save Timeline"),
            subtitle: const Text(
              "Save activity history automatically on device",
            ),
            value: autoSaveEnabled,
            onChanged: (val) => setState(() => autoSaveEnabled = val),
          ),

          ListTile(
            title: const Text("Delete My Timeline Data"),
            trailing: const Icon(Icons.delete, color: Colors.red),
            onTap: _deleteTimelineData,
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Sharing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text("Share My Timeline"),
            subtitle: const Text(
              "Send a summary of today’s timeline to someone else",
            ),
            trailing: const Icon(Icons.share),
            onTap: () => _shareTimeline(),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "More",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text("View Privacy Policy"),
            trailing: const Icon(Icons.privacy_tip),
            onTap: _viewPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}
