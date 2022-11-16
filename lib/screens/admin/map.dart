import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/screens/admin/listBeacon.dart';
import 'package:floorplans/screens/admin/listLocation.dart';
import 'package:floorplans/screens/login.dart';
import 'package:flutter/material.dart';

import '../../element/beaconelement.dart';
import '../../element/deskelement.dart';
import '../../element/rectelement.dart';
import '../../function/utils.dart';
import '../../model/BeaconModel.dart';

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
  List<Widget> elementInScreens = [];
  List<Widget> elements = [];
  late TransformationController controllerTF;
  late final dataRoomAndObj;
  late final dataLocation;
  late final dataBeacon;
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
          child: Text(
            "${element.location_id}",
            style: TextStyle(fontSize: 6),
          ),
        ),
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
    napDiemAo();
    napBeacon();
    return Scaffold(
        appBar: AppBar(
          title: Text(
              "Quản trị bản đồ tầng ${widget.floorNumber == 1 ? "trệt" : widget.floorNumber - 1}"),
          actions: [
            logoutButton(context),
          ],
        ),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListLocationScreen(
                                    floorNumber: widget.floorNumber),
                              )).then((_) {
                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          widget));
                            });
                          });
                        },
                        child: Text("Quản lí điểm ảo")),
                    SizedBox(width: 20),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListBeaconScreen(
                                    floorNumber: widget.floorNumber),
                              )).then((_) {
                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          widget));
                            });
                          });
                        },
                        child: Text("Quản lí beacon")),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
