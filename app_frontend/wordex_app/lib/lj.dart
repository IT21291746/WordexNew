// ignore_for_file: library_private_types_in_public_api, unused_field, avoid_print, prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:wordex_app/wj.dart';


class Lj extends StatefulWidget {
  final Map<String, String> userDetails;
  final Map<String, dynamic> summaryDetails;
  final Map<String, dynamic> racSummaryDetails;

  const Lj({
    super.key,
    required this.userDetails,
    required this.summaryDetails,
    required this.racSummaryDetails,
  });

  @override
  _LjState createState() => _LjState();
}

class _LjState extends State<Lj> {
  int _currentQuestionIndex = -2;
  int _timeLeft = 30;
  int _totalCorrect = 0;
  int _totalTimeSpent = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _results = [];
  String _recognizedText = "";
  List<Offset> _currentStroke = [];
  List<List<Offset>> _strokes = [];
  File? _savedImage;
  String _correctAnswer = "";


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _currentQuestionIndex = -1);
      _fetchQuestions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitAnswer(null);
      }
    });
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.2:8080/ljq/random'));
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


void _submitAnswer(String? selectedOption) {
  _timer?.cancel();
  bool isCorrect = _recognizedText == _correctAnswer;
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
              _correctAnswer = _questions[_currentQuestionIndex]['answer'];  
                      _recognizedText = "";
      _startTimer();
      _clearDrawing();
    });
  } else {
    setState(() => _currentQuestionIndex = -3);
  }
}

  void _clearDrawing() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
      _recognizedText = "";
      _savedImage = null;
    });
  }

  Future<void> _recognizeText() async {
    if (_strokes.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0 // 🔥 Reduced for better accuracy
      ..style = PaintingStyle.stroke;

    // ✅ White Background & Padding for better OCR recognition
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(10, 10, 580, 580), backgroundPaint);

    for (var stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(600, 600);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
    File file = File(filePath);
    await file.writeAsBytes(buffer);

    // ✅ Load Image for Advanced Preprocessing
    img.Image decodedImage = img.decodeImage(await file.readAsBytes())!;

    // ✅ 1. Flip Image (Fixes "M" vs. "W" issue)
    decodedImage = img.flipVertical(decodedImage);

    // ✅ 2. Convert to Grayscale (Removes background noise)
    decodedImage = img.grayscale(decodedImage);

    // ✅ 3. Apply Adaptive Thresholding (Improves contrast)
    decodedImage = img.adjustColor(decodedImage, contrast: 180);

    // ✅ 4. Denoise Image (Removes artifacts for clearer letters)
    decodedImage = img.gaussianBlur(decodedImage, radius: 1);

    // ✅ 5. Edge Detection (Enhances boundaries)
    decodedImage = img.sobel(decodedImage);

    // ✅ 6. Rotate correction (if needed)
    decodedImage = img.copyRotate(decodedImage, angle: 0);

    // Save the processed image
    file = File(filePath)..writeAsBytesSync(img.encodePng(decodedImage));

    // Store the image file for display
    setState(() {
      _savedImage = file;
    });

    // ✅ OCR Recognition with Custom Filtering
    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      String text = recognizedText.text.trim();
      if (text.isNotEmpty) {
        _recognizedText = text.toUpperCase();
      } else {
        _recognizedText = "Try Again";
      }
    });

    await textRecognizer.close();
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
          Text("${_questions[_currentQuestionIndex]['answer']}", style: const TextStyle(fontSize: 65, color: Colors.green)),
          const SizedBox(height: 20),
          GestureDetector(
            onPanStart: (details) {
              _currentStroke = [details.localPosition];
            },
            onPanUpdate: (details) {
              setState(() {
                _currentStroke.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              if (_currentStroke.isNotEmpty) {
                setState(() {
                  _strokes.add(List.from(_currentStroke));
                  _currentStroke.clear();
                });
              }
            },
            child: CustomPaint(
              size: const Size(300, 300),
              painter: SignaturePainter(_strokes, _currentStroke),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              ),
            ),
          ),
                        ElevatedButton(
                onPressed: _recognizeText,
                child: const Text("Recognize"),
              ),
          ElevatedButton(onPressed: _clearDrawing, child: const Text("Clear")),
          const SizedBox(height: 10),
          Text("Recognized Letter is   $_recognizedText", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => _submitAnswer(_recognizedText), child: const Text("Submit")),
          Text("Time left: $_timeLeft seconds", style: const TextStyle(fontSize: 18)),
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
        Text("Letter Identification Test Round", style: GoogleFonts.poppins(fontSize: 18)),
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

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  SignaturePainter(this.strokes, this.currentStroke);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    for (var stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
