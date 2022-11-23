import 'package:floorplans/screens/admin/ListRoom.dart';
import 'package:floorplans/screens/admin/listBeacon.dart';
import 'package:floorplans/screens/admin/listLocation.dart';
import 'package:floorplans/screens/admin/listPath.dart';
import 'package:floorplans/screens/admin/select_map.dart';
import 'package:flutter/material.dart';

int floorNumbernav=1;

final List<String> listname = [
  "List floorplan",
  "List location",
  "List beacon",
  "List path",
  "List room",
];
final List<IconData> listicon = [
  Icons.map,
  Icons.location_on,
  Icons.bluetooth,
  Icons.linear_scale,
  Icons.door_back_door,
];



class Listnav extends StatelessWidget {
  final String namenav;
  final IconData iconnav;
  final Widget widgetnav;
  Listnav(
      {required this.namenav, required this.iconnav, required this.widgetnav});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconnav, size: 20, color: Colors.black),
      title: Text(namenav, style: TextStyle(color: Colors.black, fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widgetnav),
        );
      },
    );
  }
}

class draweradmin extends StatefulWidget {
  final int floorNumber;
  const draweradmin({Key? key, required this.floorNumber}) : super(key: key);

  @override
  State<draweradmin> createState() => _draweradminState();
}

class _draweradminState extends State<draweradmin> {

  @override
  Widget build(BuildContext context) {
    final List<Widget> listclass = [
      SelectMapScreen(),
      ListLocationScreen(floorNumber: widget.floorNumber,),
      ListBeaconScreen(floorNumber: widget.floorNumber,),
      ListPath(floorNumber: widget.floorNumber,),
      ListRoom(floorNumber: widget.floorNumber,),
    ];
    print(floorNumbernav);
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.3,
            child: DrawerHeader(
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   border: Border(
              //     bottom: BorderSide(
              //       color: Colors.grey,
              //       width: 1,
              //     )
              //   )
              // ),
              child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Image.asset('assets/images/logo.jpg'),
                      ),
                      SizedBox(height: 20),
                      Text('Hệ thống định vị tòa nhà',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text('Công nghệ Bluetooth năng lượng thấp',
                          style: TextStyle(color: Colors.black, fontSize: 15)),
                    ],
                  )),
            ),
          ),
          for (int i = 0; i < listname.length; i++)
            Listnav(
                namenav: listname[i],
                iconnav: listicon[i],
                widgetnav: listclass[i]),
        ],
      ),
    );
  }
}