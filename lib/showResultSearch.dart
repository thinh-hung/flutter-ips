import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/SearchRoom.dart';
import 'package:floorplans/bledata.dart';
import 'package:floorplans/gird/circle_painter.dart';
import 'package:floorplans/model/LocationModel.dart';
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

class ShowResultSearch extends StatefulWidget {
  final int locationResult;
  const ShowResultSearch({Key? key, required this.locationResult})
      : super(key: key);

  @override
  State<ShowResultSearch> createState() => _FloorplanState();
}

class _FloorplanState extends State<ShowResultSearch>
    with SingleTickerProviderStateMixin {
  late RootElement root;
  late TransformationController controllerTF;
  late AnimationController controller;
  var centerXList = [];
  var centerYList = [];
  late final Location location;
  List<DeskElement> listPosition = [];

  List<num> radiusList = [];
  List<dynamic> roomsAndObj = [];

  late final dataRoomAndObj = [];
  List<List<int>> matrix2 = [];

  Future<Location> getLocation() async {
    var snapshot = (await FirebaseFirestore.instance
        .collection('Location')
        .where('location_id', isEqualTo: widget.locationResult)
        .get());
    late final Location location;

    snapshot.docs.forEach((element) {
      var document = element.data();
      location = Location.fromJson(document);
    });
    return location;
  }

  Future<List<dynamic>> getRoomsAndObj() async {
    location = await getLocation();
    var snapshot = (await FirebaseFirestore.instance
        .collection('Room')
        .where('map_id', isEqualTo: location.map_id)
        .get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });

    var snapshot2 = (await FirebaseFirestore.instance
        .collection('Object Map')
        .where('map_id', isEqualTo: location.map_id)
        .get());
    snapshot2.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  void load() {
    print("-------------------------------------------------");
    print(dataRoomAndObj);

    //-------------Matrix-------------------
    matrix2 = matrix(900, 900);
    // print("data.jsonFloorplan" + data.toString());
  }

  @override
  void didUpdateWidget(covariant ShowResultSearch oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
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

    return Positioned(
      top: element.y,
      left: element.x,
      child: InkWell(
        onTap: () {
          print(element.idLocation.toString());
          setState(() {
            element.fill = element.fill == element.baseFill
                ? Colors.brown[300]
                : element.baseFill;
            element.frame = element.frame == element.baseFrame
                ? Colors.white
                : element.baseFrame;
            idcolor = element.idLocation!;
          });
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
        ),
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
    return MaterialApp(
        title: 'Floorplans Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Ban Do Tang tren Khoa"),
              backgroundColor: Colors.blueAccent,
            ),
            backgroundColor: Colors.brown[100],
            body: InteractiveViewer(
                transformationController: controllerTF,
                maxScale: 300,
                constrained: false,
                child: Stack(children: [
                  GestureDetector(
                    onTapDown: (details) {},
                    child: CustomPaint(
                      // painter: LinePainter(listPosition: listPosition),
                      painter: GridPainter(),

                      child: FutureBuilder(
                        future: getRoomsAndObj(),
                        builder: (context, snapshot) {
                          roomsAndObj = (snapshot.data ?? []) as List<dynamic>;

                          print("-===========================================");
                          print(snapshot.data);
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
                          // layers.add(buildDeskElement(
                          //     context,
                          //     DeskElement(
                          //         location_id: location.id,
                          //         x: location.x.toDouble(),
                          //         y: location.y.toDouble(),
                          //         map_id: location.map_id)));
                          return Stack(
                            children: layers,
                          );
                        },
                      ),
                    ),
                  ),
                ]))));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getDataFromFirebase() async {
    await getRoomsAndObj().then((value) => dataRoomAndObj.add(value));
  }
}