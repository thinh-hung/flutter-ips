/// RoomModel.dart
import 'dart:convert';

Room roomFromJson(String str) {
  final jsonData = json.decode(str);
  return Room.fromMap(jsonData);
}

String roomToJson(Room data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Room {
  int? id;
  String roomName;
  int x;
  int y;
  double w;
  double h;

  Room({
    this.id,
    required this.roomName,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory Room.fromMap(Map<String, dynamic> json) => new Room(
        id: json["room_id"],
        roomName: json["room_name"],
        x: json["x"],
        y: json["y"],
        w: json["w"],
        h: json["h"],
      );

  Map<String, dynamic> toMap() => {
        "room_id": id,
        "room_name": roomName,
        "x": x,
        "y": y,
        "w": w,
        "h": h,
      };
}
