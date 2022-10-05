import 'package:floorplans/floorplan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String?> _future;
  @override
  void initState() {
    _future = rootBundle.loadString('assets/floorplan.json');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Floorplans Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage(json: snapshot.data!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String json;

  const MyHomePage({required this.json, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ban Do Tang tren Khoa"),backgroundColor: Colors.green,),
      body: Column(
        children: [
          Expanded(
            child: Floorplan(jsonFloorplan: json),
          ),
        ],
      ),
    );
  }
}
