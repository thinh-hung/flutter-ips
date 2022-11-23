import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/function/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'addEdgeDB.dart';

class ListLocationScreen extends StatefulWidget {
  final int floorNumber;
  const ListLocationScreen({Key? key, required this.floorNumber})
      : super(key: key);

  @override
  State<ListLocationScreen> createState() => _ListLocationScreenState();
}

class _ListLocationScreenState extends State<ListLocationScreen> {
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

  createLocation() async {
    DocumentReference documentReference =
        firestoreInstance.collection("Location").doc();
    int currentId = await getCurrentMax();

    //Map
    Map<String, dynamic> location = {
      "location_id": currentId + 1,
      "map_id": widget.floorNumber,
      "x": x,
      "y": y
    };

    documentReference.set(location).whenComplete(() {
      print("tạo thành công điểm ảo");
    });
  }

  updateLocation(location_id, xnew, ynew) async {
    final documentReference = await firestoreInstance
        .collection("Location")
        .where('location_id', isEqualTo: location_id)
        .get()
        .then((value) {
      return firestoreInstance.collection("Location").doc(value.docs.first.id);
    });
    Map<String, dynamic> location = {
      "location_id": location_id,
      "map_id": widget.floorNumber,
      "x": xnew,
      "y": ynew
    };
    documentReference.set(location, SetOptions(merge: true)).whenComplete(() {
      print("$location_id updated");
    });
  }

  deleteLocation(location_id) async {
    final documentReference = await firestoreInstance
        .collection("Location")
        .where('location_id', isEqualTo: location_id)
        .get()
        .then((value) {
      return firestoreInstance.collection("Location").doc(value.docs.first.id);
    });

    documentReference.delete().whenComplete(() {
      print("$location_id deleted");
    });
  }

  void showUpdateDialog(int location_id, int currentX, int currentY) {
    x = currentX;
    y = currentY;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Cập nhật điểm ảo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: currentX.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(hintText: "Nhập tọa độ X: "),
                  onChanged: (String value) {
                    if (value != "") x = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: currentY.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(hintText: "Nhập tọa độ Y: "),
                  onChanged: (String value) {
                    if (value != "") y = int.parse(value);
                  },
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    updateLocation(location_id, x, y);
                    Navigator.of(context).pop();
                  },
                  child: Text("Cập nhật"))
            ],
          );
        });
  }

  void showDeleteDialog(int location_id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Xóa điểm ảo"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Bạn chắc chắn muốn xóa điểm ảo số $location_id này chứ"),
            ]),
            actions: <Widget>[
              ElevatedButton(
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.redAccent,
                  // ),
                  onPressed: () {
                    deleteLocation(location_id);
                    Navigator.of(context).pop();
                  },
                  child: Text("Xóa"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Danh sách điểm ảo tầng ${widget.floorNumber == 1 ? "trệt" : widget.floorNumber - 1}"),
        actions: [logoutButton(context)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  title: Text("Thêm điểm ảo"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            InputDecoration(hintText: "Nhập tọa độ X: "),
                        onChanged: (String value) {
                          if (value != "") x = int.parse(value);
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            InputDecoration(hintText: "Nhập tọa độ Y: "),
                        onChanged: (String value) {
                          if (value != "") y = int.parse(value);
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          createLocation();
                          // Navigator.of(context).pop();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    addEdgeDB(floorNumber: widget.floorNumber),
                              ));
                        },
                        child: Text("Thêm"))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
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
                            showDeleteDialog(documentSnapshot["location_id"]);
                          },
                          key: Key(documentSnapshot["location_id"].toString()),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: InkWell(
                              onTap: () {
                                showUpdateDialog(
                                    documentSnapshot["location_id"],
                                    documentSnapshot["x"],
                                    documentSnapshot["y"]);
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
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDeleteDialog(
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
