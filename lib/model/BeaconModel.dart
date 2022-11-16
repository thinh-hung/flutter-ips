import 'package:flutter/material.dart';

class Beacon {
  int id;
  int map_id;
  String mac_address;
  int rssi_at_1m;
  final double radius = 25.0;
  int x;
  int y;

  Beacon({
    required this.id,
    required this.map_id,
    required this.mac_address,
    required this.rssi_at_1m,
    required this.x,
    required this.y,
  });

  int getid() {
    return this.id;
  }

  @override
  Rect getExtent() =>
      Rect.fromLTWH(x - radius, y - radius, radius * 2, radius * 2);
  factory Beacon.fromJson(Map<String, dynamic> data) {
    return Beacon(
      id: data['beacon_id'],
      mac_address: data['mac_address'],
      rssi_at_1m: data['rssi_at_1m'],
      map_id: data['map_id'],
      x: data['x'],
      y: data['y'],
    );
  }
}
