import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/floorplan.dart';
import 'package:flutter/material.dart';

import '../../rectelement.dart';

class AdminMapScreen extends StatefulWidget {
  final int floorNumber;
  const AdminMapScreen({Key? key, required this.floorNumber}) : super(key: key);

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  List<dynamic> roomsAndObj = [];
  List<Widget> a = [];
  late TransformationController controllerTF;
  late final dataRoomAndObj;
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
        child: Center(child: Text("phòng")),
        // color: element.fill,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quản trị bản đồ"),
        ),
        body: InteractiveViewer(
            transformationController: controllerTF,
            maxScale: 300,
            constrained: false,
            child: Stack(children: [
              GestureDetector(
                onTapDown: (details) {
                  print("x2: " + details.localPosition.dx.toString());

                  print("y: " + details.localPosition.dy.toString());
                },
                child: FutureBuilder(
                  future: dataRoomAndObj,
                  initialData: [],
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
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
                              (element) => a.add(buildRectElement(
                                  context, RectElement.fromJson(element))),
                            );
                            return CustomPaint(
                              child: SizedBox(
                                height: 900,
                                width: 900,
                                child: Stack(
                                  children: a,
                                ),
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
              )
            ])));
  }
}
