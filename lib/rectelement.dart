import 'package:flutter/material.dart';

import 'baseelement.dart';
import 'utils.dart';

class RectElement implements BaseElement {
  final Color? fill;
  final Color? stroke;
  final String? roomName;
  final double x;
  final double y;
  final double width;
  final double height;

  RectElement({
    this.roomName,
    this.fill,
    this.stroke,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  Rect getExtent() => Rect.fromLTWH(x, y, width, height);

  factory RectElement.fromJson(Map<String, dynamic> data) {
    return RectElement(
      fill: parseColor(data['fill']),
      stroke: parseColor(data['stroke']),
      x: parseNumber(data['x']),
      y: parseNumber(data['y']),
      width: parseNumber(data['w']),
      height: parseNumber(data['h']),
      roomName: data['roomName'],
    );
  }
}
