import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/function/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'addEdgeDB.dart';

class ListPath extends StatefulWidget {
  final int floorNumber;
  const ListPath({Key? key, required this.floorNumber}) : super(key: key);

  @override
  State<ListPath> createState() => _ListPathState();
}

class _ListPathState extends State<ListPath> {
  final firestoreInstance = FirebaseFirestore.instance;
  int end_location = 0;
  int start_location = 0;

  updateLocation(
      start_location, end_location, startLocationNew, endLocationNew) async {
    // final documentReference = await firestoreInstance
    //     .collection("Path")
    //     .where("end_location", isEqualTo: end_location)
    //     .where("start_location", isEqualTo: start_location)
    //     .get()
    //     .then((value) {
    //   return firestoreInstance.collection("Path").doc(value.docs.first.id);
    // });

    final documentReference = await firestoreInstance
        .collection("Path")
        .where("end_location", isEqualTo: end_location)
        .where("start_location", isEqualTo: start_location)
        .get()
        .then((value) {
      return firestoreInstance.collection("Path").doc(value.docs.first.id);
    });
    Map<String, dynamic> location = {
      "end_location": endLocationNew,
      "start_location": startLocationNew
    };
    documentReference.set(location, SetOptions(merge: true)).whenComplete(() {
      print("($endLocationNew , $startLocationNew) cập nhật cung thành công");
    });
  }

  deleteLocation(end_location, start_location) async {
    final documentReference = await firestoreInstance
        .collection("Path")
        .where('end_location', isEqualTo: end_location)
        .where('start_location', isEqualTo: start_location)
        .get()
        .then((value) {
      return firestoreInstance.collection("Path").doc(value.docs.first.id);
    });

    documentReference.delete().whenComplete(() {
      print("($end_location , $start_location) deleted successful");
    });
  }

  void showUpdateDialog(int currentend, int currentstart) {
    end_location = currentend;
    start_location = currentstart;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Cập nhật cung"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: currentstart.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                      hintText: "Nhập Id đầu cung(start_location): "),
                  onChanged: (String value) {
                    if (value != "") start_location = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: currentend.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                      hintText: "Nhập Id cuối cung(end_location): "),
                  onChanged: (String value) {
                    if (value != "") end_location = int.parse(value);
                  },
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    updateLocation(
                        currentstart, currentend, start_location, end_location);
                    Navigator.of(context).pop();
                  },
                  child: Text("Cập nhật"))
            ],
          );
        });
  }

  void showDeleteDialog(int currentend, int currentstart) {
    end_location = currentend;
    start_location = currentstart;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Xóa cung này"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  "Bạn chắc chắn muốn xóa cung số  $currentend,  $currentstart này chứ"),
            ]),
            actions: <Widget>[
              ElevatedButton(
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.redAccent,
                  // ),
                  onPressed: () {
                    deleteLocation(end_location, start_location);
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
            "Danh sách cung tầng ${widget.floorNumber == 1 ? "trệt" : widget.floorNumber - 1}"),
        actions: [logoutButton(context)],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreInstance
              .collection("Path")
              .orderBy('end_location')
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
                          // onDismissed: (direction) {
                          //   showDeleteDialog(documentSnapshot["location_id"]);
                          // },
                          key: Key(documentSnapshot["end_location"].toString()),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: InkWell(
                                onTap: () {
                                  showUpdateDialog(
                                      documentSnapshot["end_location"],
                                      documentSnapshot["start_location"]);
                                },
                                child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      CircleAvatar(
                                          child: Text(
                                              "${documentSnapshot["start_location"]}")),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 25,
                                        width: 25,
                                        child: Image.asset(
                                            "assets/images/double-arrows.png"),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      CircleAvatar(
                                          child: Text(
                                              "${documentSnapshot["end_location"]}")),
                                      Expanded(
                                        child: Center(),
                                      ),
                                      IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            showDeleteDialog(
                                                documentSnapshot[
                                                    "end_location"],
                                                documentSnapshot[
                                                    "start_location"]);
                                          }),
                                    ]))),
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
