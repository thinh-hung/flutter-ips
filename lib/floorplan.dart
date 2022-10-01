import 'dart:convert';
import 'dart:math';
import 'package:floorplans/gird/circle_painter.dart';
import 'package:floorplans/gird/gird_painter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'baseelement.dart';
import 'beaconelement.dart';
import 'layerelement.dart';
import 'rectelement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'deskelement.dart';
import 'rootelement.dart';
import 'elementwithchildren.dart';

class Floorplan extends StatefulWidget {
  final String jsonFloorplan;
  const Floorplan({required this.jsonFloorplan, Key? key}) : super(key: key);

  @override
  State<Floorplan> createState() => _FloorplanState();
}

class _FloorplanState extends State<Floorplan> {
  late RootElement root;
  late TransformationController controller;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  List<BeaconElement> beacons = [];
  List<ScanResult> scanResults = [];
  List<String> macAddressList = [];
  List<double> selectedCenterXList = [];
  List<double> selectedCenterYList = [];
  List<String> rssiList = [];
  List<num> radiusList = [];

  void load(String jsonString) {
    final data = json.decode(jsonString);
    root = RootElement.fromJson(data);
  }

  @override
  void initState() {
    debugPrint(widget.jsonFloorplan);
    load(widget.jsonFloorplan);
    _readJsonBeacon();
    controller = TransformationController();

    super.initState();
    flutterBlue.startScan(scanMode: ScanMode(1), allowDuplicates: true);
    scan();
  }

  Widget buildRectElement(BuildContext context, RectElement element) {
    return Positioned(
      top: element.y,
      left: element.x,
      child: Container(
        height: element.height,
        width: element.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: element.fill as Color,
            width: 2,
          ),
        ),
        child: Center(child: Text("${element.roomName}")),
        // color: element.fill,
      ),
    );
  }

  Widget buildDeskElement(BuildContext context, DeskElement element) {
    return Positioned(
      top: element.y - element.radius,
      left: element.x - element.radius,
      child: Container(
        height: element.radius * 2,
        width: element.radius * 2,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget buildBeaconElement(BuildContext context, BeaconElement element) {
    return Positioned(
      top: element.y - element.radius,
      left: element.x - element.radius,
      child: Container(
        height: element.radius * 2,
        width: element.radius * 2,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 72, 171, 228),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget buildElement(BuildContext context, BaseElement element) {
    switch (element.runtimeType) {
      case DeskElement:
        return buildDeskElement(context, element as DeskElement);

      case RectElement:
        return buildRectElement(context, element as RectElement);

      case BeaconElement:
        return buildBeaconElement(context, element as BeaconElement);

      default:
        throw Exception('Invalid element type: ${element.runtimeType}');
    }
  }

  Widget buildLayer(BuildContext context, LayerElement layer, Rect size) {
    final elements = layer.children
        .map<Widget>((child) => buildElement(context, child))
        .toList();

    return SizedBox(
      height: size.bottom,
      width: size.right,
      child: Stack(
        children: elements,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = root.getExtent();
    final layers = root.layers
        .map<Widget>((layer) => buildLayer(context, layer, size))
        .toList();
    return InteractiveViewer(
        transformationController: controller,
        maxScale: 300,
        constrained: false,
        child: GestureDetector(
          onTapDown: (details) {
            print("beacon in local database: " + beacons.length.toString());
            print("beacon in enviroment: " + scanResults.length.toString());
            for (ScanResult r in scanResults) {
              for (int i = 0; i < beacons.length; i++) {
                if (r.device.id.id == beacons[i].macAddress) {
                  print(r.rssi.toString());
                  rssiList.add(r.rssi.toString());
                  print(
                      beacons[i].x.toString() + ":" + beacons[i].y.toString());
                  selectedCenterXList.add(beacons[i].x);
                  selectedCenterYList.add(beacons[i].y);
                  radiusList.add(0.0);
                  setState(() {});
                }
              }
            }
            // print("x: " + details.localPosition.dx.toString());

            // print("y: " + details.localPosition.dy.toString());
          },
          child: CustomPaint(
            foregroundPainter: CirclePainter(
                selectedCenterXList, selectedCenterYList, radiusList),
            painter: GridPainter(),
            child: Stack(
              children: layers,
            ),
          ),
        ));
  }

  void scan() async {
    flutterBlue.scanResults.listen((results) {
      this.scanResults = results;
    });
  }

  Future<void> _readJsonBeacon() async {
    final String response = await rootBundle.loadString('assets/beacon.json');
    final Map<String, dynamic> database = await json.decode(response);
    List<dynamic> data = database["children"][0]["children"];
    for (dynamic it in data) {
      final BeaconElement b = BeaconElement.fromJson(it); // Parse data
      beacons.add(b); // and organization to List
    }
  }
}
