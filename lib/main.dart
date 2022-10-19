import 'dart:convert';

import 'package:floorplans/floorplan.dart';
import 'package:floorplans/nearbyscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import 'beaconelement.dart';
import 'bledata.dart';
import 'bleselected.dart';

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
  // flutter_blue_plus
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = false;
  int scanMode = 1;
  var _selectedIndex = 0;
  var bleController = Get.put(BLEResult());

  Future<List<BeaconElement>> getJsonBeacon() async {
    List<BeaconElement> beacons = [];
    final String response = await rootBundle.loadString('assets/beacon.json');
    final Map<String, dynamic> database = await json.decode(response);
    List<dynamic> data = database["children"][0]["children"];
    for (dynamic it in data) {
      final BeaconElement b = BeaconElement.fromJson(it); // Parse data
      beacons.add(b); // and organization to List
    }
    return beacons;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void toggleState() {
    isScanning = !isScanning;
    if (isScanning) {
      flutterBlue.startScan(
          scanMode: ScanMode(scanMode), allowDuplicates: true);
      scan();
    } else {
      flutterBlue.stopScan();
      bleController.initBLEList();
    }
    setState(() {});
  }

  /* Scan */
  void scan() async {
    // Listen to scan results
    flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      bleController.scanResultList = results;
      bleController.parseBeaconFromResult(
          results, getJsonBeacon()); // chac ko chay dau
      print(results);
      // update state
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Floorplan(jsonFloorplan: widget.json),
      NearbyScreen(),
      BleSelected(),
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text("Ban Do Tang tren Khoa"),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: Icon(isScanning ? Icons.stop : Icons.search),
              onPressed: () {
                toggleState();
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _widgetOptions[_selectedIndex],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Bản đồ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_searching),
              label: "BeaconList",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_connected),
              label: "BeaconSelected",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ));
  }
}
