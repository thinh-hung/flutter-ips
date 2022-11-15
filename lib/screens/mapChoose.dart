import 'package:floorplans/Drawer.dart';
import 'package:floorplans/main.dart';
import 'package:floorplans/model/MapModel.dart';
import 'package:flutter/material.dart';

class MapChooseScreen extends StatelessWidget {
  const MapChooseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map> lstOfMaps = [];
    lstOfMaps.add(Map(mapName: 'Map ở nhà'));
    lstOfMaps.add(Map(mapName: 'Tầng 01'));
    lstOfMaps.add(Map(mapName: 'Tầng trệt'));

    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("LIST MAP CIT")),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.location_on),)
          ],
        ),
        drawer: drawermenu(),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: ListView.builder(
              itemCount: lstOfMaps.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  if (lstOfMaps[index].mapName == 'Map ở nhà') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width*0.6,
                      height: 50,
                      child: Text(
                        lstOfMaps[index].mapName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19,color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.teal,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 2), // changes position of shadow
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(9.0),
            )));
  }
}
