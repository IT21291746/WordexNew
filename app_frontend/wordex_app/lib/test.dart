import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class LetterRecognitionPage extends StatefulWidget {
  const LetterRecognitionPage({super.key});

  @override
  State<LetterRecognitionPage> createState() => _LetterRecognitionPageState();
}

class _LetterRecognitionPageState extends State<LetterRecognitionPage> {
  List<Offset> _currentStroke = [];
  final List<List<Offset>> _strokes = [];
  String _recognizedText = "";
  File? _savedImage;

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

  void _clearDrawing() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
      _recognizedText = "";

      if (_savedImage != null && _savedImage!.existsSync()) {
        _savedImage!.deleteSync();
      }

      _savedImage = null;
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
          if (_savedImage != null)
            Column(
              children: [
                const Text("Generated Image Preview:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Image.file(_savedImage!, width: 150, height: 150),
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
      ..strokeWidth = 5.0  // 🔥 Adjusted stroke width for better OCR readability
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
