import 'dart:math';
import 'package:flutter/material.dart';

class SemiCircleMenu extends StatefulWidget {
  final List<IconData> icons;
  final double radius;
  final void Function(int) onItemTap;

  const SemiCircleMenu({
    Key? key,
    required this.icons,
    required this.radius,
    required this.onItemTap,
  }) : super(key: key);

  @override
  _SemiCircleMenuState createState() => _SemiCircleMenuState();
}

class _SemiCircleMenuState extends State<SemiCircleMenu> {
  double rotationAngle = 0; // 用來追蹤當前的旋轉角度

  @override
  Widget build(BuildContext context) {
    final double angleStep = pi / (widget.icons.length - 1);
    final double iconSize = 24;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // 根據拖動的水平方向更新旋轉角度
          rotationAngle += details.localPosition.dx * 0.01; // 調整旋轉的敏感度
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
