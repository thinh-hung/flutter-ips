import 'package:floorplans/anchor.dart';
import 'package:floorplans/model/BeaconModel.dart';
import 'package:get/get.dart';

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
  List<Beacon> beaconsDB = [];

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

  num getRssiAt1mFromMac(List<Beacon> beaconsDB, String key) {
    for (Beacon b in beaconsDB) {
      if (b.mac_address == key) {
        return b.rssi_at_1m;
      }
    }
    return 0;
  }

  double getYFromMac(List<Beacon> beaconsDB, String key) {
    for (Beacon b in beaconsDB) {
      if (b.mac_address == key) {
        return b.y.toDouble();
      }
    }
    return 0;
  }

  double getXFromMac(List<Beacon> beaconsDB, String key) {
    for (Beacon b in beaconsDB) {
      if (b.mac_address == key) {
        return b.x.toDouble();
      }
    }
    return 0;
  }
}
