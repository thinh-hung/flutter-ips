import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/SearchRoom.dart';
import 'package:floorplans/bledata.dart';
import 'package:floorplans/gird/circle_painter.dart';
import 'package:floorplans/model/LocationModel.dart';
import 'package:floorplans/showResultSearch.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'element/Matrix.dart';
import 'element/baseelement.dart';
import 'element/beaconelement.dart';
import 'element/deskelement.dart';
import 'element/layerelement.dart';
import 'element/rectelement.dart';
import 'element/rootelement.dart';
import 'function/dijkstra.dart';
import 'function/utils.dart';
import 'gird/drawAPath.dart';
import 'gird/gird_painter.dart';
import 'localizations/localizationalgorithms.dart';
import 'package:flutter/material.dart';

import 'model/RoomModel.dart';

class Floorplan extends StatefulWidget {
  int search_location_finish = 0;
  int map_id = 1;
  Floorplan(
      {required this.search_location_finish, required this.map_id, Key? key})
      : super(key: key);

  @override
  State<Floorplan> createState() => _FloorplanState();
}

class _FloorplanState extends State<Floorplan>
    with SingleTickerProviderStateMixin {
  bool isNotComplete = true;
  late RootElement root;
  late TransformationController controllerTF;
  late AnimationController controller;
  var bleController = Get.put(BLEResult());
  var centerXList = [];
  var centerYList = [];
  Dijkstra a = Dijkstra();
  bool openFloor = false;
  bool closeFloor = false;
  int t = 1;

  List<Location> listPosition = [];
  Localization localization = Localization();

  List<num> radiusList = [];
  List<dynamic> roomsAndObj = [];

  late final dataRoomAndObj = [];
  List<List<int>> matrix2 = [];
  Future<List<dynamic>> getRoomsAndObj() async {
    var snapshot = (await FirebaseFirestore.instance
        .collection('Room')
        .where('map_id', isEqualTo: widget.map_id)
        .get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });

    var snapshot2 = (await FirebaseFirestore.instance
        .collection('Object Map')
        .where('map_id', isEqualTo: widget.map_id)
        .get());
    snapshot2.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  void load() {
    //-------------Matrix-------------------
    matrix2 = matrix(900, 900);
    // print("data.jsonFloorplan" + data.toString());
  }

  @override
  void didUpdateWidget(covariant Floorplan oldWidget) {
    print("widget.search_location");
    print(widget.search_location_finish);
    // TODO: implement didUpdateWidget
    // print("getLocationId : ${SearchRoom.getLocationId()}");
    widget.search_location_finish = SearchRoom.getLocationId(t);
    t = 1;
    print("widget.search_location");
    print(widget.search_location_finish);
    // print("isnotcommplete $isNotComplete");
    // if (isNotComplete == false) {
    //   widget.search_location_finish = 0;
    // }
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
    load();
    super.initState();
  }

  // Widget buildRectElement(BuildContext context, RectElement element) {
  //   return Positioned(
  //     top: element.y,
  //     left: element.x,
  //     child: Container(
  //       height: element.height,
  //       width: element.width,
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: element.fill as Color,
  //           width: 2,
  //         ),
  //       ),
  //       child: Center(child: Text("${element.roomName}")),
  //       // color: element.fill,
  //     ),
  //   );
  // }

  //-------------------------------Phần thêm vào--------------------------------
  var idcolor = 0;
  Widget buildRectElement(BuildContext context, RectElement element) {
    int val = 1;
    int x = element.x.ceil();
    int y = element.y.ceil();
    int x1 = element.x.ceil() + element.width.ceil();
    int y1 = element.y.ceil() + element.height.ceil();
    // print("$x $y $x1 $y1");

    //from left to right
    for (var i = x; i <= x1; i++) {
      matrix2[i][y] = val;
      matrix2[i][y1] = val;
    }
    //from top to bottom
    for (var i = y; i <= y1; i++) {
      matrix2[x][i] = val;
      matrix2[x1][i] = val;
    }
    matrix2[0][1] = 1;
    int idroom = element.idLocation ?? 0;

    List<Map<String, int>> stair = [
      {"x": 340, "y": 580},
      {"x": 342, "y": 580},
      {"x": 200, "y": 698},
      {"x": 109, "y": 409},
      {"x": 470, "y": 261},
      {"x": 198, "y": 697}
    ];
    var check = true;

    stair.forEach((x) {
      if (x["x"] == element.x && x["y"] == element.y) {
        check = false;
      }
    });
    // print(check);
    return check
        ? Positioned(
            top: element.y,
            left: element.x,
            child: InkWell(
              onTap: () async {
                if (element.idLocation.toString() != null) {
                  setState(() {
                    element.fill = element.fill == element.baseFill
                        ? Colors.brown[300]
                        : element.baseFill;
                    element.frame = element.frame == element.baseFrame
                        ? Colors.white
                        : element.baseFrame;
                    idcolor = element.idLocation!;
                  });
                }
                if (idroom != 0) {
                  Location location = await getLocation(idroom);
                  Room room = await getRoomAreaByLocation_Id(location);
                  Map<String, dynamic> dataSearch = {
                    "location": location,
                    "room": room,
                  };
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ShowResultSearch(locationResult: dataSearch);
                  }));
                }
              },
              child: Ink(
                height: element.height,
                width: element.width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: idcolor == element.idLocation
                        ? element.frame as Color
                        : Colors.black,
                    width: 2,
                  ),
                  color: idcolor == element.idLocation
                      ? element.fill as Color
                      : Colors.white,
                ),
                child: Center(
                    child: Text(
                  "${element.roomName}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          )
        : Positioned(
            top: element.y,
            left: element.x,
            child: Container(
                height: element.height,
                width: element.width,
                child: Icon(
                  Icons.stairs,
                  size: 50,
                  color: Colors.brown,
                )
                // color: element.fill,
                ),
          );
  }

  Widget buildStair(BuildContext context, RectElement element) {
    return Positioned(
      top: element.y,
      left: element.x,
      child: Container(
          height: element.height,
          width: element.width,
          child: Icon(
            Icons.stairs,
            size: 60,
            color: Colors.black12,
          )
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
    localization.addAnchorNode(bleController.anchorList);

    if (localization.conditionMet) {
      // if (true) {
      Offset xyMinMax = localization.minMaxPosition();

      print('x: $xyMinMax.dx , y: $xyMinMax.y');
      a.resetGraph();
      a.dijkstraCaculate(
          xyMinMax.dx.toInt(),
          xyMinMax.dy.toInt(),
          widget.map_id - 1,
          widget
              .search_location_finish); // so 1 la stt tang vd tang tret thi 0 --> tang dan 1 .2.3
      listPosition = a.getWayPoint();
      if (listPosition.length > 1 && isNotComplete) {
        bool b1 = xyMinMax.dx >= listPosition[listPosition.length - 1].x - 20;
        bool b2 = xyMinMax.dx <= listPosition[listPosition.length - 1].x + 20;
        bool b3 = xyMinMax.dy >= listPosition[listPosition.length - 1].y - 20;
        bool b4 = xyMinMax.dy <= listPosition[listPosition.length - 1].y + 20;
        bool b5 = listPosition[listPosition.length - 2].id == 0;
        if ((b1 || b2 || b3 || b4) && b5) {
          setState(() {
            // controller.stop();
            isNotComplete = false;

            showDialog();
          });
        }
      }
    }
    // for (int i = 0; i < listPosition.length; i++) {
    //   var element = listPosition[i];

    //   // if(element.map_id != 0){
    //   //   listPosition.removeRange(i, listPosition.length);
    //   //   break;
    //   // }
    //   if (element.id >= 35 && stairList.contains(listPosition[1].id)) {
    //     listPosition.removeAt(i - 1);
    //     setState(() {
    //       openFloor = true;
    //       controller.stop();
    //     });
    //     break;
    //   } else {
    //     openFloor = false;
    //   }
    //   //new xuongs tằng
    //   if (element.id >= 35 && endStairList.contains(listPosition[1].id)) {
    //     listPosition.removeAt(i - 1);
    //     setState(() {
    //       closeFloor = true;
    //       controller.stop();
    //     });
    //     break;
    //   } else {
    //     closeFloor = false;
    //   }

    //   // if (b1 &&
    //   //     b2 &&
    //   //     b3 &&
    //   //     b4 &&
    //   //     element.location_id == listPosition[listPosition.length - 1]) {
    //   //   setState(() {
    //   //     print("tới r");
    //   //     controller.stop();
    //   //     showDialog();
    //   //   });
    //   //   break;
    //   // }
    // }

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
            child: Stack(children: [
              RepaintBoundary(
                  child: CustomPaint(
                painter: LinePainter(
                    listPosition: listPosition, mapid: widget.map_id),
              )),
              RepaintBoundary(
                child: CustomPaint(
                  painter: GridPainter(),
                  foregroundPainter:
                      CirclePainter(centerXList, centerYList, radiusList),
                  child: FutureBuilder(
                    future: getRoomsAndObj(),
                    builder: (context, snapshot) {
                      roomsAndObj = (snapshot.data ?? []) as List<dynamic>;

                      final data = {
                        "schema":
                            "https://evoko.app/schema/floorplan.schema.json",
                        "locationId": "Floor1",
                        "children": [
                          {
                            "type": "layer",
                            "id": "floorplan-layer",
                            "children": roomsAndObj
                          }
                        ]
                      };
                      // final data = json.decode(jsonString);
                      root = RootElement.fromJson(data, 'rect');
                      final size = root.getExtent();
                      final layers = root.layers
                          .map<Widget>(
                              (layer) => buildLayer(context, layer, size))
                          .toList();

                      // print(jsonString);
                      return Stack(
                        children: layers,
                      );
                    },
                  ),
                ),
              ),
            ]),
          ),
          openFloor
              ? ElevatedButton(
                  onPressed: () async {
                    final String response =
                        await rootBundle.loadString('assets/floor2.json');
                    load();
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
                    load();
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
          t = 0;
          isNotComplete = true;
          listPosition.clear();
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        },
      ).show();
    });
  }

  void getDataFromFirebase() async {
    await getRoomsAndObj().then((value) => dataRoomAndObj.add(value));
  }
}
