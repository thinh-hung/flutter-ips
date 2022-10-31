import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:floorplans/bledata.dart';
import 'package:floorplans/dijkstra.dart';
import 'package:floorplans/drawAPath.dart';
import 'package:floorplans/gird/circle_painter.dart';
import 'package:floorplans/gird/gird_painter.dart';
import 'package:floorplans/utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'baseelement.dart';
import 'beaconelement.dart';
import 'layerelement.dart';
import 'localizations/localizationalgorithms.dart';
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
  Dijkstra a = Dijkstra();
  bool openFloor = false;
  bool closeFloor = false;

  List<DeskElement> listPosition = [];
  Localization localization = Localization();

  List<num> radiusList = [];
  void load(String jsonString) {
    final data = json.decode(jsonString);
    root = RootElement.fromJson(data);
  }

  @override
  void didUpdateWidget(covariant Floorplan oldWidget) {
    print("...................................");
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    centerXList = bleController.selectedCenterXList;
    centerYList = bleController.selectedCenterYList;
    radiusList.clear();

    // rssi to distance

    for (int idx = 0; idx < bleController.sortedEntriesMap.length; idx++) {
      var rssi = bleController.rssiList[idx];
      var alpha = bleController.getRssiAt1mFromMac(
          bleController.beaconsDB, bleController.macAddressList[idx]);
      var constantN = 2;
      var distance = logDistancePathLoss(
          rssi.toDouble(), alpha.toDouble(), constantN.toDouble());
      radiusList.add(distance);
    }
    // Tinh theo cong thuc mo hinh distance path loss
    print(
        "Ban kinh r tinh theo mo hinh distance path loss (rssiAt1m, rssiHienTai)");
    for (int i = 0; i < bleController.macAddressList.length; i++) {
      print('${bleController.macAddressList[i]} : ${radiusList[i]}');
    }
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
    List<int> stairList = [
      2,
      6,
      30,
      31,
    ];
    List<int> endStairList = [
      35,
      40,
      62,
      70,
    ];
    localization.addAnchorNode(bleController.anchorList);

    if (localization.conditionMet) {
      Offset xyMinMax = localization.minMaxPosition();

      print('x: $xyMinMax.dx , y: $xyMinMax.y');
      a.resetGraph();
      a.dijkstraCaculate(xyMinMax.dx, xyMinMax.dy,
          0); // so 1 la stt tang vd tang tret thi 0 --> tang dan 1 .2.3
      listPosition = a.getWayPoint();
      print("len way:" + listPosition.length.toString());
    }
    for (int i = 0; i < listPosition.length; i++) {
      var element = listPosition[i];
      if (element.deskId >= 35 && stairList.contains(listPosition[1].deskId)) {
        listPosition.removeAt(i - 1);
        setState(() {
          print("######################################");
          openFloor = true;
          print(")))))))))))))))))))))))))))))))) ${element.deskId}");
          controller.stop();
        });
        break;
      } else {
        openFloor = false;
      }
      //new xuongs tằng
      if (element.deskId >= 35 &&
          endStairList.contains(listPosition[1].deskId)) {
        listPosition.removeAt(i - 1);
        setState(() {
          print("######################################");
          closeFloor = true;
          controller.stop();
        });
        break;
      } else {
        closeFloor = false;
      }
      // bool b1 = a.x >= listPosition[listPosition.length - 1].x - 10;
      // bool b2 = a.x <= listPosition[listPosition.length - 1].x + 10;
      // bool b3 = a.y >= listPosition[listPosition.length - 1].y - 10;
      // bool b4 = a.y <= listPosition[listPosition.length - 1].y + 10;
      // if (b1 &&
      //     b2 &&
      //     b3 &&
      //     b4 &&
      //     element.deskId == listPosition[listPosition.length - 1]) {
      //   setState(() {
      //     print("tới r");
      //     controller.stop();
      //     showDialog();
      //   });
      //   break;
      // }
    }
    final size = root.getExtent();
    final layers = root.layers
        .map<Widget>((layer) => buildLayer(context, layer, size))
        .toList();
    return InteractiveViewer(
        transformationController: controllerTF,
        maxScale: 300,
        constrained: false,
        child: Stack(children: [
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
                    // Dijkstra b1 = Dijkstra();
                    // b1.dijkstraCaculate();
                  },
                  child: Text("Lên tầng trên"),
                )
              : Center(),
          //new
          closeFloor
              ? ElevatedButton(
                  onPressed: () async {
                    final String response =
                        await rootBundle.loadString('assets/floorplan.json');
                    load(response);
                    setState(() {});
                    // Dijkstra b1 = Dijkstra();
                    // b1.dijkstraCaculate();
                  },
                  child: Text("Xuống tầng dưới"),
                )
              : Center(),
        ]));
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
