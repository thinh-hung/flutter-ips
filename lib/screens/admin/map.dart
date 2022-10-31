import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, dynamic> dataRoom = Map<String, dynamic>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int floorNumber = widget.floorNumber;

    print("-0-------------------------------0-");
    getDatabyFloorNumber(floorNumber);
    print(dataObjectMap);
    print(dataRoom);
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản trị bản đồ"),
      ),
      body: Stack(children: [
        Container(
          child: Center(child: Text('Bạn đang ở tầng ${floorNumber}')),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ElevatedButton(onPressed: () {}, child: Text("Tạo điểm phụ")),
            SizedBox(
              width: 30,
            ),
            ElevatedButton(onPressed: () {}, child: Text("Vẽ lối đi")),
            SizedBox(
              width: 30,
            ),
            ElevatedButton(onPressed: () {}, child: Text("Thêm beacon"))
          ]),
        ),
      ]),
    );
  }

  Future<void> getDatabyFloorNumber(int floorNumber) async {
    await FirebaseFirestore.instance
        .collection('Object Map')
        .where('map_id', isEqualTo: floorNumber)
        .get()
        .then(
          (value) => value.docs.map((e) {
            dataObjectMap = e.data() as Map<String, dynamic>;
          }),
        );

    await FirebaseFirestore.instance
        .collection('Room')
        .where('map_id', isEqualTo: floorNumber)
        .get()
        .then(
          (value) => value.docs.map((e) {
            dataRoom = e.data() as Map<String, dynamic>;
          }),
        );
  }
}
