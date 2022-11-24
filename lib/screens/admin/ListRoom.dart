import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/function/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';


class ListRoom extends StatefulWidget {
  final int floorNumber;
  const ListRoom({Key? key, required this.floorNumber}) : super(key: key);

  @override
  State<ListRoom> createState() => _ListRoomState();
}

class _ListRoomState extends State<ListRoom> {
  final firestoreInstance = FirebaseFirestore.instance;
  String? room_namenew;

  updateLocation(room_name ,room_namenew) async {
    final documentReference = await firestoreInstance
        .collection("Room")
        .where("room_name", isEqualTo: room_name)
        .get()
        .then((value) {
      return firestoreInstance.collection("Room").doc(value.docs.first.id);
    });
    Map<String, dynamic> location = {
      "room_name": room_namenew,
    };
    documentReference.set(location, SetOptions(merge: true)).whenComplete(() {
      print("$room_name cập nhật tên phòng thành công");
    });
  }

  void showUpdateDialog(String room_name) {
    room_namenew = room_name;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Cập nhật tên phòng"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: room_name.toString(),
                  // inputFormatters: <TextInputFormatter>[
                  //   FilteringTextInputFormatter.digitsOnly
                  // ],
                  decoration: InputDecoration(
                      hintText: "Nhập tên phòng: "),
                  onChanged: (String value) {
                    if (value != "") room_namenew = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    updateLocation(room_name,room_namenew);
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
        title: Text(
            "Danh sách Phòng tầng ${widget.floorNumber == 1 ? "trệt" : widget.floorNumber - 1}"),
        actions: [logoutButton(context)],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreInstance
              .collection("Room")
              .orderBy('room_name')
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
                          key: Key(documentSnapshot["room_name"].toString()),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: InkWell(
                                onTap: () {
                                  showUpdateDialog(
                                      documentSnapshot["room_name"]);
                                },
                                child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("${documentSnapshot["room_name"]}"),
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