import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/Drawer.dart';
import 'package:floorplans/function/utils.dart';
import 'package:floorplans/screens/admin/map.dart';
import 'package:floorplans/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../Drawer.dart';

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
          title: Center(child: Text("Danh sách tầng")),
          actions: [
            logoutButton(context),
          ],
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
                                  data['map_name'], Colors.teal),
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

//   Widget box(String title, Color backgroundcolor) {
//     return Container(
//         margin: EdgeInsets.all(10),
//         padding: EdgeInsets.symmetric(horizontal: 10),
//         width: 120,
//         color: backgroundcolor,
//         alignment: Alignment.center,
//         child:
//             Text(title, style: TextStyle(color: Colors.white, fontSize: 20)));
//   }
// }
  Widget box(String title, Color backgroundcolor) {
    return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width/3,
        // color: backgroundcolor,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: backgroundcolor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child:
        Text(title, style: TextStyle(color: Colors.white, fontSize: 20)));
  }
}