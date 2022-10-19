import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:floorplans/floorplan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

import 'beaconelement.dart';
import 'bledata.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String?> _future;

  @override
  void initState() {
    _future = rootBundle.loadString('assets/floorplan.json');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floorplans Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage(json: snapshot.data!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String json;

  const MyHomePage({required this.json, Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var bleController = Get.put(BLEResult());
  HashMap<String, List<double>> dictMacRSSI = HashMap<String, List<double>>();
  HashMap<String, double> averageRSSIByMac = HashMap<String, double>();
  List<BeaconElement> beaconsDB = [];
  Map<String, ScanResult> resultList = HashMap<String, ScanResult>();
  Map<String, double> sortedEntriesMap = HashMap<String, double>();
  void setStream(Stream<ScanResult> stream) async {
    stream.listen((r) {
      resultList[r.timeStamp.millisecond.toString()] = r;
      // print('${r.device.name} found! rssi: ${r.rssi}');
    }, onDone: () async {
      // Scan is finished ****************
      await FlutterBluePlus.instance.stopScan();
      print(resultList.length);
      resultList.forEach((key, r) {
        List<double> rssiEachItem = [];
        rssiEachItem.add(r.rssi.toDouble());
        if (dictMacRSSI.containsKey(r.device.id.id)) {
          dictMacRSSI[r.device.id.id]!.addAll(rssiEachItem);
        } else {
          dictMacRSSI[r.device.id.id] = rssiEachItem;
        }
      });
      resultList.clear();
      print("Task Done");

      // print("dictNacRSSi filtered beacon");

      // print(dictMacRSSI);
      // mean
      dictMacRSSI.forEach((key, value) {
        print("$key : $value");
        if (!value.isEmpty) {
          var aver =
              value.reduce((value, element) => value + element) / value.length;

          var dolechchuan = calculateSD(value);
          value.removeWhere((rssi) => rssi > (aver + (1.2 * dolechchuan)));

          var aver2 =
              value.reduce((value, element) => value + element) / value.length;
          // print('average of $key is ${aver2}');

          if (averageRSSIByMac.containsKey(key)) {
            averageRSSIByMac.update(key, (value) => aver2);
          } else {
            averageRSSIByMac[key] = aver2;
          }
        }
        // print('average of $key is ${aver}');
      });
      // standard deviation

      var sortedEntries = averageRSSIByMac.entries.toList()
        ..sort((e2, e1) {
          var diff = e1.value.compareTo(e2.value);
          return diff;
        });
      sortedEntriesMap = Map<String, double>.fromEntries(sortedEntries);

      // print("after sort");
      // print(sortedEntriesMap);

      bleController.sortedEntriesMap =
          sortedEntriesMap; // gan map vao bleresult

      bleController.setXYFromSortedEntries();
      // print(te);

      // reset
      dictMacRSSI.clear();
      print("second scan");
      setState(() {});
      setStream(getScanStream()); // New scan
    }, onError: (Object e) {
      print("Some Error " + e.toString());
    });
  }

  Stream<ScanResult> getScanStream() {
    return FlutterBluePlus.instance.scan(
        timeout: const Duration(seconds: 10),
        allowDuplicates: true,
        scanMode: const ScanMode(2));
  }

  Future<List<BeaconElement>> getJsonBeacon() async {
    List<BeaconElement> beacons = [];
    final String response =
        await rootBundle.loadString('assets/beaconnhatren.json');
    final Map<String, dynamic> database = await json.decode(response);
    List<dynamic> data = database["children"][0]["children"];
    for (dynamic it in data) {
      final BeaconElement b = BeaconElement.fromJson(it); // Parse data
      beacons.add(b); // and organization to List
    }
    return beacons;
  }

  void fromFutureToListBeacon(Future<List<BeaconElement>> beacons) async {
    beaconsDB = await beacons;
    bleController.beaconsDB = beaconsDB;
  }

  @override
  void initState() {
    // TODO: implement initState
    fromFutureToListBeacon(getJsonBeacon());
    setStream(getScanStream());
    Wakelock.enable();
    super.initState();
  }

  var _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Floorplan(jsonFloorplan: widget.json),
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ban Do Tang tren Khoa"),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            Expanded(
              child: _widgetOptions[_selectedIndex],
            ),
          ],
        ));
  }

  double calculateSD(List<double> numArray) {
    double sum = 0.0, standardDeviation = 0.0;
    int length = numArray.length;

    for (double num in numArray) {
      sum += num;
    }

    double mean = sum / length;

    for (double num in numArray) {
      standardDeviation += pow(num - mean, 2);
    }

    return sqrt(standardDeviation / length);
  }
}
