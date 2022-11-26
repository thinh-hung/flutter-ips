import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/screens/admin/listBeacon.dart';
import 'package:floorplans/screens/admin/listLocation.dart';
import 'package:floorplans/screens/login.dart';
import 'package:flutter/material.dart';

import '../../DrawerAdmin.dart';
import '../../element/beaconelement.dart';
import '../../element/deskelement.dart';
import '../../element/rectelement.dart';
import '../../function/utils.dart';
import '../../model/BeaconModel.dart';
import 'listPath.dart';

class AdminMapScreen extends StatefulWidget {
  final int floorNumber;
  const AdminMapScreen({Key? key, required this.floorNumber}) : super(key: key);

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  List<dynamic> roomsAndObj = [];
  List<dynamic> locations = [];
  List<dynamic> beacons = [];
  List<dynamic> paths = [];
  List<Widget> elementInScreens = [];
  List<Widget> elements = [];
  List<int> twoEdge = [];
  late TransformationController controllerTF;
  late final dataRoomAndObj;
  late final dataLocation;
  late final dataBeacon;
  late final dataPath;
  bool _dsDiemActive = false;
  late double x;
  late double y;
  Future<List<dynamic>> getLocation() async {
    var snapshot = (await FirebaseFirestore.instance
        .collection('Location')
        .where('map_id', isEqualTo: widget.floorNumber)
        .get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  Future<List<dynamic>> getBeacon() async {
    var snapshot = (await FirebaseFirestore.instance
        .collection('Beacon')
        .where('map_id', isEqualTo: widget.floorNumber)
        .get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  Future<List<dynamic>> getPath() async {
    var snapshot = (await FirebaseFirestore.instance.collection('Path').get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  Future<List<dynamic>> getRoomsAndObj() async {
    var snapshot = (await FirebaseFirestore.instance
        .collection('Room')
        .where('map_id', isEqualTo: widget.floorNumber)
        .get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });

    var snapshot2 = (await FirebaseFirestore.instance
        .collection('Object Map')
        .where('map_id', isEqualTo: widget.floorNumber)
        .get());
    snapshot2.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerTF = TransformationController();
    dataRoomAndObj = getRoomsAndObj();
    dataLocation = getLocation();
    dataBeacon = getBeacon();
    dataPath = getPath();
  }

  @override
  void dispose() {
    super.dispose();
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
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Center(child: Text("${element.roomName ?? ""}")),
        // color: element.fill,
      ),
    );
  }

  Widget buildPathElement(
      BuildContext context, DeskElement element1, DeskElement element2) {
    Offset elementOffset1 = Offset(element1.x, element1.y);
    Offset elementOffset2 = Offset(element2.x, element2.y);
    return CustomPaint(
      painter: Arrow(p1: elementOffset1, p2: elementOffset2),
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
        child: Center(
            child: Tooltip(
          message: 'ID: ${element.location_id}',
          triggerMode:
              TooltipTriggerMode.tap, // ensures the label appears when tapped
          // onTriggered: () {
          //   setState(() {
          //     twoEdge.add(element.location_id);
          //   });
          //   if (twoEdge.length == 2) {
          //     print(twoEdge);
          //
          //     twoEdge.clear();
          //   }
          // },
          preferBelow: false,
          child: Text(
            "${element.location_id}",
            style: TextStyle(fontSize: 6),
          ),
        )),
      ),
    );
  }

  Widget buildBeaconElement(BuildContext context, Beacon element) {
    return Positioned(
        top: element.y - element.radius,
        left: element.x - 10,
        child: Tooltip(
          message: 'ID: ${element.id}\nMac: ${element.mac_address}',
          triggerMode:
              TooltipTriggerMode.tap, // ensures the label appears when tapped
          preferBelow: false, // use this if you want the label above the widget
          child: Image.asset(
            "assets/images/bluetooth_icon.png",
          ),
        ));
  }

  void napDiemAo() async {
    locations = await dataLocation;
    locations.forEach(
      (element) {
        return elements
            .add(buildDeskElement(context, DeskElement.fromJson(element)));
      },
    );
  }

  Map<String, dynamic>? getLocationById(List<dynamic> list, int id) {
    int a = -1;

    for (int i = 0; i < list.length; i++) {
      if (list[i]['location_id'] == id) {
        a = i;
        break;
      }
    }
    if (a == -1) {
      return null;
    } else {
      return list[a];
    }
  }

  void napDuongDi() async {
    locations = await dataLocation;
    paths = await dataPath;
    paths.forEach(
      (element1) {
        Map<String, dynamic>? item1 =
            getLocationById(locations, element1['start_location']);
        Map<String, dynamic>? item2 =
            getLocationById(locations, element1['end_location']);
        print("$item1 : $item2");
        print("${element1['start_location']} : ${element1['end_location']}");
        if (item1 != null && item2 != null) {
          elements.add(buildPathElement(
            context,
            DeskElement.fromJson(item1),
            DeskElement.fromJson(item2),
          ));
        }
      },
    );
  }

  void napBeacon() async {
    beacons = await dataBeacon;
    beacons.forEach(
      (element) {
        return elements
            .add(buildBeaconElement(context, Beacon.fromJson(element)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    napDuongDi();
    napBeacon();
    napDiemAo();
    return Scaffold(
        appBar: AppBar(
          title: Text(
              "Quản trị bản đồ tầng ${widget.floorNumber == 1 ? "trệt" : widget.floorNumber - 1}"),
          actions: [
            logoutButton(context),
          ],
        ),
        drawer: draweradmin(floorNumber: widget.floorNumber,),
        body: GestureDetector(
          onTapUp: (TapUpDetails details) {
            print(
              controllerTF.toScene(details.localPosition),
            );
            x = double.parse(controllerTF
                .toScene(details.localPosition)
                .dx
                .toStringAsFixed(2));
            y = double.parse(controllerTF
                .toScene(details.localPosition)
                .dy
                .toStringAsFixed(2));
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tọa độ hiện tại: X: $x - Y: $y')));
          },
          child: Stack(
            children: [
              InteractiveViewer(
                  transformationController: controllerTF,
                  maxScale: 300,
                  constrained: false,
                  child: CustomPaint(
                    child: FutureBuilder(
                      future: dataRoomAndObj,
                      initialData: [],
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return loadTextMap(context);
                            break;
                          case ConnectionState.done:
                            if (snapshot.hasData && !snapshot.hasError) {
                              if (snapshot.data == null) {
                                return const Text("No Data",
                                    style: TextStyle(fontSize: 20.0));
                              } else {
                                // call the setTextFields method when the future is done
                                roomsAndObj =
                                    (snapshot.data ?? []) as List<dynamic>;
                                roomsAndObj.forEach(
                                  (element) {
                                    return elementInScreens.add(
                                        buildRectElement(context,
                                            RectElement.fromJson(element)));
                                  },
                                );
                                elementInScreens.addAll(elements);
                                return SizedBox(
                                  height: 900,
                                  width: 900,
                                  child: Stack(
                                    children: elementInScreens,
                                  ),
                                );
                              }
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          default:
                            return Text('');
                        }
                      },
                    ),
                  )),
            ],
          ),
        ));
  }
}

class Arrow extends CustomPainter {
  Offset p1;
  Offset p2;
  Arrow({required this.p1, required this.p2});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(45, 150, 133, 236)
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
