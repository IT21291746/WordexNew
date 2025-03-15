// ignore_for_file: library_private_types_in_public_api, unused_field, avoid_print, unused_element, prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:wordex_app/lj.dart';

class Rac extends StatefulWidget {
  final Map<String, String> userDetails;
  final Map<String, dynamic> summaryDetails;

  const Rac({super.key, required this.userDetails, required this.summaryDetails});

  @override
  _RacState createState() => _RacState();
}

class _RacState extends State<Rac> {
  int _currentQuestionIndex = -2;
  int _timeLeft = 30;
  int _totalCorrect = 0;
  int _totalTimeSpent = 0;
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _results = [];
  bool _isListening = false;
  String _correctAnswer = "";
  late stt.SpeechToText _speech;
  String _spokenText = "";
  Timer? _timer;
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
        Future.delayed(const Duration(seconds: 3), () {

    _speech = stt.SpeechToText();
    setState(() => _currentQuestionIndex = -1);

    _fetchQuestions();

        });
  }

  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('We need microphone access to record your voice. Please grant permission.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _startRecording() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = "";
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
            _resetSilenceTimer();
            _checkAnswerAndSubmit();
          },
        );
        _startSilenceTimer();
      }
    } else {
      _stopRecording();
    }
  }

  void _stopRecording() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    _stopSilenceTimer();
  }

  void _startSilenceTimer() {
    _silenceTimer = Timer(const Duration(seconds: 3), () {
      if (_isListening) {
        _stopRecording();
      }
    });
  }

  void _stopSilenceTimer() {
    _silenceTimer?.cancel();
  }

  void _resetSilenceTimer() {
    _stopSilenceTimer();
    _startSilenceTimer();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.2:8080/racq/random'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _questions = data.map((q) => {"question": q["question"], "answer": q["answer"]}).toList();
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _currentQuestionIndex = 0;
            _correctAnswer = _questions[_currentQuestionIndex]['answer'];  
            _startTimer();
          });
        });
      }
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }


   
  Widget _buildLoadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logoSmall.png', height: 100),
        SizedBox(height: 20),
        Text("Round 02", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
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


  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitAnswer();
      }
    });
  }

  // Function to check if the spoken text matches the correct answer
  void _checkAnswerAndSubmit() {
    String spokenAnswer = _spokenText.trim().toLowerCase();
    String correctAnswer = _correctAnswer.trim().toLowerCase();

    if (spokenAnswer == correctAnswer) {
      _submitAnswer();
    }
  }

  void _submitAnswer() {
    _timer?.cancel();
    bool isCorrect = _spokenText.trim().toLowerCase() == _correctAnswer.toLowerCase();
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
        _correctAnswer = _questions[_currentQuestionIndex]['answer'];  // Update correct answer for next question
        _spokenText = "";
        _startTimer();
      });
    } else {
      setState(() => _currentQuestionIndex = -3);
    }
  }

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Q0${_currentQuestionIndex + 1}: ${_questions[_currentQuestionIndex]['question']}",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text("${_questions[_currentQuestionIndex]['answer']}", style: const TextStyle(fontSize: 18, color: Colors.blue)),
          const SizedBox(height: 20),
          _isListening
              ? Column(
                  children: [
                    const Text("Listening...", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.red)),
                    IconButton(icon: const Icon(Icons.stop, size: 40, color: Colors.red), onPressed: _stopRecording),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.mic, size: 50, color: Colors.blue),
                  onPressed: _startRecording,
                ),
          const SizedBox(height: 20),
          Text(_spokenText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _submitAnswer, child: const Text("Submit Answer")),
          const SizedBox(height: 20),
          Text("Time Left: $_timeLeft s", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSummary() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Rac Summary",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
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
            // Construct the racSummaryDetails map
            Map<String, int> racSummaryDetails = {};
            for (int i = 0; i < _results.length; i++) {
              racSummaryDetails["Q${i + 1}"] = _results[i]["correct"] == "Correct" ? 1 : 0;
            }

            // Add total correct answers and time spent
            racSummaryDetails["totalCorrect"] = _totalCorrect;
            racSummaryDetails["totalTimeSpent"] = _totalTimeSpent;

            // Navigate to Lj and pass racSummaryDetails
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Lj(
                  userDetails: widget.userDetails,
                  summaryDetails: widget.summaryDetails,
                  racSummaryDetails: racSummaryDetails, // Pass racSummaryDetails to Lj
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
                icon: const Icon(Icons.house_sharp, color: Colors.red, size: 40),
                onPressed: () => Navigator.pop(context),
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
}
