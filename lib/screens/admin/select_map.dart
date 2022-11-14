import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/Drawer.dart';
import 'package:floorplans/screens/admin/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SelectMapScreen extends StatefulWidget {
  const SelectMapScreen({Key? key}) : super(key: key);

  @override
  State<SelectMapScreen> createState() => _SelectMapScreenState();
}

class _SelectMapScreenState extends State<SelectMapScreen> {
  @override
  Widget build(BuildContext context) {
    final maps = FirebaseFirestore.instance.collection('map').snapshots();

    return Scaffold(
        appBar: AppBar(
          title: Text("Chọn bản đồ muốn chỉnh sửa"),
        ),
        drawer: drawermenu(),
        body: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: maps,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Container(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: snapshot.data!.docs.map((document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return InkWell(
                              child: box(
                                  data['map_name'], Colors.deepPurpleAccent),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminMapScreen(
                                          floorNumber: data['map_id']),
                                    ));
                              },
                            );
                          }).toList(),
                        ));
                  },
                )
              ],
            )));
  }

  Widget box(String title, Color backgroundcolor) {
    return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: 120,
        color: backgroundcolor,
        alignment: Alignment.center,
        child:
            Text(title, style: TextStyle(color: Colors.white, fontSize: 20)));
  }
}
// return ListView(
//                       children:
//                           snapshot.data!.docs.map((DocumentSnapshot document) {
//                         Map<String, dynamic> data =
//                             document.data()! as Map<String, dynamic>;
//                         return ListTile(
//                           title: Text(data['map_name']),
//                         );
//                       }).toList(),
//                     );