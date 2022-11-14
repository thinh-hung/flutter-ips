import 'package:get/get.dart';

class Location {
  int id;
  int map_id;
  int x;
  int y;

  Location({
    required this.id,
    required this.map_id,
    required this.x,
    required this.y,
  });

  int getid() {
    return this.id;
  }

  factory Location.fromJson(Map<String, dynamic> data) {
    return Location(
      id: data['location_id'],
      map_id: data['map_id'],
      x: data['x'],
      y: data['y'],
    );
  }
}
