import 'baseelement.dart';
import 'package:flutter/material.dart';
import '../function/utils.dart';

class BeaconElement implements BaseElement {
  final int beaconId;
  final double x;
  final double y;
  final double radius = 5.0;
  final String? macAddress;
  final int rssiAt1m;

  BeaconElement({
    required this.beaconId,
    required this.rssiAt1m,
    required this.x,
    required this.y,
    this.macAddress,
  });

  @override
  Rect getExtent() =>
      Rect.fromLTWH(x - radius, y - radius, radius * 2, radius * 2);

  factory BeaconElement.fromJson(Map<String, dynamic> data) {
    return BeaconElement(
        beaconId: data['beaconId'],
        x: parseNumber(data['x']),
        y: parseNumber(data['y']),
        rssiAt1m: data['rssiAt1m'],
        macAddress: data['macAddress']);
  }
}
