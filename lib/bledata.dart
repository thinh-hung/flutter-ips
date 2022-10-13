import 'package:floorplans/beaconelement.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class BLEResult extends GetxController {
  // Raw BLE Scan Result
  Map<String, double> sortedEntriesMap = {};

  List<double> rssiList = [];

  // selected beacon param for distance
  List<double> selectedCenterXList = [];
  List<double> selectedCenterYList = [];

  // max distance
  double maxDistance = 8.0;

  // distance value
  List<double> distanceList = [];
  List<BeaconElement> beaconsDB = [];
  void clearEntries() {
    rssiList.clear();
    selectedCenterXList.clear();
    selectedCenterYList.clear();
    update();
  }

  void setXYFromSortedEntries() async {
    clearEntries();
    sortedEntriesMap.forEach((key, value) {
      rssiList.add(value);
      selectedCenterXList.add(getXFromMac(beaconsDB, key));
      selectedCenterYList.add(getYFromMac(beaconsDB, key));
    });
  }

  double getYFromMac(List<BeaconElement> beaconsDB, String key) {
    for (BeaconElement b in beaconsDB) {
      if (b.macAddress == key) {
        return b.y;
      }
    }
    return 0;
  }

  double getXFromMac(List<BeaconElement> beaconsDB, String key) {
    for (BeaconElement b in beaconsDB) {
      if (b.macAddress == key) {
        return b.x;
      }
    }
    return 0;
  }
}
