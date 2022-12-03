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
import 'package:just_audio_background/just_audio_background.dart';
import 'package:wakelock/wakelock.dart';

import 'SearchRoom.dart';
import 'bledata.dart';
import 'draweruser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await Firebase.initializeApp();
  runApp(const InitApp());
}

class InitApp extends StatelessWidget {
  const InitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Floorplans Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(
          search_location_finish: widget.search_location_finish,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  int search_location_finish = 0;

  MyHomePage({Key? key, required this.search_location_finish})
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
  int _mapIds = 1;
  var bleController = Get.put(BLEResult());
  HashMap<String, List<double>> dictMacRSSI = HashMap<String, List<double>>();
  HashMap<String, double> averageRSSIByMac = HashMap<String, double>();
  Map<String, ScanResult> resultList = HashMap<String, ScanResult>();
  Map<String, double> sortedEntriesMap = HashMap<String, double>();

  @override
  void initState() {
    // firebase 11/16/2022
    _futureData = _referenceBeaconList.where('isActive', isEqualTo: true).get();
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
      if (resultList.length != 0) {
        _mapIds = 1;
      }
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
      if (sortedEntries.isNotEmpty) {
        _mapIds = getMapIdByMacAddress(sortedEntries.first.key);

        print('${sortedEntries.first.key} : mapid= $_mapIds');
      }
      // Tinh trung binh va sap xep beacon theo rssi
      print("Tinh trung binh va sap xep beacon theo rssi");

      bleController.sortedEntriesMap =
          sortedEntriesMap; // gan map vao bleresult

      bleController.setXYFromSortedEntries();
      // print(te);

      // reset
      dictMacRSSI.clear();
      setState(() {});
      setStream(getScanStream()); // New scan
    }, onError: (Object e) {
      print("Some Error " + e.toString());
    });
  }

  Stream<ScanResult> getScanStream() {
    return FlutterBluePlus.instance.scan(
        timeout: const Duration(seconds: 6),
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
      Floorplan(
        search_location_finish: widget.search_location_finish,
        map_id: _mapIds,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Bản đồ tầng  ${_mapIds == 1 ? "trệt" : _mapIds - 1}"),
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
      drawer: draweruser(),
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

  int getMapIdByMacAddress(String value) {
    int mapId = 1;
    for (var element in _beaconItems) {
      if (element.mac_address == value) mapId = element.map_id;
    }
    return mapId;
  }
}
