import 'baseelement.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class DeskElement implements BaseElement {
  final int deskId;
  final double x;
  final double y;
  final double radius = 5.0;

  DeskElement({
    required this.deskId,
    required this.x,
    required this.y,
  });
  int getID(){
    return this.deskId;
  }
  double getX(){
    return this.x;
  }
  double getY(){
    return this.y;
  }

  @override
  Rect getExtent() =>
      Rect.fromLTWH(x - radius, y - radius, radius * 2, radius * 2);


  factory DeskElement.fromJson(Map<String, dynamic> data) {
    return DeskElement(
      deskId: data['deskId'],
      x: parseNumber(data['x']),
      y: parseNumber(data['y']),
    );
  }
}
