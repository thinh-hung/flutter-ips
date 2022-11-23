import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/function/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'map.dart';

class addEdgeDB extends StatefulWidget {
  final int floorNumber;
  const addEdgeDB({Key? key, required this.floorNumber})
      : super(key: key);

  @override
  State<addEdgeDB> createState() => _addEdgeDBState();
}

class _addEdgeDBState extends State<addEdgeDB> {
  final firestoreInstance = FirebaseFirestore.instance;
  int x = 0;
  int y = 0;

  Future<int> getCurrentMax() {
    return firestoreInstance
        .collection("Location")
        .orderBy('location_id', descending: true)
        .limit(1)
        .get()
        .then((value) async {
      return value.docs.first.data()['location_id'];
    });
  }

  createPath(location_id) async {
    DocumentReference documentReference =
    firestoreInstance.collection("Path").doc();
    int currentId = await getCurrentMax();
    print("-----------------------------------");
    print("end");
    print(currentId);
    print("start");
    print(location_id);

    //Map
    Map<String, dynamic> path = {
      "end_location": currentId,
      "start_location": location_id,
    };

    documentReference.set(path).whenComplete(() {
      print("tạo thành công cung");
    });
  }

  void showCreateDialog(int location_id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Tạo cung"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Bạn chắc chắn muốn tạo cung $location_id này chứ"),
            ]),
            actions: <Widget>[
              ElevatedButton(
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: Colors.redAccent,
                // ),
                  onPressed: () {
                    createPath(location_id);
                    // Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminMapScreen(
                              floorNumber: widget.floorNumber),
                        ));
                  },
                  child: Text("Tạo"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Chọn điểm tạo cung ${widget.floorNumber == 1 ? "Trệt" : widget.floorNumber - 1}"),
        actions: [logoutButton(context)],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreInstance
              .collection("Location")
              .where('map_id', isEqualTo: widget.floorNumber)
              .orderBy('location_id')
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData) {
              if (snapshots.data!.docs.length == 0)
                return Center(child: const Text('Không có dữ liệu nào'));
              else {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshots.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot documentSnapshot =
                      snapshots.data!.docs[index];
                      return Dismissible(
                          onDismissed: (direction) {
                            showCreateDialog(documentSnapshot["location_id"]);
                          },
                          key: Key(documentSnapshot["location_id"].toString()),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: InkWell(
                              onTap: () {

                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                    child: Text(
                                        '#${(documentSnapshot["location_id"])}')),
                                title: Text("X=" +
                                    documentSnapshot["x"].toString() +
                                    " Y=" +
                                    documentSnapshot["y"].toString()),
                                trailing: IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showCreateDialog(
                                          documentSnapshot["location_id"]);
                                    }),
                              ),
                            ),
                          ));
                    });
              }
            } else {
              return Align(
                alignment: FractionalOffset.bottomCenter,
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
