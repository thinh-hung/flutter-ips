import 'package:floorplans/beaconelement.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class BLEResult extends GetxController {
  // Raw BLE Scan Result
  List<ScanResult> scanResultList = [];

  // BLE advertising pacekt format
  List<String> deviceNameList = [];
  List<String> macAddressList = [];
  List<String> rssiList = [];

  List<String> txPowerLevelList = [];
  List<String> manuFacturerDataList = [];
  List<String> serviceUuidsList = [];

  // BTN flag
  List<bool> flagList = [];

  // selected beacon param for distance
  List<int> selectedDeviceIdxList = [];
  List<String> selectedDeviceNameList = [];
  List<num> selectedConstNList = [];
  List<int> selectedRSSI_1mList = [];
  List<double> selectedCenterXList = [];
  List<double> selectedCenterYList = [];
  List<num> selectedDistanceList = [];

  // max distance
  double maxDistance = 8.0;

  // distance value
  List<double> distanceList = [];
  List<BeaconElement> beaconsDB = [];
  void parseBeaconFromResult(List<ScanResult> scanResultList,
      Future<List<BeaconElement>> beacons) async {
    beaconsDB = await beacons;
    for (ScanResult r in scanResultList) {
      for (int i = 0; i < beaconsDB.length; i++) {
        if (r.device.id.id == beaconsDB[i].macAddress) {
          print(r.rssi.toString());
          rssiList.add(r.rssi.toString());
          print(beaconsDB[i].x.toString() + ":" + beaconsDB[i].y.toString());
          selectedCenterXList.add(beaconsDB[i].x);
          selectedCenterYList.add(beaconsDB[i].y);
          selectedDistanceList.add(0.0);
        }
      }
    }
  }

  void initBLEList() {
    scanResultList = [];

    deviceNameList = [];
    macAddressList = [];
    rssiList = [];
    txPowerLevelList = [];
    manuFacturerDataList = [];
    serviceUuidsList = [];
    flagList = [];
    selectedDeviceIdxList = [];
    selectedDeviceNameList = [];
    selectedConstNList = [];
    selectedRSSI_1mList = [];
    selectedCenterXList = [];
    selectedCenterYList = [];
    selectedDistanceList = [];
  }

  void updateBLEList(
      {required String deviceName,
      required String macAddress,
      required String rssi,
      required String serviceUUID,
      required String manuFactureData,
      required String tp}) {
    if (macAddressList.contains(macAddress)) {
      rssiList[macAddressList.indexOf(macAddress)] = rssi;
    } else {
      deviceNameList.add(deviceName);
      macAddressList.add(macAddress);
      rssiList.add(rssi);
      serviceUuidsList.add(serviceUUID);
      manuFacturerDataList.add(manuFactureData);
      txPowerLevelList.add(tp);
      flagList.add(false);
    }
    update();
  }

  void updateFlagList({required bool flag, required int index}) {
    flagList[index] = flag;
    update();
  }

  void updateselectedDeviceIdxList() {
    flagList.forEachIndexed((index, element) {
      if (element == true) {
        if (!selectedDeviceIdxList.contains(index)) {
          selectedDeviceIdxList.add(index);
          selectedDeviceNameList.add(deviceNameList[index]);
          selectedConstNList.add(2.0);
          selectedRSSI_1mList.add(-60);
          selectedCenterXList.add(2.0);
          selectedCenterYList.add(2.0);
          selectedDistanceList.add(0.0);
        }
      } else {
        int idx = selectedDeviceIdxList.indexOf(index);
        if (idx != -1) {
          selectedDeviceIdxList.remove(index);
          selectedDeviceNameList.removeAt(idx);
          selectedConstNList.removeAt(idx);
          selectedRSSI_1mList.removeAt(idx);
          selectedCenterXList.removeAt(idx);
          selectedCenterYList.removeAt(idx);
          selectedDistanceList.removeAt(idx);
        }
      }
    });
    update();
  }
}