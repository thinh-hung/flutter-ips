import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:matrix2d/matrix2d.dart';

import 'deskelement.dart';

class Dijkstra {
  var s = [];
  var p = [];
  var d = [];
  Matrix2d c = Matrix2d();
  List<List<double>> adj = [];
  void addEdge(adj, int dinh1, int dinh2, double dodai) {
    adj[dinh1][dinh2] = dodai;
  }

/**
* Trong nay, cac dinh khong co canh noi voi nhau se co khoang cach la -1
*/
  List dijkstra(List<List<double>> graph, int s) {
    List<double> dist = List<double>.filled(graph.length, 0, growable: true);

    for (int i = 0; i < graph.length; i++) {
      dist[i] = double.infinity;
    }
    dist[s] = 0;
    List<int> visit = List<int>.filled(graph.length, 0, growable: true);
    for (int i = 0; i < graph.length; i++) {
      int v = closestVertice(graph[s], visit);
      for (int j = 0; j < graph[v].length; j++) {
        if (graph[v][j] != -1) {
          // neu co canh noi giua v va j
          double currentDist = dist[v] + graph[v][j];
          if (currentDist < dist[j]) {
            dist[j] = currentDist;
          }
        }
      }
    }
    return dist;
  }

  Future<void> dijkstraCaculate() async {
    int positionLength = await getDeskLength();
    // for test purpose
    positionLength = 4;
    initAdj(adj, positionLength);
    addEdge(adj, 0, 1, 5);
    addEdge(adj, 1, 0, 5);

    addEdge(adj, 1, 3, 2);
    addEdge(adj, 3, 1, 2);

    addEdge(adj, 3, 2, 6);
    addEdge(adj, 2, 3, 6);

    addEdge(adj, 2, 0, 8);
    addEdge(adj, 0, 2, 8);

    addEdge(adj, 1, 2, 9);
    addEdge(adj, 2, 1, 9);
    print(adj);

    print(dijkstra(adj, 2));
  }

// tao ma tran
  Future<void> initAdj(List<List<double>> list, int positionLength) async {
    // print(a);
    for (var i = 0; i < positionLength; i++) {
      List<double> arr = [];
      for (var j = 0; j < positionLength; j++) {
        arr.add(-1);
      }
      adj.add(arr);
    }
  }

// dem so luong diem
  Future<int> getDeskLength() async {
    List<DeskElement> desk = [];
    final String response =
        await rootBundle.loadString('assets/floorplan.json');
    final Map<String, dynamic> database = await json.decode(response);
    List<dynamic> data = database["children"][1]["children"];

    for (dynamic it in data) {
      if (it["type"] == "desk") {
        final DeskElement d = DeskElement.fromJson(it); // Parse data
        desk.add(d); // and organization to List
      }
    }
    return desk.length;
  }

/**
 * Chon ra dinh o gan s nhat va danh dau dinh do la da tham
 * */
  int closestVertice(List<double> adjacentVertices, List<int> visit) {
    int closest = -1;
    double minDist = double.infinity;
    for (int i = 0; i < adjacentVertices.length; i++) {
      if (visit[i] == 0 && adjacentVertices[i] < minDist) {
        closest = i;
        minDist = adjacentVertices[i];
      }
    }
    visit[closest] = 1;
    return closest;
  }
}
