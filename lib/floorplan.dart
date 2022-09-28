import 'dart:convert';
import 'dart:math';
import 'baseelement.dart';
import 'layerelement.dart';
import 'rectelement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'deskelement.dart';
import 'rootelement.dart';
import 'elementwithchildren.dart';

class Floorplan extends StatefulWidget {
  final String jsonFloorplan;
  const Floorplan({required this.jsonFloorplan, Key? key}) : super(key: key);

  @override
  State<Floorplan> createState() => _FloorplanState();
}

class _FloorplanState extends State<Floorplan> {
  late RootElement root;
  late TransformationController controller;

  void load(String jsonString) {
    final data = json.decode(jsonString);
    root = RootElement.fromJson(data);
  }

  @override
  void initState() {
    debugPrint(widget.jsonFloorplan);
    load(widget.jsonFloorplan);
    controller = TransformationController();
    super.initState();
  }

  Widget buildRectElement(BuildContext context, RectElement element) {
    return Positioned(
      top: element.y,
      left: element.x,
      child: Container(
        height: element.height,
        width: element.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: element.fill as Color,
            width: 2,
          ),
        ),
        child: Center(child: Text("${element.roomName}")),
        // color: element.fill,
      ),
    );
  }

  Widget buildDeskElement(BuildContext context, DeskElement element) {
    return Positioned(
      top: element.y - element.radius,
      left: element.x - element.radius,
      child: Container(
        height: element.radius * 2,
        width: element.radius * 2,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget buildElement(BuildContext context, BaseElement element) {
    switch (element.runtimeType) {
      case DeskElement:
        return buildDeskElement(context, element as DeskElement);

      case RectElement:
        return buildRectElement(context, element as RectElement);

      default:
        throw Exception('Invalid element type: ${element.runtimeType}');
    }
  }

  Widget buildLayer(BuildContext context, LayerElement layer, Rect size) {
    final elements = layer.children
        .map<Widget>((child) => buildElement(context, child))
        .toList();

    return SizedBox(
      height: size.bottom,
      width: size.right,
      child: Stack(
        children: elements,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = root.getExtent();

    final layers = root.layers
        .map<Widget>((layer) => buildLayer(context, layer, size))
        .toList();

    return InteractiveViewer(
      onInteractionStart: (details) {
        print("x: "+details.localFocalPoint.dx.toString());
        print("y: "+details.localFocalPoint.dy.toString());
      },
      transformationController: controller,
      maxScale: 300,
      constrained: false,
      child: Stack(
        children: layers,
      ),
    );
  }
}
