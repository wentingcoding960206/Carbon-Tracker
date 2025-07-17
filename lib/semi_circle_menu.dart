import 'dart:math';
import 'package:flutter/material.dart';

class SemiCircleMenu extends StatefulWidget {
  final List<IconData> icons;
  final double radius;
  final void Function(int) onItemTap;

  const SemiCircleMenu({
    super.key,
    required this.icons,
    required this.radius,
    required this.onItemTap,
  });

  @override
  State<SemiCircleMenu> createState() => _SemiCircleMenuState();
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
        dragDelta = 0;
      });
    }
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
