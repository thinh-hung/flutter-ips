import 'package:flutter/material.dart';

import 'deskelement.dart';

class LinePainter extends CustomPainter {
  late List<DeskElement> listPosition;
  List<DeskElement> listPosition1 = [];

  LinePainter({required this.listPosition});

  List<DeskElement> getlistPosition1() {
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
      if (i == 0) {
        canvas.drawCircle(
            Offset(listPosition[i].x, listPosition[i].y), 15, paint1);
      } //màu nút
      if (i == this.listPosition.length - 2 &&
          this.listPosition[i].deskId < 72) {
        canvas.drawCircle(
            Offset(listPosition[i + 1].x, listPosition[i + 1].y), 15, paint2);
      } //màu nút
      // if (this.listPosition[i].deskId < 72) {
      if (this.listPosition[i].x == this.listPosition[0].x &&
          this.listPosition[i].y == this.listPosition[0].y) {
        print("X:" + this.listPosition[0].y.toString());
        canvas.drawLine(Offset(this.listPosition[i].x, this.listPosition[i].y),
            Offset(listPosition[i + 1].x, listPosition[i + 1].y), paint);
      } else {
        canvas.drawLine(Offset(listPosition[i].x, listPosition[i].y),
            Offset(listPosition[i + 1].x, listPosition[i + 1].y), paint);
      }
      // } else {
      //   listPosition1.add(this.listPosition[i]);
      //   if (i == this.listPosition.length - 2) {
      //     listPosition1.add(this.listPosition[i + 1]);
      //   }
      // }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
