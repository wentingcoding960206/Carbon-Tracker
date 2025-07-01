import 'package:flutter/material.dart';

class RankCard extends StatelessWidget {
  final int rankNumber;
  final String person;
  final String carbonFootprint;
  const RankCard({
    super.key,
    required this.rankNumber,
    required this.person,
    required this.carbonFootprint
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(51, 158, 158, 158),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$rankNumber'),
              Text(person),
              Text('$carbonFootprint g/km')
            ],
          ),
        ),
      ),
    );
  }
}