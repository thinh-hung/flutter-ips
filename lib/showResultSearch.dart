import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/main.dart';
import 'package:floorplans/model/RoomModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'element/Matrix.dart';
import 'element/baseelement.dart';
import 'element/beaconelement.dart';
import 'element/deskelement.dart';
import 'element/layerelement.dart';
import 'element/rectelement.dart';
import 'element/rootelement.dart';
import 'function/utils.dart';
import 'gird/gird_painter.dart';
import 'model/LocationModel.dart';

class ShowResultSearch extends StatefulWidget {
  final Map<String, dynamic> locationResult;
  const ShowResultSearch({required this.locationResult, Key? key})
      : super(key: key);

  @override
  State<ShowResultSearch> createState() => _ShowResultSearchState();
}

class _ShowResultSearchState extends State<ShowResultSearch>
    with SingleTickerProviderStateMixin {
  late RootElement root;
  late TransformationController controllerTF;
  List<List<int>> matrix2 = [];
  List<dynamic> roomsAndObj = [];
  late final dataRoomAndObj = [];
  Future<List<dynamic>> getRoomsAndObj() async {
    var documents = [];
    var snapshot2 = (await FirebaseFirestore.instance
        .collection('Object Map')
        .where('map_id', isEqualTo: widget.locationResult["location"].map_id)
        .get());
    snapshot2.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    var snapshot = (await FirebaseFirestore.instance
        .collection('Room')
        .where('map_id', isEqualTo: widget.locationResult["location"].map_id)
        .get());
    snapshot.docs.forEach((element) {
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
  void didUpdateWidget(covariant ShowResultSearch oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    controllerTF = TransformationController();
    final zoomFactor = 1.5;
    final xTranslate = widget.locationResult["room"].x.toDouble();
    final yTranslate = widget.locationResult["room"].y.toDouble();
    controllerTF.value.setEntry(0, 0, zoomFactor);
    controllerTF.value.setEntry(1, 1, zoomFactor);
    controllerTF.value.setEntry(2, 2, zoomFactor);
    controllerTF.value.setEntry(0, 3, -xTranslate);
    controllerTF.value.setEntry(1, 3, -yTranslate);
    // debugPrint(widget.jsonFloorplan);
    load();
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      _showModalBottom();
    });
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
          _showModalBottom();
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
    return Scaffold(
      appBar: AppBar(title: Text("Kết quả tìm kiếm")),
      body: InteractiveViewer(
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
                // painter: LinePainter(listPosition: listPosition),
                painter: GridPainter(),

                child: FutureBuilder(
                  future: getRoomsAndObj(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return loadTextMap(context);
                        break;
                      case ConnectionState.done:
                        if (snapshot.hasData && !snapshot.hasError) {
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
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      default:
                        return Text('');
                    }
                  },
                ),
                foregroundPainter: CirclePainterResult(
                    widget.locationResult["location"].x,
                    widget.locationResult["location"].y,
                    widget.locationResult["room"].x,
                    widget.locationResult["room"].y,
                    widget.locationResult["room"].w,
                    widget.locationResult["room"].h),
              ),
            ),
          ])),
    );
  }

  @override
  void dispose() {
    controllerTF.dispose();
    super.dispose();
  }

  void getDataFromFirebase() async {
    await getRoomsAndObj().then((value) => dataRoomAndObj.add(value));
  }

  void _showModalBottom() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        context: context,
        builder: (builder) {
          return Container(
            padding: const EdgeInsets.all(15),
            height: 129,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Phòng ${widget.locationResult["room"].roomName}",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        " - Tầng ${widget.locationResult["room"].map_id == 1 ? "Trệt" : widget.locationResult["room"].map_id - 1}",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(shape: StadiumBorder()),
                          onPressed: () {
                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => MyApp(
                            //           search_location_finish:
                            //               widget.locationResult),
                            //     ));
                            Navigator.pop(context);
                            Navigator.pop(
                                context, widget.locationResult["location"].id);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Đường đi")
                            ],
                          )),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              backgroundColor:
                                  ui.Color.fromARGB(255, 226, 209, 209)),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, color: Colors.black),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Trở về",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          )),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  )
                ]),
          );
        });
  }
}

class CirclePainterResult extends CustomPainter {
  var dx = 0;
  var dy = 0;
  var roomx = 0;
  var roomy = 0;
  var roomw = 0;
  var roomh = 0;
  late ui.Image image;
  CirclePainterResult(
    this.dx,
    this.dy,
    this.roomx,
    this.roomy,
    this.roomw,
    this.roomh,
  );
  // Future<ui.Image> load(String asset) async {
  //   ByteData data = await rootBundle.load(asset);
  //   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  //   ui.FrameInfo fi = await codec.getNextFrame();

  //   return fi.image;
  // }

  // convertFutureToGlobal() async {
  //   image = await load("assets/images/marker_map_icon.png");
  // }

  @override
  void paint(Canvas canvas, Size size) {
    // convertFutureToGlobal();
    canvas.drawCircle(
        Offset(dx.toDouble(), dy.toDouble()), 10, Paint()..color = Colors.blue);
    // canvas.drawImage(
    //     image, Offset(dx.toDouble() - 32, dy.toDouble() - 64), Paint());
    canvas.drawRect(
        Rect.fromLTWH(roomx.toDouble(), roomy.toDouble(), roomw.toDouble(),
            roomh.toDouble()),
        Paint()..color = ui.Color.fromARGB(141, 28, 105, 169));
  }

  @override
  bool shouldRepaint(CirclePainterResult oldDelegate) {
    return true;
  }
}
