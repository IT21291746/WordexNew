// ignore_for_file: library_private_types_in_public_api, unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordex_app/home.dart';
import 'package:wordex_app/wj.dart';

class Lj extends StatefulWidget {
  final Map<String, String> userDetails;
   final Map<String, dynamic> summaryDetails;
   final Map<String, dynamic> racSummaryDetails;

  const Lj({super.key, required this.userDetails, required this.summaryDetails, required this.racSummaryDetails});

  @override
  _LjState createState() => _LjState();
}

class _LjState extends State<Lj> {
  int _currentQuestionIndex = -2; // -2 for loading, -1 for countdown
  int _timeLeft = 30;
  int _totalCorrect = 0;
  int _totalTimeSpent = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _questions = [
    {"question": "What is 5 + 3?", "options": ["6", "7", "8", "9"], "answer": "8"},
    {"question": "What is the capital of France?", "options": ["London", "Berlin", "Paris", "Rome"], "answer": "Paris"},
    {"question": "Which planet is closest to the sun?", "options": ["Earth", "Mercury", "Mars", "Venus"], "answer": "Mercury"},
    {"question": "What is 12 / 4?", "options": ["2", "3", "4", "6"], "answer": "3"},
    {"question": "Which is a programming language?", "options": ["Java", "Banana", "Car", "Lion"], "answer": "Java"},
  ];

  final List<Map<String, dynamic>> _results = [];

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitAnswer(null);
      }
    });
  }

  void _submitAnswer(String? selectedOption) {
    _timer?.cancel();
    bool isCorrect = selectedOption == _questions[_currentQuestionIndex]["answer"];
    if (isCorrect) _totalCorrect++;
    _totalTimeSpent += (30 - _timeLeft);

    _results.add({
      "question": "Q0${_currentQuestionIndex + 1}",
      "correct": isCorrect ? "Correct" : "Wrong",
      "time": 30 - _timeLeft,
    });

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _startTimer();
      });
    } else {
      setState(() => _currentQuestionIndex = -3); // Show summary
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      setState(() => _currentQuestionIndex = -1);
      Future.delayed(Duration(seconds: 4), () {
        setState(() {
          _currentQuestionIndex = 0;
          _startTimer();
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildSummary() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Lj Summary",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
                        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:DataTable(
          columns: [
            DataColumn(label: Text("Q No.")),
            DataColumn(label: Text("Correct/Wrong")),
            DataColumn(label: Text("Time (s)")),
          ],
          rows: _results.map((res) {
            return DataRow(cells: [
              DataCell(Text(res["question"])),
              DataCell(Text(res["correct"])),
              DataCell(Text(res["time"].toString())),
            ]);
          }).toList(),
        ),
                        ),
        SizedBox(height: 20),
        Text(
          "Total Correct: $_totalCorrect",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        Text(
          "Total Time: $_totalTimeSpent s",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
                  
SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
// Construct the summary with Q1-Q5 values
Map<String, int> ljSummaryDetails = {};
for (int i = 0; i < _results.length; i++) {
  ljSummaryDetails["Q${i + 1}"] = _results[i]["correct"] == "Correct" ? 1 : 0;
}

// Add total correct answers and time spent
ljSummaryDetails["totalCorrect"] = _totalCorrect;
ljSummaryDetails["totalTimeSpent"] = _totalTimeSpent;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => Wj(
      userDetails: widget.userDetails,
      summaryDetails: widget.summaryDetails,
      racSummaryDetails: widget.racSummaryDetails,
      ljSummaryDetails: ljSummaryDetails,
    ),
  ),
);

            },
            child: Text("Continue", style: GoogleFonts.poppins(fontSize: 18)),
          ),
          
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: IconButton(
                icon: Icon(Icons.house_sharp, color: Colors.red, size: 40),
                onPressed: () => _showExitConfirmation(),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _currentQuestionIndex == -2
                  ? _buildLoadingScreen()
                  : _currentQuestionIndex == -1
                      ? _buildCountdown()
                      : _currentQuestionIndex == -3
                          ? _buildSummary()
                          : _buildQuestion(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logoSmall.png', height: 100),
        SizedBox(height: 20),
        Text("Round 03", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(".... Test Round", style: GoogleFonts.poppins(fontSize: 18)),
        SizedBox(height: 20),
        CircularProgressIndicator(color: Colors.deepPurple),
      ],
    );
  }

  Widget _buildCountdown() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 3.0, end: 0.0),
      duration: Duration(seconds: 3),
      builder: (context, value, child) {
        return Center(
          child: Text(
            value.toInt() == 0 ? "Go!" : value.toInt().toString(),
            style: GoogleFonts.poppins(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        );
      },
    );
  }

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Q0${_currentQuestionIndex + 1}: ${_questions[_currentQuestionIndex]['question']}",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _questions[_currentQuestionIndex]['options'].map<Widget>((option) =>
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: ElevatedButton(
                    onPressed: () => _submitAnswer(option),
                    child: Text(option, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18)),
                  ),
                )).toList(),
          ),
          SizedBox(height: 20),
          Text("Time Left: $_timeLeft s", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

void _showExitConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Exit Lj"),
      content: Text("Are you sure you want to exit?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text("No")
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyHome(userDetails: widget.userDetails),
              ),
            );
          },
          child: Text("Yes"),
        ),
      ],
    ),
  );
}
}
