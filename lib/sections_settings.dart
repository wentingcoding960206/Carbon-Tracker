import 'package:flutter/material.dart';

class SectionsSettings extends StatelessWidget {
  final String nameSectionsSettings;
  final VoidCallback onPressed;
  final Color textColor;
  const SectionsSettings({
    super.key,
    required this.nameSectionsSettings,
    required this.onPressed,
    required this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
        )
      ),
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  nameSectionsSettings,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                  ),
                )
              ],
            ),
        
            const SizedBox(height: 10,),
        
            Divider(
              color: Colors.grey,
              thickness: 2,
            )
          ],
        ),
      ),
    );
  }
}