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
  _SemiCircleMenuState createState() => _SemiCircleMenuState();
}

class _SemiCircleMenuState extends State<SemiCircleMenu> {
  double rotationAngle = 0;

  @override
  Widget build(BuildContext context) {
    final double angleStep = pi / (widget.icons.length - 1);
    final double iconSize = 24;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          rotationAngle += details.localPosition.dx * 0.01;
        });
      },
      child: SizedBox(
        width: widget.radius * 2 + 2 * iconSize,
        height: widget.radius + iconSize + 20,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: List.generate(widget.icons.length, (index) {
            final double angle = pi - (angleStep * index) + rotationAngle;
            final double x = widget.radius * cos(angle);
            final double y = widget.radius * sin(angle);

            return Positioned(
              bottom: y,
              left: widget.radius + x - iconSize / 2,
              child: IconButton(
                icon: Icon(widget.icons[index]),
                iconSize: iconSize,
                onPressed: () => widget.onItemTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}
