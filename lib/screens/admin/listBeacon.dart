import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ListBeaconScreen extends StatefulWidget {
  final int floorNumber;
  const ListBeaconScreen({Key? key, required this.floorNumber})
      : super(key: key);

  @override
  State<ListBeaconScreen> createState() => _ListBeaconScreenState();
}

class _ListBeaconScreenState extends State<ListBeaconScreen> {
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

  createTodos() async {
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
      print("tạo thành công");
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

  deleteTodos(location_id) async {
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
            title: Text("Cập nhật địa điểm"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách beacon ở tầng ${widget.floorNumber}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  title: Text("Thêm địa điểm"),
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
                          x = int.parse(value);
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
                          y = int.parse(value);
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          createTodos();
                          Navigator.of(context).pop();
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
              .orderBy("location_id")
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshots.data!.docs[index];
                    return Dismissible(
                        onDismissed: (direction) {
                          deleteTodos(documentSnapshot["location_id"]);
                        },
                        key: Key(documentSnapshot["location_id"].toString()),
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: InkWell(
                            onTap: () {
                              showUpdateDialog(documentSnapshot["location_id"],
                                  documentSnapshot["x"], documentSnapshot["y"]);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                  child: Text(
                                      '#${(documentSnapshot["location_id"])}')),
                              title: Text(
                                  documentSnapshot["location_id"].toString() +
                                      "-" +
                                      documentSnapshot["x"].toString() +
                                      "-" +
                                      documentSnapshot["y"].toString()),
                              trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    deleteTodos(
                                        documentSnapshot["location_id"]);
                                  }),
                            ),
                          ),
                        ));
                  });
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
