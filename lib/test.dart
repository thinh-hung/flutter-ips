import 'package:floorplans/drawer.dart';
import 'package:flutter/material.dart';

class Taodientich extends StatefulWidget {
  const Taodientich({Key? key}) : super(key: key);

  @override
  State<Taodientich> createState() => _TaodientichState();
}

class _TaodientichState extends State<Taodientich> {

  TextEditingController x=TextEditingController();
  TextEditingController y=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tạo bản đồ tòa nhà"),
      ),
      drawer: drawermenu(),
      body: Container(
        child: Column(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width*0.9,
                height: MediaQuery.of(context).size.height/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      controller: x,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nhập chiều rộng x tòa nhà"
                      ),
                    ),
                    TextField(
                      controller: y,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nhập chiều dài y tòa nhà"
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Dientich {
  Dientich(this.x, this.y);
  final int x;
  final int y;
}