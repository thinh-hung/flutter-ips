import 'package:floorplans/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';

import 'bledata.dart';

class BleSelected extends StatefulWidget {
  const BleSelected({Key? key}) : super(key: key);

  @override
  State<BleSelected> createState() => _BleSelectedState();
}

class _BleSelectedState extends State<BleSelected> {
  // BLE value
  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';
  var bleController = Get.put(BLEResult());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            /* listview */
            ListView.separated(
                itemCount: bleController.selectedDeviceIdxList.length,
                itemBuilder: (context, index) => widgetSelectedBLEList(
                      index,
                      bleController.scanResultList[
                          bleController.selectedDeviceIdxList[index]],
                    ),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider()),
      ),
    );
  }

  widgetSelectedBLEList(int currentIdx, ScanResult r) {
    toStringBLE(r);

    bleController.updateBLEList(
        deviceName: deviceName,
        macAddress: macAddress,
        rssi: rssi,
        serviceUUID: serviceUUID,
        manuFactureData: manuFactureData,
        tp: tp);
    double constantN = bleController.selectedConstNList[currentIdx].toDouble();
    double alpha = bleController.selectedRSSI_1mList[currentIdx].toDouble();
    num distance = logDistancePathLoss(parseNumber(rssi), alpha, constantN);
    bleController.selectedDistanceList[currentIdx] = distance;
    String constN = bleController.selectedConstNList[currentIdx].toString();
    String rssi1m = bleController.selectedRSSI_1mList[currentIdx].toString();
    return ExpansionTile(
      //leading: leading(r),
      title: Text('$deviceName ($macAddress)',
          style: const TextStyle(color: Colors.black)),
      subtitle: Text(
          '\n Alias : Anchor$currentIdx\n N : $constN\n RSSI at 1m : ${rssi1m}dBm',
          style: const TextStyle(color: Colors.blueAccent)),
      trailing: Text('${distance.toStringAsPrecision(3)}m',
          style: const TextStyle(color: Colors.black)),
      children: <Widget>[
        ListTile(
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  min: 2.0,
                  max: 4.0,
                  value:
                      bleController.selectedConstNList[currentIdx].toDouble(),
                  decimals: 1,
                  step: 0.1,
                  onChanged: (value) =>
                      bleController.selectedConstNList[currentIdx] = value,
                  decoration: const InputDecoration(
                      labelText:
                          'N (Constant depends on the Environmental factor)'),
                )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SpinBox(
                min: -100,
                max: -30,
                value: bleController.selectedRSSI_1mList[currentIdx].toDouble(),
                decimals: 0,
                step: 1,
                onChanged: (value) => bleController
                    .selectedRSSI_1mList[currentIdx] = value.toInt(),
                decoration: const InputDecoration(labelText: 'RSSI at 1m'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SpinBox(
                min: 0.0,
                max: 20.0,
                value: bleController.selectedCenterXList[currentIdx].toDouble(),
                decimals: 1,
                step: 0.1,
                onChanged: (value) =>
                    bleController.selectedCenterXList[currentIdx] = value,
                decoration: const InputDecoration(labelText: 'Center X [m]'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SpinBox(
                min: 0.0,
                max: 20.0,
                value: bleController.selectedCenterYList[currentIdx].toDouble(),
                decimals: 1,
                step: 0.1,
                onChanged: (value) =>
                    bleController.selectedCenterYList[currentIdx] = value,
                decoration: const InputDecoration(labelText: 'Center Y [m]'),
              ),
            ),
          ]),
        )
      ],
    );
  }

  void toStringBLE(ScanResult r) {
    deviceName = deviceNameCheck(r);
    macAddress = r.device.id.id;
    rssi = r.rssi.toString();

    serviceUUID = r.advertisementData.serviceUuids
        .toString()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');
    manuFactureData = r.advertisementData.manufacturerData
        .toString()
        .replaceAll('{', '')
        .replaceAll('}', '');
    tp = r.advertisementData.txPowerLevel.toString();
  }
}
