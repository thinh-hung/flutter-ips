import 'package:floorplans/main.dart';
import 'package:floorplans/screens/admin/select_map.dart';
import 'package:floorplans/screens/login.dart';
import 'package:floorplans/screens/mapChoose.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top),
        child: SizedBox(
          height: MediaQuery.of(context).padding.top,
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Image.asset('assets/images/logo.jpg'),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: Text(
                'Hệ thống định vị trong tòa nhà CIT\nsử dụng công nghệ Bluetooth\nnăng lượng thấp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Bắt đầu sử dụng",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.turn_right)
                    ],
                  )),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 650,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectMapScreen()),
                );
              },
              child: Text('Bạn là Admin ? Đăng nhập ngay'),
            )
          ],
        ),
      ),
    );
  }
}
