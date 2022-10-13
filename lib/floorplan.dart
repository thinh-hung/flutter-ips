import 'dart:convert';
import 'package:floorplans/bledata.dart';
import 'package:floorplans/dijkstra.dart';
import 'package:floorplans/gird/circle_painter.dart';
import 'package:floorplans/gird/gird_painter.dart';
import 'package:floorplans/utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'baseelement.dart';
import 'beaconelement.dart';
import 'layerelement.dart';
import 'rectelement.dart';
import 'package:flutter/material.dart';
import 'deskelement.dart';
import 'rootelement.dart';

class Floorplan extends StatefulWidget {
  final String jsonFloorplan;
  const Floorplan({required this.jsonFloorplan, Key? key}) : super(key: key);

  @override
  State<Floorplan> createState() => _FloorplanState();
}

class _FloorplanState extends State<Floorplan>
    with SingleTickerProviderStateMixin {
  late RootElement root;
  late TransformationController controllerTF;
  late AnimationController controller;
  var bleController = Get.put(BLEResult());
  var centerXList = [];
  var centerYList = [];
  List<num> radiusList = [];
  void load(String jsonString) {
    final data = json.decode(jsonString);
    root = RootElement.fromJson(data);
  }

  @override
  void didUpdateWidget(covariant Floorplan oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print(
        "musst run every 10s...........................................................");

    centerXList = bleController.selectedCenterXList;
    centerYList = bleController.selectedCenterYList;
    print(centerXList);
    print(centerYList);

    // rssi to distance

    for (int idx = 0; idx < bleController.sortedEntriesMap.length; idx++) {
      var rssi = bleController.rssiList[idx];
      var alpha = -75;
      var constantN = 2;
      var distance = logDistancePathLoss(
          rssi.toDouble(), alpha.toDouble(), constantN.toDouble());
      radiusList.add(distance);
    }
    print(radiusList);
    // setState(() {});
  }

  @override
  void initState() {
    controllerTF = TransformationController();
    // debugPrint(widget.jsonFloorplan);
    load(widget.jsonFloorplan);
    super.initState();
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
        transformationController: controllerTF,
        maxScale: 300,
        constrained: false,
        child: GestureDetector(
          onTapDown: (details) {
            // print("beacon in local database: " + beacons.length.toString());
            // print("beacon in enviroment: " +
            //     bleController.scanResultList.length.toString());

            // print("x: " + details.localPosition.dx.toString());

            // print("y: " + details.localPosition.dy.toString());
          },
          child: CustomPaint(
            painter: GridPainter(),
            foregroundPainter:
                CirclePainter(centerXList, centerYList, radiusList),
            child: Stack(
              children: layers,
            ),
          ),
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
