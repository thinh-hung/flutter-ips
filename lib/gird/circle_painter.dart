import 'package:flutter/material.dart';

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
  // final bleController = Get.put(BLEResult());

  CirclePainter(this.centerXList, this.centerYList, this.radiusList);

  @override
  void paint(Canvas canvas, Size size) {
    // List<Anchor> anchorList = [];
    // List<double> pointDistance = [];
    if (radiusList.isNotEmpty) {
      for (int i = 0; i < radiusList.length; i++) {
        // radius
        var radius = radiusList[i];
        // anchorList.add(Anchor(
        //     centerX: centerXList[i], centerY: centerYList[i], radius: radius));
        canvas.drawCircle(
            Offset(centerXList[i], centerYList[i]), radius, anchorePaint);
        // centerX, centerY
        canvas.drawCircle(
            Offset(centerXList[i], centerYList[i]), 2, anchorePaint);
        // anchor text paint
        var anchorTextPainter = TextPainter(
          text: TextSpan(
            text: 'Anchor$i\n(${centerXList[i]}, ${centerYList[i]})',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        anchorTextPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        anchorTextPainter.paint(
            canvas, Offset(centerXList[i] - 27, centerYList[i]));
        // radius text paint
        var radiusTextPainter = TextPainter(
          text: TextSpan(
            text: '  ${radius.toStringAsFixed(2)}m',
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
            canvas, Offset(centerXList[i], centerYList[i] - (radius) / 2 - 5));
        // draw a line
        //var p1 = Offset(centerXList[i], centerYList[i]);
        //var p2 = Offset(
        //    centerXList[i], centerYList[i] - radiusList[i]);

        //canvas.drawLine(p1, p2, anchorePaint);
        drawDashedLine(
            canvas, anchorePaint, centerXList[i], centerYList[i], radius);
      }
      // decision max distance
      // if (anchorList.length >= 3) {
      //   for (int i = 0; i < anchorList.length - 1; i++) {
      //     pointDistance.add(sqrt(
      //         pow((anchorList[i + 1].centerX - anchorList[0].centerX), 2) +
      //             pow((anchorList[i + 1].centerY - anchorList[0].centerY), 2)));
      //   }
      //   var maxDistance = pointDistance.reduce(max);
      //   bleController.maxDistance = maxDistance;
      //   print(maxDistance);
      //   //
      //   var position =
      //       trilaterationMethod(anchorList, bleController.maxDistance);

      //   if ((position[0][0] >= 0.0) && (position[1][0] >= 0.0)) {
      //     canvas.drawCircle(Offset(position[0][0], position[1][0]),
      //         3, positionPaint);

      //     var positionTextPainter = TextPainter(
      //       text: TextSpan(
      //         text:
      //             '(${position[0][0].toStringAsFixed(2)}, ${position[1][0].toStringAsFixed(2)})',
      //         style: const TextStyle(
      //           color: Colors.black,
      //           fontSize: 10,
      //         ),
      //       ),
      //       textDirection: TextDirection.ltr,
      //     );
      //     positionTextPainter.layout(
      //       minWidth: 0,
      //       maxWidth: size.width,
      //     );

      //     positionTextPainter.paint(canvas,
      //         Offset(position[0][0] - 25, position[1][0] + 10));
      //   }
      // }
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
