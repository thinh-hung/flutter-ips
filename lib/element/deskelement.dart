import 'baseelement.dart';
import 'package:flutter/material.dart';
import '../function/utils.dart';

class DeskElement implements BaseElement {
  final int location_id;
  final int map_id;
  double x;
  double y;
  final double radius = 5.0;

  DeskElement({
    required this.location_id,
    required this.x,
    required this.y,
    required this.map_id,
  });
  int getID() {
    return this.location_id;
  }

  double getX() {
    return this.x;
  }

  double getY() {
    return this.y;
  }

  @override
  Rect getExtent() =>
      Rect.fromLTWH(x - radius, y - radius, radius * 2, radius * 2);

  factory DeskElement.fromJson(Map<String, dynamic> data) {
    return DeskElement(
      location_id: data['location_id'],
      map_id: data['map_id'],
      x: parseNumber(data['x']),
      y: parseNumber(data['y']),
    );
  }
}
