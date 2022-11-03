import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/floorplan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AdminMapScreen extends StatefulWidget {
  final int floorNumber;
  const AdminMapScreen({Key? key, required this.floorNumber}) : super(key: key);

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  Map<String, dynamic> dataObjectMap = Map<String, dynamic>();
  List<dynamic> rooms = [];
  late final data;
  Future<List<dynamic>> data2() async {
    var snapshot = (await FirebaseFirestore.instance.collection('Room').get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = data2();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quản trị bản đồ"),
        ),
        body: InteractiveViewer(
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
                  child: FutureBuilder(
                    future: data,
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
                              return Text("No Data",
                                  style: new TextStyle(fontSize: 20.0));
                            } else {
                              // call the setTextFields method when the future is done
                              rooms = (snapshot.data ?? []) as List<dynamic>;
                              rooms.forEach((e) {
                                print(e["room_name"]);
                              });
                              return Center(
                                child: Text(""),
                              );
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        default:
                          return Text('');
                      }
                    },
                  ))
            ])));
  }
}
