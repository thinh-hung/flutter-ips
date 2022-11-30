import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/model/LocationModel.dart';
import 'package:floorplans/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../model/RoomModel.dart';

double parseNumber(dynamic number) => (number as num).toDouble();

Color? parseColor(String? color) {
  return color == null ? null : Color(int.parse(color, radix: 16));
}

/* log distance path loss model */
num logDistancePathLoss(double rssi, double alpha, double constantN) {
  return pow(10.0, ((alpha - rssi) / (10 * constantN)));
}

String deviceNameCheck(ScanResult r) {
  String name;

  if (r.device.name.isNotEmpty) {
    // Is device.name
    name = r.device.name;
  } else if (r.advertisementData.localName.isNotEmpty) {
    // Is advertisementData.localName
    name = r.advertisementData.localName;
  } else {
    // null
    name = 'N/A';
  }
  return name;
}

leading(ScanResult r) => const CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
loadTextMap(BuildContext context) => Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 2.5),
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width / 2.9),
            Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Đang tải bản đồ",
                  style: TextStyle(fontSize: 19),
                )
              ],
            ),
          ],
        ),
      ],
    );
Widget logoutButton(BuildContext context) {
  return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text('Đăng xuất thành công')));
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const LoginScreen(),
          ),
          ModalRoute.withName('/'),
        );
      },
      icon: Icon(Icons.door_back_door_rounded));
}

Future<Room> getRoomAreaByLocation_Id(Location location) async {
  var snapshot = (await FirebaseFirestore.instance
      .collection('Room')
      .where('location_id', isEqualTo: location.id)
      .get());
  late final Room room;
  snapshot.docs.forEach((element) {
    var document = element.data();
    room = Room.fromMap(document);
  });

  return room;
}

Future<Location> getLocation(int locationId) async {
  var snapshot = (await FirebaseFirestore.instance
      .collection('Location')
      .where('location_id', isEqualTo: locationId)
      .get());
  late final Location location;

  snapshot.docs.forEach((element) {
    var document = element.data();
    location = Location.fromJson(document);
  });
  return location;
}
