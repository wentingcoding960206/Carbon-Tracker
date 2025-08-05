import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SemiCircleMenu extends StatefulWidget {
  final List<IconData> icons;
  final double radius;
  final void Function(int) onItemTap;
  final double distanceInMeters; // 
  final String userId; // 

  const SemiCircleMenu({
    super.key,
    required this.icons,
    required this.radius,
    required this.onItemTap,
    required this.distanceInMeters,
    required this.userId,
  });

  @override
  _SemiCircleMenuState createState() => _SemiCircleMenuState();
}


class _SemiCircleMenuState extends State<SemiCircleMenu> {
  int selectedIndex = 3;
  double dragDelta = 0.0;

  void _handlePanUpdate(DragUpdateDetails details) {
    dragDelta += details.delta.dx;

    if (dragDelta.abs() > 20) {
      setState(() {
        if (dragDelta > 0 && selectedIndex > 0) {
          selectedIndex--;
        } else if (dragDelta < 0 && selectedIndex < widget.icons.length - 1) {
          selectedIndex++;
        }
        widget.onItemTap(selectedIndex);
        _saveToFirebase();
        dragDelta = 0;
      });
    }
  }



  void _saveToFirebase() {
    final List<double> carbonemission = [0.255, 0.11, 0, 0.0197, 0.1, 0.035, 0.04];
    
  double carbonFactor = (selectedIndex >= 0 && selectedIndex < carbonemission.length)
      ? carbonemission[selectedIndex]
      : 0;

  final double carbon = widget.distanceInMeters * carbonFactor;

  FirebaseFirestore.instance
    .collection('carbon_records')
    .add({
      'userId': widget.userId,
      'timestamp': Timestamp.now(),
      'selectedIndex': selectedIndex,
      'distance': widget.distanceInMeters,
      'carbonEmission': carbon,
    })
    .then((_) => print("成功儲存至 Firebase"))
    .catchError((e) => print("儲存失敗: $e"));
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = 32.0;
    final visibleCount = min(5, widget.icons.length);
    final double angleStep = pi / (visibleCount - 1);

    final List<Widget> iconWidgets = [];

    for (int i = 0; i < visibleCount; i++) {
      int relativeIndex = selectedIndex - (visibleCount ~/ 2) + i;

      if (relativeIndex < 0 || relativeIndex >= widget.icons.length) continue;

      final angle = pi - i * angleStep;
      final double x = widget.radius * cos(angle);
      final double y = widget.radius * sin(angle);

      final icon = Icon(
        widget.icons[relativeIndex],
        size: iconSize,
        color: i == visibleCount ~/ 2 ? Colors.blueAccent : Colors.grey,
      );

      iconWidgets.add(Positioned(
        bottom: y,
        left: (widget.radius * 2 + iconSize) / 2 + x - iconSize / 2 - 3,
        child: icon,
      ));
    }

    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      child: SizedBox(
        width: widget.radius * 2 + iconSize,
        height: widget.radius + iconSize + 20,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: iconWidgets,
        ),
      ),
    );
  }
}
