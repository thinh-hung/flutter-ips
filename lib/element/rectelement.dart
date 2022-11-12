// import 'package:flutter/material.dart';
// import 'baseelement.dart';
// import '../function/utils.dart';
//
// class RectElement implements BaseElement {
//   final Color? fill;
//   final Color? stroke;
//   final int? idLocation;
//   final String? roomName;
//   final double x;
//   final double y;
//   final double width;
//   final double height;
//
//   RectElement({
//     this.idLocation,
//     this.roomName,
//     this.fill,
//     this.stroke,
//     required this.x,
//     required this.y,
//     required this.width,
//     required this.height,
//   });
//
//   @override
//   Rect getExtent() => Rect.fromLTWH(x, y, width, height);
//
//   factory RectElement.fromJson(Map<String, dynamic> data) {
//     return RectElement(
//       fill: parseColor(data['fill']),
//       stroke: parseColor(data['stroke']),
//       idLocation: data['idLocation'],
//       x: parseNumber(data['x']),
//       y: parseNumber(data['y']),
//       width: parseNumber(data['w']),
//       height: parseNumber(data['h']),
//       roomName: data['room_name'],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../function/utils.dart';
import 'baseelement.dart';

class RectElement implements BaseElement {
  Color? baseFill;
  Color? fill;

  Color? baseFrame;
  Color? frame;

  final Color? stroke;
  final int? idLocation;
  final String? roomName;
  final double x;
  final double y;
  final double width;
  final double height;

  RectElement({
    this.idLocation,
    this.roomName,
    this.baseFill,
    this.fill,

    this.baseFrame,
    this.frame,

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
      baseFill: parseColor(data['fill']),
      fill: parseColor(data['fill']),

      baseFrame: parseColor(data['frame']),
      frame: parseColor(data['frame']),

      stroke: parseColor(data['stroke']),
      idLocation: data['idLocation'],
      x: parseNumber(data['x']),
      y: parseNumber(data['y']),
      width: parseNumber(data['w']),
      height: parseNumber(data['h']),
      roomName: data['roomName'],
    );
  }
}