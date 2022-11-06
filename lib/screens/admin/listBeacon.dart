import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ListBeaconScreen extends StatefulWidget {
  final int floorNumber;
  const ListBeaconScreen({Key? key, required this.floorNumber})
      : super(key: key);

  @override
  State<ListBeaconScreen> createState() => _ListBeaconScreenState();
}

class _ListBeaconScreenState extends State<ListBeaconScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Danh sách beacon ở tầng ${widget.floorNumber}"),
        ),
        body: Container(
          child: Text(widget.floorNumber.toString()),
        ));
  }
}
