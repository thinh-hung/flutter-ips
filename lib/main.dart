import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:floorplans/Drawer.dart';
import 'package:floorplans/floorplan.dart';
import 'package:floorplans/model/BeaconModel.dart';
import 'package:floorplans/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

import 'SearchRoom.dart';
import 'bledata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const InitApp());
}

class InitApp extends StatelessWidget {
  const InitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreens(),
    );
  }
}

class MyApp extends StatefulWidget {
  int search_location_finish = 0;
  MyApp({Key? key, required this.search_location_finish}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String?> _future;

  @override
  void initState() {
    _future = rootBundle.loadString('assets/testjson.json');

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
            return MyHomePage(
              json: snapshot.data!,
              search_location_finish: widget.search_location_finish,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String json;
  int search_location_finish = 0;

  MyHomePage(
      {required this.json, Key? key, required this.search_location_finish})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // firebase 11/16/2022
  final CollectionReference _referenceBeaconList =
      FirebaseFirestore.instance.collection("Beacon");
  late Future<QuerySnapshot> _futureData;
  List<Beacon> _beaconItems = [];

  var bleController = Get.put(BLEResult());
  HashMap<String, List<double>> dictMacRSSI = HashMap<String, List<double>>();
  HashMap<String, double> averageRSSIByMac = HashMap<String, double>();
  Map<String, ScanResult> resultList = HashMap<String, ScanResult>();
  Map<String, double> sortedEntriesMap = HashMap<String, double>();

  @override
  void initState() {
    // firebase 11/16/2022
    _futureData = _referenceBeaconList.get();
    _futureData.then(
      (value) {
        setState(() {
          _beaconItems = parseData(value);
          bleController.beaconsDB = _beaconItems;
        });
      },
    );

    setStream(getScanStream());
    Wakelock.enable();
    super.initState();
  }

  // firebase 11/16/2022
  List<Beacon> parseData(QuerySnapshot querySnapshot) {
    List<QueryDocumentSnapshot> listDocs = querySnapshot.docs;

    List<Beacon> listItems = listDocs
        .map((e) => Beacon.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return listItems;
  }

  void setStream(Stream<ScanResult> stream) async {
    stream.listen((r) {
      resultList[r.timeStamp.toString()] = r;
      // print('${r.device.name} found! rssi: ${r.rssi}');
    }, onDone: () async {
      // Scan is finished ****************
      await FlutterBluePlus.instance.stopScan();
      print(resultList.length);

      resultList.forEach((key, r) {
        if (getMacAddressBeaconDB().contains(r.device.id.id)) {
          List<double> rssiEachItem = [];
          rssiEachItem.add(r.rssi.toDouble());
          if (dictMacRSSI.containsKey(r.device.id.id)) {
            dictMacRSSI[r.device.id.id]!.addAll(rssiEachItem);
          } else {
            dictMacRSSI[r.device.id.id] = rssiEachItem;
          }
        }
      });
      resultList.clear();
      // Loc ra nhung beacon co trong database
      print("Loc ra nhung beacon co trong database");
      dictMacRSSI.forEach((key, value) {
        print('$key: ${value}');
      });
      // Loai bo do cac gia tri thua bang do lech chuan
      print("Loai bo do cac gia tri thua bang do lech chuan");
      dictMacRSSI.forEach((key, value) {
        // print("$key : $value");
        if (!value.isEmpty) {
          var aver =
              value.reduce((value, element) => value + element) / value.length;

          var dolechchuan = calculateSD(value);
          value.removeWhere((rssi) => rssi > (aver + (1.2 * dolechchuan)));
          print('$key: $value');
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
      // Tinh trung binh va sap xep beacon theo rssi
      print("Tinh trung binh va sap xep beacon theo rssi");

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
    print("scanstream chay....");
    return FlutterBluePlus.instance.scan(
        timeout: const Duration(milliseconds: 3000),
        allowDuplicates: true,
        scanMode: const ScanMode(2));
  }

  List<String> getMacAddressBeaconDB() {
    return _beaconItems.map((e) => e.mac_address).toList();
  }

  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Floorplan(search_location_finish: widget.search_location_finish),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ban Do Tang tren Khoa"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              showSearch(
                context: context,
                // delegate to customize the search bar
                delegate: SearchRoom(),
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      backgroundColor: Colors.brown[100],
      drawer: drawermenu(),
      body: Column(
        children: [
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
        ],
      ),
    );
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
