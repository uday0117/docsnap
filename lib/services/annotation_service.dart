import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/annotation_model.dart';

class AnnotationService extends GetxService {
  Future<String> renderAnnotations({
    required String imagePath,
    required List<AnnotationStroke> strokes,
    required List<AnnotationShape> shapes,
    required List<AnnotationTextStamp> textStamps,
    required Size canvasSize,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Could not read image.');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final imageWidth = decoded.width.toDouble();
    final imageHeight = decoded.height.toDouble();

    final srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final dstRect = Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);

    final uiImage = await _decodeUiImage(bytes);
    canvas.drawImageRect(uiImage, srcRect, dstRect, Paint());

    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color
        ..strokeWidth = shape.strokeWidth
        ..style = PaintingStyle.stroke;
      switch (shape.type) {
        case AnnotationType.rectangle:
          canvas.drawRect(shape.rect, paint);
        case AnnotationType.circle:
          canvas.drawOval(shape.rect, paint);
        case AnnotationType.arrow:
          _drawArrow(canvas, shape.rect, paint);
        case AnnotationType.draw:
        case AnnotationType.text:
          break;
      }
    }

    for (final stamp in textStamps) {
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: TextAlign.left),
      )
        ..pushStyle(ui.TextStyle(
          color: stamp.color,
          fontSize: stamp.fontSize,
        ))
        ..addText(stamp.text);
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: canvasSize.width));
      canvas.drawParagraph(paragraph, stamp.position);
    }

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(
      canvasSize.width.round(),
      canvasSize.height.round(),
    );
    final pngBytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytes == null) throw Exception('Failed to render annotations.');

    final scaled = img.decodeImage(pngBytes.buffer.asUint8List());
    if (scaled == null) throw Exception('Failed to encode annotated image.');

    final output = img.copyResize(
      scaled,
      width: decoded.width,
      height: decoded.height,
    );

    final dir = await getApplicationDocumentsDirectory();
    final outPath = p.join(
      dir.path,
      'docsnap',
      'annotated',
      '${const Uuid().v4()}.jpg',
    );
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(output, quality: 92));
    return outPath;
  }

  void _drawArrow(Canvas canvas, Rect rect, Paint paint) {
    final start = Offset(rect.left, rect.center.dy);
    final end = Offset(rect.right, rect.center.dy);
    canvas.drawLine(start, end, paint);

    const arrowSize = 12.0;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize, end.dy - arrowSize / 2)
      ..lineTo(end.dx - arrowSize, end.dy + arrowSize / 2)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  Future<ui.Image> _decodeUiImage(List<int> bytes) async {
    final codec = await ui.instantiateImageCodec(
      Uint8List.fromList(bytes),
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
