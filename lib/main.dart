import 'package:floorplans/floorplan.dart';
import 'package:floorplans/nearbyscreen.dart';
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

class MyHomePage extends StatefulWidget {
  final String json;

  const MyHomePage({required this.json, Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Floorplan(jsonFloorplan: widget.json),
      const NearbyScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Ban Do Tang tren Khoa"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: "Floorplan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: "Beacon",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
