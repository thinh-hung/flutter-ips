import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/function/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
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
  String mac_address = "";
  int rssi_at_1m = -66;

  Future<bool> getStatus(int idBeacon) {
    return firestoreInstance
        .collection("Beacon")
        .where('beacon_id', isEqualTo: idBeacon)
        .get()
        .then((value) async {
      return value.docs.first.data()['isActive'];
    });
  }

  updateStatus(int beacon_id, bool isActive) async {
    final documentReference = await firestoreInstance
        .collection("Beacon")
        .where('beacon_id', isEqualTo: beacon_id)
        .get()
        .then((value) {
      return firestoreInstance.collection("Beacon").doc(value.docs.first.id);
    });
    Map<String, dynamic> beacon = {"isActive": isActive};
    documentReference.set(beacon, SetOptions(merge: true)).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text(
            'Cập nhật trạng thái thành công',
          )));
    }).onError((error, stackTrace) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text('Cập nhật thất bại'))));
  }

  Future<int> getCurrentMax() {
    return firestoreInstance
        .collection("Beacon")
        .orderBy('beacon_id', descending: true)
        .limit(1)
        .get()
        .then((value) async {
      return value.docs.first.data()['beacon_id'];
    });
  }

  createBeacon() async {
    DocumentReference documentReference =
        firestoreInstance.collection("Beacon").doc();
    int currentId = await getCurrentMax();

    //Map
    Map<String, dynamic> beacon = {
      "beacon_id": currentId + 1,
      "map_id": widget.floorNumber,
      "x": x,
      "y": y,
      "mac_address": mac_address,
      "rssi_at_1m": rssi_at_1m,
      "isActive": true,
    };

    documentReference.set(beacon).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text('Thêm beacon thành công')));
    }).onError((error, stackTrace) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text('Thêm thất bại'))));
  }

  updateBeacon(beacon_id, xnew, ynew, mac_adressnew, rssi_at_1mnew) async {
    final documentReference = await firestoreInstance
        .collection("Beacon")
        .where('beacon_id', isEqualTo: beacon_id)
        .get()
        .then((value) {
      return firestoreInstance.collection("Beacon").doc(value.docs.first.id);
    });
    Map<String, dynamic> location = {
      "beacon_id": beacon_id,
      "map_id": widget.floorNumber,
      "x": xnew,
      "y": ynew,
      "mac_address": mac_adressnew,
      "rssi_at_1m": rssi_at_1mnew,
    };
    documentReference.set(location, SetOptions(merge: true)).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text('Cập nhật beacon thành công')));
    }).onError((error, stackTrace) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text('Cập nhật thất bại'))));
  }

  deleteBeacon(beacon_id) async {
    final documentReference = await firestoreInstance
        .collection("Beacon")
        .where('beacon_id', isEqualTo: beacon_id)
        .get()
        .then((value) {
      return firestoreInstance.collection("Beacon").doc(value.docs.first.id);
    });

    documentReference.delete().whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text('Xóa beacon thành công')));
    }).onError((error, stackTrace) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text('Xóa thất bại'))));
  }

  void showUpdateDialog(int beacon_id, int currentX, int currentY,
      String mac_address, int rssi_at_1m) {
    x = currentX;
    y = currentY;
    this.mac_address = mac_address;
    this.rssi_at_1m = rssi_at_1m;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Cập nhật beacon"),
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
                TextFormField(
                  initialValue: mac_address.toString(),
                  decoration: InputDecoration(hintText: "Nhập địa chỉ Mac: "),
                  onChanged: (String value) {
                    if (value != "") this.mac_address = value;
                  },
                ),
                TextFormField(
                  initialValue: rssi_at_1m.toString(),
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "Nhập giá trị RSSI tại 1m: "),
                  onChanged: (String value) {
                    if (value != "") this.rssi_at_1m = int.parse(value);
                  },
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    updateBeacon(
                        beacon_id, x, y, this.mac_address, this.rssi_at_1m);
                    Navigator.of(context).pop();
                  },
                  child: Text("Cập nhật"))
            ],
          );
        });
  }

  void showDeleteDialog(int beacon_id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text("Xóa beacon"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Bạn chắc chắn muốn xóa beacon số $beacon_id này chứ"),
            ]),
            actions: <Widget>[
              ElevatedButton(
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.redAccent,
                  // ),
                  onPressed: () {
                    deleteBeacon(beacon_id);
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
            "Danh sách beacon tầng ${widget.floorNumber == 1 ? "trệt" : widget.floorNumber - 1}"),
        actions: [logoutButton(context)],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  title: Text("Thêm beacon"),
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
                      TextField(
                        decoration:
                            InputDecoration(hintText: "Nhập địa chỉ Mac: "),
                        onChanged: (String value) {
                          if (value != "") this.mac_address = value;
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: "Nhập giá trị RSSI tại 1m: "),
                        onChanged: (String value) {
                          if (value != "-" && value != "")
                            this.rssi_at_1m = int.parse(value);
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          createBeacon();
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
              .collection("Beacon")
              .where('map_id', isEqualTo: widget.floorNumber)
              .orderBy('beacon_id')
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
                            showDeleteDialog(documentSnapshot["beacon_id"]);
                          },
                          key: Key(documentSnapshot["beacon_id"].toString()),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: InkWell(
                              onTap: () {
                                showUpdateDialog(
                                    documentSnapshot["beacon_id"],
                                    documentSnapshot["x"],
                                    documentSnapshot["y"],
                                    documentSnapshot["mac_address"],
                                    documentSnapshot["rssi_at_1m"]);
                              },
                              child: ListTile(
                                  leading: CircleAvatar(
                                      child: Text(
                                          '#${(documentSnapshot["beacon_id"])}')),
                                  title: Text("X=" +
                                      documentSnapshot["x"].toString() +
                                      " Y=" +
                                      documentSnapshot["y"].toString()),
                                  subtitle: Text(
                                      'MAC: ${documentSnapshot["mac_address"]}\nRSSI 1m: ${documentSnapshot['rssi_at_1m']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch(
                                        value: documentSnapshot["isActive"],
                                        onChanged: (bool value) {
                                          // This is called when the user toggles the switch.
                                          setState(() {
                                            updateStatus(
                                                documentSnapshot["beacon_id"],
                                                value);
                                          });
                                        },
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            showDeleteDialog(
                                                documentSnapshot["beacon_id"]);
                                          }),
                                    ],
                                  )),
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
