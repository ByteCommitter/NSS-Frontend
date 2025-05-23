import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This is a utility class to create a zoomed in version of the logo
// Run this file separately once to generate the zoomed logo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load the original image
  final ByteData data = await rootBundle.load('assets/images/Sereine Logo with Brain and Leaf.png');
  final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;
  
  // Create a zoomed in version by cropping just the central portion
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Define the crop area (focusing more on the center)
  final srcSize = Size(image.width.toDouble(), image.height.toDouble());
  final centerX = srcSize.width / 2;
  final centerY = srcSize.height / 2;
  
  // Adjust these values to zoom in more or less
  final cropWidth = srcSize.width * 0.7; // Crop to 70% of original width
  final cropHeight = srcSize.height * 0.7; // Crop to 70% of original height
  
  final srcRect = Rect.fromCenter(
    center: Offset(centerX, centerY),
    width: cropWidth,
    height: cropHeight,
  );
  
  final destRect = Rect.fromLTWH(0, 0, srcSize.width, srcSize.height);
  
  // Paint the cropped and zoomed image
  canvas.drawImageRect(
    image,
    srcRect,
    destRect,
    Paint()..filterQuality = FilterQuality.high,
  );
  
  final picture = recorder.endRecording();
  final zoomedImage = await picture.toImage(image.width, image.height);
  final pngBytes = await zoomedImage.toByteData(format: ui.ImageByteFormat.png);
  
  // Save the zoomed image
  final file = File('assets/images/sereine_logo_zoomed.png');
  await file.writeAsBytes(pngBytes!.buffer.asUint8List());
  
  print('Zoomed logo created and saved to: ${file.path}');
}