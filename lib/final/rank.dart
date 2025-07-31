import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carbon_tracker/sections_rank.dart';
import 'package:flutter/material.dart';

class Rank extends StatefulWidget {
  final String userId;
  const Rank({super.key, required this.userId});

  @override
  State<Rank> createState() => _RankState();
}

class _RankState extends State<Rank> {
  List<Map<String, dynamic>> rankedUsers = [];
  int userRank = -1;

  @override
  void initState() {
    super.initState();
    fetchRanking();
  }

  Future<void> fetchRanking() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('carbon_records')
        .get();

    final Map<String, double> totals = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final emission = (data['carbonEmission'] ?? 0).toDouble();
      totals[userId] = (totals[userId] ?? 0) + emission;
    }

    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));//small->big

    final List<Map<String, dynamic>> top20 = [];
    int rank = 1;
    for (var entry in sortedEntries) {
      top20.add({
        'rank': rank,
        'userId': entry.key,
        'totalCarbon': entry.value,
      });

      if (entry.key == widget.userId) {
        userRank = rank;
      }

      if (rank >= 20) break;
      rank++;
    }

    // 如果使用者不在前 20，還是顯示其排名
    if (userRank == -1) {
      for (int i = 20; i < sortedEntries.length; i++) {
        if (sortedEntries[i].key == widget.userId) {
          userRank = i + 1;
          break;
        }
      }
    }

    setState(() {
      rankedUsers = top20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rank'), centerTitle: true),
      body: rankedUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rankedUsers.length,
              itemBuilder: (context, index) {
                final user = rankedUsers[index];
                return SectionsRank(
                  rank: user['rank'],
                  userId: user['userId'],
                  totalCarbon: user['totalCarbon'],
                  isUser: user['userId'] == widget.userId,
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.blue.shade50,
          child: Center(
            child: Text(
              userRank == -1
                  ? 'No records found for you'
                  : 'Your Rank: #$userRank',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*class _RankState extends State<Rank> {
  int userRank = 7; // You can make this dynamic later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rank'), centerTitle: true,),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return SectionsRank(rank: index + 1, isUser: index + 1 == userRank);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.blue.shade50,
          child: Center(
            child: Text(
              'Your Rank: #$userRank',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/