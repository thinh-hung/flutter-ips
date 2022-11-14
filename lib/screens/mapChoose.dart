import 'package:floorplans/main.dart';
import 'package:floorplans/model/MapModel.dart';
import 'package:flutter/material.dart';

class MapChooseScreen extends StatelessWidget {
  const MapChooseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map> lstOfMaps = [];
    lstOfMaps.add(Map(mapName: 'Map1'));

    lstOfMaps.add(Map(mapName: 'Map2'));
    lstOfMaps.add(Map(mapName: 'Map3'));

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Các bản đồ trong tòa nhà CIT",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: ListView.builder(
              itemCount: lstOfMaps.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  if (lstOfMaps[index].mapName=="Map1") {
                    print(index);
                    print("-------------------------");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp(keymap: index,)),
                    );
                  }else if (lstOfMaps[index].mapName=="Map2") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp(keymap: index,)),
                    );
                  }else if (lstOfMaps[index].mapName=="Map3") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp(keymap: index,)),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 100,
                      child: Text(
                        lstOfMaps[index].mapName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFe0f2f1),
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
