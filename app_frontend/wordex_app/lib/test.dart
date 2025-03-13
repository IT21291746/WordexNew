import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LetterRecognitionPage extends StatefulWidget {
  const LetterRecognitionPage({super.key});

  @override
  State<LetterRecognitionPage> createState() => _LetterRecognitionPageState();
}

class _LetterRecognitionPageState extends State<LetterRecognitionPage> {
  List<Offset> _currentStroke = [];
  final List<List<Offset>> _strokes = [];
  String _recognizedText = "";
  File? _savedImage; // Store the drawn image

  Future<void> _recognizeText() async {
    if (_strokes.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8.0 // Thicker strokes for better recognition
      ..style = PaintingStyle.stroke;

    // Fill background with white
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 600, 600), backgroundPaint);

    for (var stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(600, 600); // Higher resolution
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
final file = File('${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(buffer);

    // Store the image file for display
    setState(() {
      _savedImage = file;
    });

    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text.isNotEmpty ? recognizedText.text : "No text recognized";
    });

    await textRecognizer.close();
  }




void _clearDrawing() {
  setState(() {
    _strokes.clear();
    _currentStroke.clear();
    _recognizedText = "";

    // Delete the saved image from storage
    if (_savedImage != null && _savedImage!.existsSync()) {
      _savedImage!.deleteSync();
    }

    _savedImage = null; // Reset saved image

    // Force Flutter to clear image cache
    imageCache.clear();
    imageCache.clearLiveImages();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draw a Letter')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _recognizeText,
                child: const Text("Recognize"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _clearDrawing,
                child: const Text("Clear"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Recognized: $_recognizedText", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          if (_savedImage != null) // Show preview if image is saved
            Column(
              children: [
                const Text("Generated Image Preview:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Image.file(_savedImage!, width: 150, height: 150), // Display saved image
              ],
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
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint); 
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
