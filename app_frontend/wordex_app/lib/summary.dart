// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:wordex_app/home.dart';
import 'package:intl/intl.dart';

class Summary extends StatefulWidget {
  final Map<String, String> userDetails;
  final Map<String, dynamic> summaryDetails;
  final Map<String, dynamic> racSummaryDetails;
  final Map<String, dynamic> ljSummaryDetails;
  final Map<String, dynamic> wjSummaryDetails;
  final Map<String, dynamic> dsSummaryDetails;

  const Summary({
    super.key,
    required this.userDetails,
    required this.summaryDetails,
    required this.racSummaryDetails,
    required this.ljSummaryDetails,
    required this.wjSummaryDetails,
    required this.dsSummaryDetails,
  });

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String? racResult, dsResult, ljResult, wjResult;

  @override
  void initState() {
    super.initState();
    fetchDyslexiaResults();
  }

  Future<void> fetchDyslexiaResults() async {
String? birthDate = widget.userDetails["birthDate"];
int age = 0; // Declare 'age' before the if-else block

if (birthDate != null && birthDate.length >= 4) {
  String birthYearString = birthDate.substring(0, 4); // Extract first 4 characters
  int birthYear = int.parse(birthYearString); // Convert to integer
  age = DateTime.now().year - birthYear; // Subtract from current year
}

// Now 'age' is available throughout the function
print("User Age: $age");
print("User Age: $birthDate");






    // Send predictions for each test type
    await sendPrediction(
        "RAC", "http://172.20.10.2:5001/predict_rac", widget.racSummaryDetails, age);
    await sendPrediction(
        "DS", "http://172.20.10.2:5001/predict_ds", widget.dsSummaryDetails, age);
    await sendPrediction(
        "LJ", "http://172.20.10.2:5001/predict_letter_jumbling", widget.ljSummaryDetails, age);
    await sendPrediction(
        "WJ", "http://172.20.10.2:5001/predict_word_jumbling", widget.wjSummaryDetails, age);
  }

  Future<void> sendPrediction(
      String key, String url, Map<String, dynamic> roundDetails, int age) async {
    int iq = (widget.summaryDetails["totalCorrect"] ?? 0).toInt();
    int totalTimeSpent = (widget.summaryDetails["totalTimeSpent"] ?? 0).toInt() +
        (roundDetails["totalTimeSpent"] ?? 0).toInt();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Age": age,
          "IQ": iq,
          "Q1": (roundDetails["Q1"] ?? 0).toInt(),
          "Q2": (roundDetails["Q2"] ?? 0).toInt(),
          "Q3": (roundDetails["Q3"] ?? 0).toInt(),
          "Q4": (roundDetails["Q4"] ?? 0).toInt(),
          "Q5": (roundDetails["Q5"] ?? 0).toInt(),
          "Time Seconds": totalTimeSpent,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          var prediction = jsonDecode(response.body)["prediction"];
          if (key == "RAC") racResult = prediction;
          if (key == "DS") dsResult = prediction;
          if (key == "LJ") ljResult = prediction;
          if (key == "WJ") wjResult = prediction;
        });
      }
    } catch (e) {
      print("Error sending prediction for $key: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        title: Text("Quiz Summary", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoundSummary("Round 01 - IQ Test", widget.summaryDetails, null),
              _buildRoundSummary("Round 02 - RAC Test", widget.racSummaryDetails, racResult),
              _buildRoundSummary("Round 03 - LJ Test", widget.ljSummaryDetails, ljResult),
              _buildRoundSummary("Round 04 - WJ Test", widget.wjSummaryDetails, wjResult),
              _buildRoundSummary("Round 05 - Final Test", widget.dsSummaryDetails, dsResult),
              Divider(thickness: 2),
              _buildGrandSummary(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
  onPressed: () async {
    // Send summary data to the backend to save in the database
    await saveSummaryToDatabase();
    
    // Navigate to the home page after saving
if (mounted) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => MyHome(userDetails: widget.userDetails),
    ),
  );
}
  },
  child: Text("Continue", style: GoogleFonts.poppins(fontSize: 18)),
),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundSummary(String roundTitle, Map<String, dynamic> roundData, String? result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(roundTitle, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        SizedBox(height: 5),
        Text("Total Correct Answers - ${(roundData["totalCorrect"] ?? 0).toInt()}/5", style: GoogleFonts.poppins(fontSize: 16)),
        Text("Total Time Taken - ${(roundData["totalTimeSpent"] ?? 0).toInt()}s", style: GoogleFonts.poppins(fontSize: 16)),
        if (result != null) Text("Dyslexia Prediction - $result", style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGrandSummary() {
    int totalCorrect = (widget.summaryDetails["totalCorrect"] ?? 0).toInt() +
        (widget.racSummaryDetails["totalCorrect"] ?? 0).toInt() +
        (widget.ljSummaryDetails["totalCorrect"] ?? 0).toInt() +
        (widget.wjSummaryDetails["totalCorrect"] ?? 0).toInt() +
        (widget.dsSummaryDetails["totalCorrect"] ?? 0).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Grand Summary", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
        SizedBox(height: 10),
        Text("Total No. of Correct Answers Given - $totalCorrect/25", style: GoogleFonts.poppins(fontSize: 16)),
      ],
    );
  }
  


Future<void> saveSummaryToDatabase() async {
  // Format timestamp correctly
  String timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now().toUtc());


  Map<String, dynamic> summaryData = {
    "userId": widget.userDetails['id'],
    "timestamp": timestamp, // Use the correctly formatted timestamp
    "totalCorrect": widget.summaryDetails["totalCorrect"] + widget.racSummaryDetails["totalCorrect"]+ widget.dsSummaryDetails["totalCorrect"]+ widget.ljSummaryDetails["totalCorrect"]+ widget.wjSummaryDetails["totalCorrect"],
    "totalTimeSpent": widget.summaryDetails["totalTimeSpent"] + widget.racSummaryDetails["totalTimeSpent"]+ widget.dsSummaryDetails["totalTimeSpent"]+ widget.ljSummaryDetails["totalTimeSpent"]+ widget.wjSummaryDetails["totalTimeSpent"],
    "racResult": racResult,
    "dsResult": dsResult,
    "ljResult": ljResult,
    "wjResult": wjResult,
    "racDetails": widget.racSummaryDetails,
    "dsDetails": widget.dsSummaryDetails,
    "ljDetails": widget.ljSummaryDetails,
    "wjDetails": widget.wjSummaryDetails,
  };

  try {
    final response = await http.post(
      Uri.parse("http://172.20.10.2:8080/quiz/saveSummary"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(summaryData),
    );

    if (response.statusCode == 201) {
      print("Summary saved successfully!");
    } else {
      print("Failed to save summary: ${response.statusCode}");
    }
  } catch (e) {
    print("Error saving summary: $e");
  }
}
}
