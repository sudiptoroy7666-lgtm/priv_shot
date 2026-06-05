import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/core/theme.dart';

class RedactCanvas extends StatefulWidget {
  final ui.Image image;
  final List<RedactBox> boxes;
  final ValueChanged<Rect>? onBoxDrawn;
  final ValueChanged<RedactBox>? onBoxDismissed;

  const RedactCanvas({
    super.key,
    required this.image,
    required this.boxes,
    this.onBoxDrawn,
    this.onBoxDismissed,
  });

  @override
  State<RedactCanvas> createState() => _RedactCanvasState();
}

class _RedactCanvasState extends State<RedactCanvas> {
  Rect? _currentDrawingBox;
  Offset? _drawStart;
  bool _isDrawMode = true; // Default to draw mode
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Offset _toImageCoords(Offset local, Size canvasSize) {
    final imgW = widget.image.width.toDouble();
    final imgH = widget.image.height.toDouble();
    final scale = min(canvasSize.width / imgW, canvasSize.height / imgH);
    final dx = (canvasSize.width - imgW * scale) / 2;
    final dy = (canvasSize.height - imgH * scale) / 2;

    return Offset(
      (local.dx - dx) / scale,
      (local.dy - dy) / scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = constraints.biggest;
        final imgW = widget.image.width.toDouble();
        final imgH = widget.image.height.toDouble();
        final scale = min(canvasSize.width / imgW, canvasSize.height / imgH);
        final dx = (canvasSize.width - imgW * scale) / 2;
        final dy = (canvasSize.height - imgH * scale) / 2;

        Rect toWidgetRect(Rect r) {
          return Rect.fromLTWH(
            dx + r.left * scale,
            dy + r.top * scale,
            r.width * scale,
            r.height * scale,
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isDrawMode ? AppTheme.primary.withOpacity(0.5) : Colors.white.withOpacity(0.1), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. Image & Boxes Layer (Zoomable)
              InteractiveViewer(
                transformationController: _transformController,
                panEnabled: !_isDrawMode,
                scaleEnabled: !_isDrawMode,
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(
                  child: CustomPaint(
                    size: canvasSize,
                    painter: _ImageAndBoxesPainter(
                      image: widget.image,
                      boxes: widget.boxes,
                      currentDrawingBox: _currentDrawingBox,
                    ),
                  ),
                ),
              ),

              // 2. Drawing Layer (Active only in Draw Mode)
              if (_isDrawMode)
                GestureDetector(
                  onPanStart: (details) {
                    _drawStart = _toImageCoords(details.localPosition, canvasSize);
                  },
                  onPanUpdate: (details) {
                    if (_drawStart != null) {
                      setState(() {
                        final current = _toImageCoords(details.localPosition, canvasSize);
                        _currentDrawingBox = Rect.fromPoints(_drawStart!, current);
                      });
                    }
                  },
                  onPanEnd: (details) {
                    if (_currentDrawingBox != null &&
                        _currentDrawingBox!.width > 10 &&
                        _currentDrawingBox!.height > 10) {
                      widget.onBoxDrawn?.call(_currentDrawingBox!);
                    }
                    setState(() {
                      _currentDrawingBox = null;
                      _drawStart = null;
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),

              // 3. Dismiss Buttons (Always on top)
              ...widget.boxes.where((b) => b.isAutoDetected && b.shouldRedact).map((box) {
                final wRect = toWidgetRect(box.rect);
                return Positioned(
                  left: wRect.right - 16,
                  top: wRect.top - 16,
                  child: GestureDetector(
                    onTap: () => widget.onBoxDismissed?.call(box),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                );
              }).toList(),

              // 4. Mode Toggle Button
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() {
                        _isDrawMode = !_isDrawMode;
                        if (_isDrawMode) {
                          _transformController.value = Matrix4.identity(); // Reset zoom when drawing
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDrawMode ? Icons.draw : Icons.pan_tool_outlined,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDrawMode ? 'Draw Mode' : 'Zoom/Pan',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageAndBoxesPainter extends CustomPainter {
  final ui.Image image;
  final List<RedactBox> boxes;
  final Rect? currentDrawingBox;

  _ImageAndBoxesPainter({
    required this.image,
    required this.boxes,
    required this.currentDrawingBox,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    final scale = min(size.width / imgW, size.height / imgH);
    final dx = (size.width - imgW * scale) / 2;
    final dy = (size.height - imgH * scale) / 2;

    final src = Rect.fromLTWH(0, 0, imgW, imgH);
    final dst = Rect.fromLTWH(dx, dy, imgW * scale, imgH * scale);
    canvas.drawImageRect(image, src, dst, Paint());

    Rect toWidgetRect(Rect r) {
      return Rect.fromLTWH(dx + r.left * scale, dy + r.top * scale, r.width * scale, r.height * scale);
    }

    for (final box in boxes) {
      final widgetRect = toWidgetRect(box.rect);
      if (box.shouldRedact) {
        canvas.drawRect(widgetRect, Paint()..color = box.isAutoDetected ? AppTheme.accent.withOpacity(0.4) : AppTheme.primary.withOpacity(0.4));
        canvas.drawRect(widgetRect, Paint()..color = box.isAutoDetected ? AppTheme.accent : AppTheme.primary..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }

    if (currentDrawingBox != null) {
      final widgetRect = toWidgetRect(currentDrawingBox!);
      canvas.drawRect(widgetRect, Paint()..color = AppTheme.primary.withOpacity(0.3));
      canvas.drawRect(widgetRect, Paint()..color = AppTheme.primary..style = PaintingStyle.stroke..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(_ImageAndBoxesPainter oldDelegate) => true;
}