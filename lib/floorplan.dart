import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:floorplans/bledata.dart';
import 'package:floorplans/dijkstra.dart';
import 'package:floorplans/gird/circle_painter.dart';
import 'package:floorplans/gird/gird_painter.dart';
import 'package:floorplans/utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'baseelement.dart';
import 'beaconelement.dart';
import 'drawAPath.dart';
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
  late final bleController;
  late RootElement root;
  late AnimationController controller;
  late TransformationController controllerTs;
  var centerXList = [];
  var centerYList = [];
  Dijkstra a = Dijkstra();
  List<DeskElement> listPosition = [];
  List<num> radiusList = [];
  bool openFloor = false;
  void load(String jsonString) {
    final data = json.decode(jsonString);
    root = RootElement.fromJson(data);
  }

  // Future<void> calldijkstra() async {
  //   await
  // }

  @override
  void initState() {
    // debugPrint(widget.jsonFloorplan);
    load(widget.jsonFloorplan);
    super.initState();

    a.dijkstraCaculate();
    listPosition = a.getWayPoint();
    print("len way:" + listPosition.length.toString());

    bleController = Get.put(BLEResult());
    controllerTs = TransformationController();
    //animation duration 1 seconds
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() => setState(() {}))
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
          centerXList = bleController.selectedCenterXList;
          centerYList = bleController.selectedCenterYList;
          // initialize radius list tao r
          radiusList = [];
          for (int i = 0; i < bleController.selectedDistanceList.length; i++) {
            radiusList.add(0.0);
          }
          // rssi to distance
          for (int idx = 0;
              idx < bleController.selectedDistanceList.length;
              idx++) {
            var rssi = bleController
                .scanResultList[bleController.selectedDeviceIdxList[idx]].rssi;
            var alpha = bleController.selectedRSSI_1mList[idx];
            var constantN = bleController.selectedConstNList[idx];
            var distance = logDistancePathLoss(
                rssi.toDouble(), alpha.toDouble(), constantN.toDouble());
            radiusList[idx] = distance;
          }
        }
      });
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
          color: Colors.yellow,
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
    List<int> stairList = [
      2,
      6,
      30,
      31,
    ];
    List<int> endList = [
      35,
      40,
      62,
      70,
    ];
    for (int i = 0; i < listPosition.length; i++) {
      var element = listPosition[i];
      if (element.deskId >= 35 || stairList.contains(listPosition[1].deskId)) {
        setState(() {
          print("######################################");
          openFloor = true;
        });
      } else {
        openFloor = false;
      }
      bool b1 = a.x >= listPosition[listPosition.length - 1].x - 10;
      bool b2 = a.x <= listPosition[listPosition.length - 1].x + 10;
      bool b3 = a.y >= listPosition[listPosition.length - 1].y - 10;
      bool b4 = a.y <= listPosition[listPosition.length - 1].y + 10;
      if (b1 && b2 && b3 && b4) {
        setState(() {
          print("tới r");
          a.stopDijstra();

          controller.stop();
          showDialog();
        });
        break;
      }
    }
    final size = root.getExtent();
    final layers = root.layers
        .map<Widget>((layer) => buildLayer(context, layer, size))
        .toList();
    return InteractiveViewer(
        transformationController: controllerTs,
        maxScale: 300,
        constrained: false,
        child: Stack(
          children: [
            GestureDetector(
              onTapDown: (details) {
                // print("beacon in local database: " + beacons.length.toString());
                // print("beacon in enviroment: " +
                //     bleController.scanResultList.length.toString());

                print("x: " + details.localPosition.dx.toString());

                print("y: " + details.localPosition.dy.toString());
              },
              child: CustomPaint(
                painter: LinePainter(listPosition: listPosition),
                foregroundPainter:
                    CirclePainter(centerXList, centerYList, radiusList),
                child: Stack(
                  children: layers,
                ),
              ),
            ),
            openFloor
                ? ElevatedButton(
                    onPressed: () async {
                      final String response =
                          await rootBundle.loadString('assets/floor2.json');
                      load(response);
                      setState(() {});
                    },
                    child: Text("Lên tầng trên"),
                  )
                : Center(),
          ],
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future showDialog() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: false,
        dialogType: DialogType.success,
        showCloseIcon: true,
        title: 'Hoàn tất chỉ đường',
        desc: 'Bạn đã đến được địa điểm cần tìm',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        },
      ).show();
    });
  }
}
