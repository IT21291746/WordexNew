// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class QuizHistory extends StatefulWidget {
  final Map<String, String> userDetails;

  const QuizHistory({super.key, required this.userDetails});

  @override
  _QuizHistoryState createState() => _QuizHistoryState();
}

class _QuizHistoryState extends State<QuizHistory> {
  List<dynamic> quizHistory = [];
  bool isLoading = true;



  @override
  void initState() {
    super.initState();
    fetchQuizHistory();
  }

  Future<void> fetchQuizHistory() async {
    try {
      String? userId = widget.userDetails["id"];
      final response = await http.get(
        Uri.parse('http://172.20.10.2:8080/quiz/summaries/$userId')
      );

      if (response.statusCode == 200) {
        setState(() {
          quizHistory = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Failed to fetch quiz history: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching quiz history: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        title: Text("Quiz History", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizHistory.isEmpty
              ? Center(child: Text("No quiz history found", style: GoogleFonts.poppins(fontSize: 18)))
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: quizHistory.length,
                  itemBuilder: (context, index) {
                    var quiz = quizHistory[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      color: Colors.white,
                      child: ListTile(
                        title: Text("Quiz Taken On: ${quiz['timestamp']}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Correct Answers: ${quiz['totalCorrect']}/25", style: GoogleFonts.poppins(fontSize: 16)),
                            Text("Total Time Spent: ${quiz['totalTimeSpent']}s", style: GoogleFonts.poppins(fontSize: 16)),
                            Text("RAC Result: ${quiz['racResult'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                            Text("DS Result: ${quiz['dsResult'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                            Text("LJ Result: ${quiz['ljResult'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                            Text("WJ Result: ${quiz['wjResult'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
