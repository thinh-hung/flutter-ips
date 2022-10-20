import 'dart:math';
import 'dart:ui';

import 'package:floorplans/anchor.dart';
import 'package:ml_linalg/matrix.dart';

class Localization {
  late Anchor anchor1;
  late Anchor anchor2;
  late Anchor anchor3;

  late double distance1;
  late double distance2;
  late double distance3;

  bool conditionMet = false;

  Map<String, Map<Anchor, double>> distanceToAnchors =
      Map<String, Map<Anchor, double>>();

  addAnchorNode(List<Anchor> anchorList) {
    if (anchorList.length >= 3) {
      conditionMet = true;
      anchorList.sort(
        (a, b) => a.radius.compareTo(b.radius),
      );

      anchor1 = anchorList.elementAt(0);
      anchor2 = anchorList.elementAt(1);
      anchor3 = anchorList.elementAt(2);
      print(
          "${anchor1.centerX}:${anchor1.centerY}, ${anchor2.centerX}:${anchor2.centerY}, ${anchor3.centerX}:${anchor3.centerY}");
      distance1 = anchorList.elementAt(0).radius * 100;
      distance2 = anchorList.elementAt(1).radius * 100;
      distance3 = anchorList.elementAt(2).radius * 100;
    } else {
      conditionMet = false;
    }
  }

  Offset minMaxPosition() {
    var xMin = Matrix.row([
      anchor1.centerX - distance1,
      anchor2.centerX - distance2,
      anchor3.centerX - distance3
    ]).max();
    var xMax = Matrix.row([
      anchor1.centerX + distance1,
      anchor2.centerX + distance2,
      anchor3.centerX + distance3
    ]).min();
    var yMin = Matrix.row([
      anchor1.centerY - distance1,
      anchor2.centerY - distance2,
      anchor3.centerY - distance3
    ]).max();
    var yMax = Matrix.row([
      anchor1.centerY + distance1,
      anchor2.centerY + distance2,
      anchor3.centerY + distance3
    ]).min();

    var x = (xMin + xMax) / 2;
    var y = (yMin + yMax) / 2;

    return Offset(x, y);
  }

  Offset trilateration() {
    double a = (-2 * anchor1.centerX) + (2 * anchor2.centerX);
    double b = (-2 * anchor1.centerY) + (2 * anchor2.centerY);
    double c = (pow(distance1, 2) -
            pow(distance2, 2) -
            pow(anchor1.centerX, 2) +
            pow(anchor2.centerX, 2) -
            pow(anchor1.centerY, 2) +
            pow(anchor2.centerY, 2))
        .toDouble();

    double d = (-2 * anchor2.centerX) + (2 * anchor3.centerX);
    double e = (-2 * anchor2.centerY) + (2 * anchor3.centerY);
    double f = (pow(distance2, 2) -
            pow(distance3, 2) -
            pow(anchor2.centerX, 2) +
            pow(anchor3.centerX, 2) -
            pow(anchor2.centerY, 2) +
            pow(anchor3.centerY, 2))
        .toDouble();
    double x = (c * e - f * b);
    x = x / (e * a - b * d);

    double y = (c * d - a * f);
    y = y / (b * d - a * e);
    return Offset(x, y);
  }
}
