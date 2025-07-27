import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    fetchTopPlayers();
  }

  Future<void> fetchTopPlayers() async {
    try {
      print("Fetching top players...");
      QuerySnapshot query = await FirebaseFirestore.instance
          .collectionGroup('results')
          .get();

      print("Fetched results count: ${query.docs.length}");

      Map<String, Map<String, dynamic>> userTopScores = {};

      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userRef = doc.reference.parent.parent;
        final userSnapshot = await userRef!.get();

        final userData = userSnapshot.data();
        if (userData == null) continue;

        final uid = userRef.id;
        final userName =
            (userData as Map<String, dynamic>)['name'] ?? 'Unknown';

        if (!userTopScores.containsKey(uid)) {
          userTopScores[uid] = {
            'name': userName,
            'correctAnswers': 0,
            'totalQuestions': 0,
            'category': data['category'] ?? 'N/A',
          };
        }

        userTopScores[uid]!['correctAnswers'] += data['correctAnswers'] ?? 0;
        userTopScores[uid]!['totalQuestions'] += data['totalQuestions'] ?? 0;

        // Store latest category (override each time)
        userTopScores[uid]!['category'] = data['category'] ?? 'N/A';
      }

      final sortedList = userTopScores.values.toList()
        ..sort(
          (a, b) => (b['correctAnswers'] as int).compareTo(
            a['correctAnswers'] as int,
          ),
        );

      setState(() {
        _leaderboard = sortedList;
      });

      print("Leaderboard updated successfully.");
    } catch (e) {
      print("Error fetching leaderboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6CC), Color(0xFFF4C4C4), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.all(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Leaderboard",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFA726),
                              Color(0xFFF48FB1),
                              Color(0xFFAB47BC),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _leaderboard.isEmpty
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _leaderboard.length,
                                itemBuilder: (context, index) {
                                  final player = _leaderboard[index];
                                  return ListTile(
                                    leading: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      player["name"],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      "Category: ${player["category"] ?? "N/A"} • Total: ${player["totalQuestions"]}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Text(
                                      "${player["correctAnswers"]}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
