import 'package:floorplans/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:rolling_switch/rolling_switch.dart';

import 'bledata.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({Key? key}) : super(key: key);

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  var bleController = Get.put(BLEResult());

  // BLE value
  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';

  @override
  void initState() {
    super.initState();
    const oneSecond = Duration(seconds: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child:
          /* listview */
          ListView.separated(
              itemCount: bleController.scanResultList.length,
              itemBuilder: (context, index) =>
                  widgetBLEList(index, bleController.scanResultList[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider()),
    ));
  }

  widgetBLEList(int index, ScanResult r) {
    toStringBLE(r);
    print(r);
    bleController.updateBLEList(
        deviceName: deviceName,
        macAddress: macAddress,
        rssi: rssi,
        serviceUUID: serviceUUID,
        manuFactureData: manuFactureData,
        tp: tp);
    serviceUUID.isEmpty ? serviceUUID = 'null' : serviceUUID;
    manuFactureData.isEmpty ? manuFactureData = 'null' : manuFactureData;
    bool switchFlag = bleController.flagList[index];
    switchFlag ? deviceName = '$deviceName (active)' : deviceName;

    bleController.updateselectedDeviceIdxList();
    return ExpansionTile(
      leading: leading(r),
      title: Text(deviceName,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      subtitle: Text(macAddress,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      trailing: Text(rssi,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      children: <Widget>[
        ListTile(
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'UUID : $serviceUUID\nManufacture data : $manuFactureData\nTX power : ${tp == 'null' ? tp : '${tp}dBm'}',
                  style: const TextStyle(fontSize: 10),
                ),
                const Padding(padding: EdgeInsets.all(2)),
                Row(
                  children: [
                    const Spacer(),
                    RollingSwitch.icon(
                      initialState: bleController.flagList[index],
                      onChanged: (bool state) {
                        bleController.updateFlagList(flag: state, index: index);
                        print(index);
                      },
                      rollingInfoRight: const RollingIconInfo(
                        icon: Icons.flag,
                        text: Text(
                          'Active',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      rollingInfoLeft: const RollingIconInfo(
                        icon: Icons.check,
                        backgroundColor: Colors.grey,
                        text: Text('Inactive'),
                      ),
                    )
                  ],
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
