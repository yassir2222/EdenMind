import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class EmotionService {
  Interpreter? _interpreter;
  bool _isBusy = false;

  static const List<String> _labels = [
    'Neutral',
    'Happy',
    'Surprise',
    'Sad',
    'Angry',
    'Disgust',
    'Fear',
    'Contempt',
  ];

  int _inputSize = 48;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/emotion.tflite',
      );
      var inputTensor = _interpreter!.getInputTensor(0);
      _inputSize = inputTensor.shape[1];
      debugPrint('Emotion model loaded. Input size: $_inputSize');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<String> predictEmotion(
    CameraImage cameraImage,
    int x,
    int y,
    int w,
    int h,
  ) async {
    if (_interpreter == null || _isBusy) return "Waiting...";
    _isBusy = true;

    try {
      // Extract data to send to Isolate (CameraImage cannot be sent directly sometimes)
      final isolateInput = IsolateInput(
        planes: cameraImage.planes
            .map(
              (p) => PlaneData(
                bytes: p.bytes,
                bytesPerRow: p.bytesPerRow,
                bytesPerPixel: p.bytesPerPixel,
              ),
            )
            .toList(),
        width: cameraImage.width,
        height: cameraImage.height,
        faceX: x,
        faceY: y,
        faceW: w,
        faceH: h,
        inputSize: _inputSize,
      );

      // Run heavy processing in background
      final input = await compute(_processImageInIsolate, isolateInput);

      if (input == null) return "Error";

      // Run Inference
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      var outputClasses = outputShape.last;
      var output = List.filled(
        1 * outputClasses,
        0.0,
      ).reshape([1, outputClasses]);

      _interpreter!.run(input, output);

      List<double> probs = List<double>.from(output[0]);
      int maxIndex = 0;
      double maxProb = probs[0];
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > maxProb) {
          maxProb = probs[i];
          maxIndex = i;
        }
      }
      if (maxIndex < _labels.length) {
        return _labels[maxIndex];
      }
      return "Unknown";
    } catch (e) {
      debugPrint('Emotion prediction error: $e');
      return "Error";
    } finally {
      _isBusy = false;
    }
  }

  // Static function to run in Isolate
  static List<List<List<List<double>>>>? _processImageInIsolate(
    IsolateInput data,
  ) {
    try {
      // 1. Convert YUV to RGB using image package (slow but robust, now off-thread)
      img.Image image = _convertYUV420ToImage(
        data.planes,
        data.width,
        data.height,
      );

      // 2. Rotate if needed (Front camera usually needs 270 aka -90 for display,
      // but raw buffer is usually landscape 90 relative to sensor.
      // We'll rotate to make it upright for cropping.)
      // Note: FaceDetector coordinates from ML Kit (if not transformed) are relative to the *detected* image.
      // If we rotate the image, we must ensure coordinates catch up or rotate image to match coordinates.
      // Standard fix: Rotate image to upright portrait first.

      img.Image rotated = img.copyRotate(image, angle: 270);

      // 3. Crop Face
      // Ensure coordinates are within bounds
      int left = data.faceX.clamp(0, rotated.width - 1);
      int top = data.faceY.clamp(0, rotated.height - 1);
      int width = data.faceW;
      int height = data.faceH;

      if (left + width > rotated.width) width = rotated.width - left;
      if (top + height > rotated.height) height = rotated.height - top;

      if (width <= 0 || height <= 0) return null;

      img.Image faceCrop = img.copyCrop(
        rotated,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      // 4. Resize
      img.Image resized = img.copyResize(
        faceCrop,
        width: data.inputSize,
        height: data.inputSize,
      );

      // 5. Normalize
      var input = List.generate(
        1,
        (i) => List.generate(
          data.inputSize,
          (j) => List.generate(data.inputSize, (k) => List.filled(1, 0.0)),
        ),
      );

      for (int y = 0; y < data.inputSize; y++) {
        for (int x = 0; x < data.inputSize; x++) {
          img.Pixel pixel = resized.getPixel(x, y);
          double gray = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
          input[0][y][x][0] = gray / 255.0;
        }
      }

      return input;
    } catch (e) {
      debugPrint("Isolate processing error: $e");
      return null;
    }
  }

  static img.Image _convertYUV420ToImage(
    List<PlaneData> planes,
    int width,
    int height,
  ) {
    final int uvRowStride = planes[1].bytesPerRow;
    final int uvPixelStride = planes[1].bytesPerPixel ?? 1;

    final img.Image image = img.Image(width: width, height: height);

    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        final int uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;

        final y = planes[0].bytes[index];
        final u = planes[1].bytes[uvIndex];
        final v = planes[2].bytes[uvIndex];

        int r = (y + (1.370705 * (v - 128))).toInt();
        int g = (y - (0.337633 * (u - 128)) - (0.698001 * (v - 128))).toInt();
        int b = (y + (1.732446 * (u - 128))).toInt();

        image.setPixelRgb(
          w,
          h,
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
      }
    }
    return image;
  }

  void dispose() {
    _interpreter?.close();
  }
}

class IsolateInput {
  final List<PlaneData> planes;
  final int width;
  final int height;
  final int faceX;
  final int faceY;
  final int faceW;
  final int faceH;
  final int inputSize;

  IsolateInput({
    required this.planes,
    required this.width,
    required this.height,
    required this.faceX,
    required this.faceY,
    required this.faceW,
    required this.faceH,
    required this.inputSize,
  });
}

class PlaneData {
  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;

  PlaneData({
    required this.bytes,
    required this.bytesPerRow,
    this.bytesPerPixel,
  });
}
