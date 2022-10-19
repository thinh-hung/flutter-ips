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
      distance1 = anchorList.elementAt(0).radius;
      distance2 = anchorList.elementAt(1).radius;
      distance3 = anchorList.elementAt(2).radius;
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
}
