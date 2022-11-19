import 'package:floorplans/model/LocationModel.dart';
import 'package:flutter/material.dart';

import '../element/deskelement.dart';

class LinePainter extends CustomPainter {
  late List<Location> listPosition;
  List<Location> listPosition1 = [];

  LinePainter({required this.listPosition});

  List<Location> getlistPosition1() {
    return this.listPosition1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    final paint1 = Paint()..color = Colors.blue;
    final paint2 = Paint()..color = Colors.red;

    for (int i = 0; i < this.listPosition.length - 1; i++) {
      canvas.drawCircle(
          Offset(listPosition[i].x.toDouble(), listPosition[i].y.toDouble()),
          15,
          paint);
    }
    for (int i = 0; i < this.listPosition.length - 1; i++) {
      if (i == 0) {
        canvas.drawCircle(
            Offset(listPosition[i].x.toDouble(), listPosition[i].y.toDouble()),
            15,
            paint1);
      } //màu nút
      if (i == this.listPosition.length - 2 && this.listPosition[i].id < 35) {
        canvas.drawCircle(
            Offset(listPosition[i + 1].x.toDouble(),
                listPosition[i + 1].y.toDouble()),
            15,
            paint2);
      } //màu nút
      if (this.listPosition[i].id < 35) {
        canvas.drawLine(
            Offset(listPosition[i].x.toDouble(), listPosition[i].y.toDouble()),
            Offset(listPosition[i + 1].x.toDouble(),
                listPosition[i + 1].y.toDouble()),
            paint);
      } else {
        listPosition1.add(this.listPosition[i]);
        if (i == this.listPosition.length - 2) {
          listPosition1.add(this.listPosition[i + 1]);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
