import 'dart:ui';

enum AnnotationType { draw, rectangle, circle, arrow, text }

class AnnotationStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const AnnotationStroke({
    required this.points,
    required this.color,
    this.strokeWidth = 3,
  });

  Map<String, dynamic> toJson() => {
        'type': 'draw',
        'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
      };

  factory AnnotationStroke.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List? ?? [];
    return AnnotationStroke(
      points: rawPoints
          .map((p) => Offset(
                (p['dx'] as num).toDouble(),
                (p['dy'] as num).toDouble(),
              ))
          .toList(),
      color: Color(json['color'] as int? ?? 0xFF000000),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3,
    );
  }
}

class AnnotationShape {
  final AnnotationType type;
  final Rect rect;
  final Color color;
  final double strokeWidth;

  const AnnotationShape({
    required this.type,
    required this.rect,
    required this.color,
    this.strokeWidth = 3,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'left': rect.left,
        'top': rect.top,
        'right': rect.right,
        'bottom': rect.bottom,
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
      };

  factory AnnotationShape.fromJson(Map<String, dynamic> json) {
    return AnnotationShape(
      type: AnnotationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AnnotationType.rectangle,
      ),
      rect: Rect.fromLTRB(
        (json['left'] as num).toDouble(),
        (json['top'] as num).toDouble(),
        (json['right'] as num).toDouble(),
        (json['bottom'] as num).toDouble(),
      ),
      color: Color(json['color'] as int? ?? 0xFF000000),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3,
    );
  }
}

class AnnotationTextStamp {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;

  const AnnotationTextStamp({
    required this.text,
    required this.position,
    required this.color,
    this.fontSize = 24,
  });

  Map<String, dynamic> toJson() => {
        'type': 'text',
        'text': text,
        'dx': position.dx,
        'dy': position.dy,
        'color': color.toARGB32(),
        'fontSize': fontSize,
      };

  factory AnnotationTextStamp.fromJson(Map<String, dynamic> json) {
    return AnnotationTextStamp(
      text: json['text'] as String? ?? '',
      position: Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      ),
      color: Color(json['color'] as int? ?? 0xFF000000),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24,
    );
  }
}
