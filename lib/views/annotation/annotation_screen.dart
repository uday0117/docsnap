import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/annotation_controller.dart';
import '../../models/annotation_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/common_widgets.dart';

class AnnotationScreen extends GetView<AnnotationController> {
  const AnnotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'annotate'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: controller.undo,
            tooltip: 'undo'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: controller.clearAll,
            tooltip: 'clear'.tr,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final path = controller.imagePath.value;
              if (path == null || !File(path).existsSync()) {
                return _EmptyState(onPick: controller.pickImage);
              }
              return Column(
                children: [
                  _ToolBar(controller: controller),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _AnnotationCanvas(
                            controller: controller,
                            imagePath: path,
                            maxSize: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          _BottomActions(controller: controller),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPick;

  const _EmptyState({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.draw_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('pick_image_annotate'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.photo_library_rounded),
            label: Text('pick_image'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBar extends StatelessWidget {
  final AnnotationController controller;

  const _ToolBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _ToolChip(
              icon: Icons.edit_rounded,
              label: 'draw'.tr,
              selected: controller.activeTool.value == AnnotationType.draw,
              onTap: () => controller.setTool(AnnotationType.draw),
            ),
            _ToolChip(
              icon: Icons.crop_square_rounded,
              label: 'rectangle'.tr,
              selected: controller.activeTool.value == AnnotationType.rectangle,
              onTap: () => controller.setTool(AnnotationType.rectangle),
            ),
            _ToolChip(
              icon: Icons.circle_outlined,
              label: 'circle'.tr,
              selected: controller.activeTool.value == AnnotationType.circle,
              onTap: () => controller.setTool(AnnotationType.circle),
            ),
            _ToolChip(
              icon: Icons.arrow_forward_rounded,
              label: 'arrow'.tr,
              selected: controller.activeTool.value == AnnotationType.arrow,
              onTap: () => controller.setTool(AnnotationType.arrow),
            ),
            _ToolChip(
              icon: Icons.text_fields_rounded,
              label: 'text'.tr,
              selected: controller.activeTool.value == AnnotationType.text,
              onTap: () => controller.setTool(AnnotationType.text),
            ),
            const SizedBox(width: 12),
            for (final c in [
              Colors.red,
              Colors.black,
              Colors.blue,
              Colors.green,
              Colors.orange,
            ])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => controller.setStrokeColor(c),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: c,
                    child: controller.strokeColor.value == c
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToolChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor.withAlpha(50),
      ),
    );
  }
}

class _AnnotationCanvas extends StatelessWidget {
  final AnnotationController controller;
  final String imagePath;
  final Size maxSize;

  const _AnnotationCanvas({
    required this.controller,
    required this.imagePath,
    required this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: _imageAspectSize(imagePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final fitted = _fitSize(snapshot.data!, maxSize);
        controller.setCanvasSize(fitted);

        return Center(
          child: Container(
            width: fitted.width,
            height: fitted.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onPanStart: (d) => controller.onPanStart(d.localPosition),
                onPanUpdate: (d) => controller.onPanUpdate(d.localPosition),
                onPanEnd: (d) => controller.onPanEnd(d.localPosition),
                onTapUp: (d) {
                  if (controller.activeTool.value == AnnotationType.text) {
                    controller.onPanStart(d.localPosition);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(imagePath), fit: BoxFit.contain),
                    GetBuilder<AnnotationController>(
                      id: 'canvas',
                      builder: (ctrl) => CustomPaint(
                        painter: _AnnotationPainter(
                          strokes: ctrl.strokes.toList(),
                          shapes: ctrl.shapes.toList(),
                          textStamps: ctrl.textStamps.toList(),
                          previewPoints: ctrl.previewPoints,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Size> _imageAspectSize(String path) async {
    final image = FileImage(File(path));
    final completer = Completer<Size>();
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (!completer.isCompleted) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        }
      }),
    );
    return completer.future;
  }

  Size _fitSize(Size imageSize, Size maxSize) {
    final ratio = imageSize.width / imageSize.height;
    var width = maxSize.width;
    var height = width / ratio;
    if (height > maxSize.height) {
      height = maxSize.height;
      width = height * ratio;
    }
    return Size(width, height);
  }
}

class _AnnotationPainter extends CustomPainter {
  final List<AnnotationStroke> strokes;
  final List<AnnotationShape> shapes;
  final List<AnnotationTextStamp> textStamps;
  final List<Offset> previewPoints;

  _AnnotationPainter({
    required this.strokes,
    required this.shapes,
    required this.textStamps,
    required this.previewPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke.points, stroke.color, stroke.strokeWidth);
    }
    if (previewPoints.length >= 2) {
      _drawStroke(canvas, previewPoints, Colors.red, 3);
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
          canvas.drawLine(
            Offset(shape.rect.left, shape.rect.center.dy),
            Offset(shape.rect.right, shape.rect.center.dy),
            paint,
          );
        default:
          break;
      }
    }

    for (final stamp in textStamps) {
      final builder = TextPainter(
        text: TextSpan(
          text: stamp.text,
          style: TextStyle(color: stamp.color, fontSize: stamp.fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      builder.paint(canvas, stamp.position);
    }
  }

  void _drawStroke(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double width,
  ) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) => true;
}

class _BottomActions extends StatelessWidget {
  final AnnotationController controller;

  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.pickImage,
                icon: const Icon(Icons.photo_library_rounded),
                label: Text('change_image'.tr),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    controller.isSaving.value ? null : controller.saveAnnotatedImage,
                icon: const Icon(Icons.save_rounded),
                label: Text('save'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}