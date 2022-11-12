import 'package:floorplans/anchor.dart';
import 'package:get/get.dart';

import 'element/beaconelement.dart';

class BLEResult extends GetxController {
  // Raw BLE Scan Result
  Map<String, double> sortedEntriesMap = {};

  List<double> rssiList = [];
  List<String> macAddressList = [];

  // selected beacon param for distance
  List<double> selectedCenterXList = [];
  List<double> selectedCenterYList = [];

  // max distance
  double maxDistance = 8.0;

  // distance value
  List<double> distanceList = [];
  List<BeaconElement> beaconsDB = [];

  // anchor
  List<Anchor> anchorList = [];

  void clearEntries() {
    rssiList.clear();
    macAddressList.clear();
    selectedCenterXList.clear();
    selectedCenterYList.clear();
    update();
  }

  void setXYFromSortedEntries() async {
    clearEntries();
    sortedEntriesMap.forEach((key, value) {
      rssiList.add(value);
      macAddressList.add(key);
      selectedCenterXList.add(getXFromMac(beaconsDB, key));
      selectedCenterYList.add(getYFromMac(beaconsDB, key));
    });
  }

  num getRssiAt1mFromMac(List<BeaconElement> beaconsDB, String key) {
    for (BeaconElement b in beaconsDB) {
      if (b.macAddress == key) {
        return b.rssiAt1m;
      }
    }
    return 0;
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
