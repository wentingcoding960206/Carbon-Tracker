import 'package:carbon_tracker/rank_screen/rank_card.dart';
import 'package:flutter/material.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  List<Map<String, dynamic>> people = [
    {'account': 'ling26', 'carbon': 4.2},
    {'account': 'Bob', 'carbon': 5.6},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
    {'account': 'Charlie', 'carbon': 3.1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          'Ranking',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: people.length,
                itemBuilder: (context, index) {
                  final person = people[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: RankCard(
                      rankNumber: index + 1,
                      person: person['account'],
                      carbonFootprint: person['carbon'].toString(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.lightBlue.withOpacity(0.3),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Divider(
                color: Colors.grey,
                thickness: 2,
                height: 0, // removes extra spacing above divider
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: RankCard(rankNumber: 1, person: 'ling26', carbonFootprint: '4.2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
