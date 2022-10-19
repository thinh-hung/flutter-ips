import 'dart:math';

import 'package:floorplans/anchor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bledata.dart';
import '../localizations/localizationalgorithms.dart';
import '../trilateration.dart';

class CirclePainter extends CustomPainter {
  var centerXList = [];
  var centerYList = [];
  var radiusList = [];
  var anchorePaint = Paint()
    ..color = Colors.lightBlue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;
  var positionPaint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;
  final bleController = Get.put(BLEResult());

  CirclePainter(this.centerXList, this.centerYList, this.radiusList);
  Localization localization = Localization();

  @override
  void paint(Canvas canvas, Size size) {
    List<Anchor> anchorList = []; // da sap xep theo rssi
    if (radiusList.isNotEmpty) {
      for (int i = 0; i < radiusList.length; i++) {
        var radius = radiusList[i];
        anchorList.add(Anchor(
            centerX: centerXList[i], centerY: centerYList[i], radius: radius));
      }
      anchorList.sort(
        (a, b) => a.radius.compareTo(b.radius),
      );
      for (int i = 0; i < anchorList.length; i++) {
        // danh dau mau tim 3 diem theo rssi gan nhat
        if (i < 3) {
          canvas.drawCircle(
              Offset(anchorList[i].centerX, anchorList[i].centerY),
              anchorList[i].radius * 20,
              Paint()..color = Colors.purple);
        }

        canvas.drawCircle(Offset(anchorList[i].centerX, anchorList[i].centerY),
            anchorList[i].radius * 10, anchorePaint); // m to cm

        canvas.drawCircle(Offset(anchorList[i].centerX, anchorList[i].centerY),
            2, anchorePaint);
        // anchor text paint etc Anchor0 (,,,,,)
        var anchorTextPainter = TextPainter(
          text: TextSpan(
            text: 'Anchor$i\n(${centerXList[i]}, ${centerYList[i]})',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        anchorTextPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        anchorTextPainter.paint(canvas,
            Offset(anchorList[i].centerX - 27, anchorList[i].centerY + 20));
        // radius text paint etc 7.08m
        var radiusTextPainter = TextPainter(
          text: TextSpan(
            text: '  ${radiusList[i].toStringAsFixed(2)}m',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        radiusTextPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        radiusTextPainter.paint(
            canvas,
            Offset(anchorList[i].centerX,
                anchorList[i].centerY - (anchorList[i].radius) / 2 - 5));
        drawDashedLine(canvas, anchorePaint, anchorList[i].centerX,
            anchorList[i].centerY, anchorList[i].radius);
      }
      // decision max distance if more or equal 3 beacon
      localization.addAnchorNode(anchorList);
      if (localization.conditionMet) {
        Offset xyMinMax = localization.minMaxPosition();
        canvas.drawCircle(xyMinMax, 20, Paint()..color = Colors.red);
        print(
            "toa do: " + xyMinMax.dx.toString() + ':' + xyMinMax.dy.toString());
      }
    }
  }

  void drawDashedLine(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    const int dashWidth = 4;
    const int dashSpace = 3;
    double startY = 0;
    while (startY < radius - 2) {
      // Draw a dash line
      canvas.drawLine(Offset(centerX, centerY - startY),
          Offset(centerX, centerY - startY - dashSpace), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return true;
  }
}
