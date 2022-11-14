import 'package:floorplans/screens/admin/select_map.dart';
import 'package:floorplans/screens/mapChoose.dart';
import 'package:flutter/material.dart';

final List<String> listname = [
  "Home",
  "Edit",
];
final List<IconData> listicon = [
  Icons.gps_fixed,
  Icons.build,
];

final List<Widget> listclass=[
  MapChooseScreen(),
  SelectMapScreen(),
];

class Listnav extends StatelessWidget {
  final String namenav;
  final IconData iconnav;
  final Widget widgetnav;
  Listnav({required this.namenav, required this.iconnav, required this.widgetnav});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconnav, size: 20, color: Colors.black),
      title: Text(namenav, style: TextStyle(color: Colors.black, fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=> widgetnav),
        );
      },
    );
  }
}

class drawermenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.3,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.6,
                        child:  Image.asset('assets/images/logo.jpg'),
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
            Listnav(namenav: listname[i], iconnav: listicon[i], widgetnav: listclass[i]),
        ],
      ),
    );
  }
}