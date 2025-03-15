// ignore_for_file: library_private_types_in_public_api, unused_field, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:wordex_app/rac.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
            Future.delayed(const Duration(seconds: 3), () {

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
              });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },
                  ),
                ],
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class Quiz extends StatefulWidget {
  final Map<String, String> userDetails;

  const Quiz({super.key, required this.userDetails});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _currentQuestionIndex = -2; // -2 for loading, -1 for countdown
  int _timeLeft = 30;
  int _totalCorrect = 0;
  int _totalTimeSpent = 0;
  Timer? _timer;

  List<Map<String, dynamic>> _questions = [];
  final List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }






  

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.2:8080/iq/random'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _questions = data.map((q) => {
            "question": q["question"],
            "options": (q["options"] as Map<String, dynamic>).values.toList(),
            "answer": q["answer"],
            "qImageUrl": q["qImageUrl"],
            "qAudioUrl": q["qAudioUrl"],
            "qVideoUrl": q["qVideoUrl"]
          }).toList();
          //_currentQuestionIndex = -1;
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _currentQuestionIndex = 0;
              _startTimer();
            });
          });
        });
      }
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }

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
    // Quiz completed, show summary
    setState(() {
      _currentQuestionIndex = -3; // Triggers _buildSummary()
    });
  }
}




    Widget _buildSummary() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Quiz Summary",
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Rac(
                    userDetails: widget.userDetails,
                    summaryDetails: {
                      "totalCorrect": _totalCorrect,
                      "totalTimeSpent": _totalTimeSpent,
                      "results": _results,
                    },
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


  Widget _buildLoadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logoSmall.png', height: 100),
        SizedBox(height: 20),
        Text("Round 01", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("IQ Test Round", style: GoogleFonts.poppins(fontSize: 18)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: Column(
        children: [
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


Widget _buildAudioPlayer(String audioUrl) {
  final player = AudioPlayer();

  return Column(
    children: [
      Text("Audio Available", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      IconButton(
        icon: Icon(Icons.play_circle_fill, size: 40, color: Colors.deepPurple),
        onPressed: () async {
          await player.stop(); // Stop any previous audio before playing new one
          await player.play(UrlSource(audioUrl)); // Play the audio from URL
        },
      ),
    ],
  );
}


Widget _buildVideoPlayer(String videoUrl) {
  return Column(
    children: [
      Text("Video Available", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      VideoPlayerWidget(videoUrl: videoUrl),
    ],
  );
}


Widget _buildQuestion() {
  final question = _questions[_currentQuestionIndex];

  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Question Text
        Text(
          "Q0${_currentQuestionIndex + 1}: ${question['question']}",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 10),

        // Display Image (if available)
        if (question['qImageUrl'] != null && question['qImageUrl'].isNotEmpty)
          Image.network(question['qImageUrl'], height: 200, fit: BoxFit.cover),

        SizedBox(height: 10),

        // Play Audio (if available)
        if (question['qAudioUrl'] != null && question['qAudioUrl'].isNotEmpty)
          _buildAudioPlayer(question['qAudioUrl']),

        SizedBox(height: 10),

        // Play Video (if available)
        if (question['qVideoUrl'] != null && question['qVideoUrl'].isNotEmpty)
          _buildVideoPlayer(question['qVideoUrl']),

        SizedBox(height: 20),

        // Options (Answers)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: question['options']
              .map<Widget>(
                (option) => SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: ElevatedButton(
                    onPressed: () => _submitAnswer(option),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                  ),
                ),
              )
              .toList(),
        ),

        SizedBox(height: 20),

        // Countdown Timer
        Text(
          "Time Left: $_timeLeft s",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ],
    ),
  );
}

}