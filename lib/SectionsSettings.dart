import 'package:flutter/material.dart';

class SectionsSettings extends StatelessWidget {
  final String nameSectionsSettings;
  final IconData iconsSectionsSettings;
  final VoidCallback onPressed;

  const SectionsSettings({
    super.key,
    required this.nameSectionsSettings,
    required this.iconsSectionsSettings,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Needed for ripple effect
      color: Colors.transparent, // Keep background transparent
      child: InkWell(
        onTap: () {
          onPressed();
          print('$nameSectionsSettings button pressed');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(iconsSectionsSettings),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      nameSectionsSettings,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}
