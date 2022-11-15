import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/bledata.dart';
import 'package:floorplans/model/Path.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:matrix2d/matrix2d.dart';

import '../model/LocationModel.dart';

class Dijkstra {
  Matrix2d c = Matrix2d();
  double totalPathValue = 0.0;
  List<Location> positionList = [];
  List<TablePath> pathList = [];

  List<Location> wayPoint = [];
  List<String> floorLisst = ['assets/floorplan.json', 'assets/floor2.json'];
  var bleController = Get.put(BLEResult());
  List<List<double>> adj = [];
  late double x, y;

  late final listLocationS;
  late final pathS;

  void addEdge(adj, int dinh1, int dinh2, double dodai) {
    adj[dinh1][dinh2] = dodai;
  }

  //láy danh sách đih đường đi
  List<Location> getWayPoint() {
    return this.wayPoint;
  }

  //lấy đọ dài đường thằng
  double getTotalPathValue() {
    return totalPathValue;
  }

  void dijkstra(List<List<double>> graph, int start, int finsih) {
    List<int> back =
        List<int>.filled(graph.length, -1, growable: true); //luu dinh cha
    List<double> weight = List<double>.filled(graph.length, double.infinity,
        growable: true); // luu trong so
    List<int> mark =
        List<int>.filled(graph.length, 0, growable: true); //danh dau dinh
    int connect;
    int start1 = start;
    back[start] = 0;
    weight[start] = 0;
    do {
      connect = -1;
      double min = double.infinity;
      for (int j = 0; j < graph.length; j++) {
        if (mark[j] == 0) {
          if (graph[start][j] != -1 &&
              weight[j] > weight[start] + graph[start][j]) {
            weight[j] = weight[start] + graph[start][j];
            back[j] = start;
          }
          if (min > weight[j]) {
            min = weight[j];
            connect = j;
          }
        }
      }
      start = connect;
      mark[start] = 1;
    } while (connect != -1 && start != finsih);
    totalPathValue = weight[finsih];

    printPath(start1, finsih, back);
    for (int i = 0; i < positionList.length; i++) {
      if (positionList[i].getid() == finsih) {
        wayPoint.add(positionList[i]);
      }
    }
  }

  void printPath(int start, int finish, List<int> back) {
    wayPoint.clear();
    if (start != finish) {
      printPath(start, back[finish], back);
      // print(back[finish].toString()+"->"+finish.toString());
      for (int i = 0; i < positionList.length; i++) {
        if (positionList[i].getid() == back[finish]) {
          wayPoint.add(positionList[i]);
        }
      }
    }
  }

  double distance(int a, int b) {
    Location A = positionList[0];
    Location B = positionList[1];

    for (int i = 0; i < positionList.length; i++) {
      if (positionList[i].getid() == a) {
        A = positionList[i];
      }
      if (positionList[i].getid() == b) {
        B = positionList[i];
      }
    }
    int X = (B.x - A.x) * (B.x - A.x);
    int Y = (B.y - A.y) * (B.y - A.y);
    return double.parse(sqrt(x + y).toStringAsFixed(2));
  }

  void resetGraph() {
    this.adj.clear();
  }

  // lấy bảng Location trong Databaase
  Future<List<dynamic>> getListLocation() async {
    var snapshot =
        (await FirebaseFirestore.instance.collection('Location').get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  // lấy bảng Path trong Databaase
  Future<List<dynamic>> getListPath() async {
    var snapshot = (await FirebaseFirestore.instance.collection('Path').get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    return documents;
  }

  Future<void> dijkstraCaculate(
      int currentX, int currentY, int floorNumber, int finish) async {
    // int positionLength = await getDeskLengthONha();

    //goi ham lấy Location database
    listLocationS = getListLocation();
    print("---------------------------------------------------");
    await listLocationS.then((value) {
      for (int i = 0; i < value.length; i++) {
        final Location d = Location.fromJson(value[i]); // Parse data
        positionList.add(d);
      }
    });
    //goi ham lấy path database
    pathS = getListPath();
    print("---------------------------------------------------");
    await pathS.then((value) {
      for (int i = 0; i < value.length; i++) {
        final TablePath d = TablePath.fromJson(value[i]); // Parse data
        pathList.add(d);
      }
    });
    initAdj(adj, positionList.length);

    //thêm đường đi cho ma tran
    for (int i = 0; i < pathList.length; i++) {
      addEdge(adj, pathList[i].startLocation, pathList[i].endLocation,
          distance(pathList[i].startLocation, pathList[i].endLocation));
      addEdge(adj, pathList[i].endLocation, pathList[i].startLocation,
          distance(pathList[i].startLocation, pathList[i].endLocation));
    }

    for (int i = 0; i < positionList.length; i++) {
      if (positionList[i].id == 0) {
        positionList[i].x = currentX;
        positionList[i].y = currentY;
        // print("X0: "+positionList[i].x.toString());
        // print("Y0: "+positionList[i].y.toString());
      }
    }
    double min = 99999;
    int vitri = 0;
    if (floorNumber == 0) {
      for (int i = 1; i <= 35; i++) {
        if (min > distance(i, 0)) {
          min = distance(i, 0);
          vitri = i;
        }
      }
    } else if (floorNumber == 1) {
      for (int i = 35; i <= 72; i++) {
        if (min > distance(i, 0)) {
          min = distance(i, 0);
          vitri = i;
        }
      }
    }
    //print(vitri);
    addEdge(adj, 0, vitri, min);
    addEdge(adj, vitri, 0, min);

    // khac so voi minmax
    for (int i = 0; i < positionList.length; i++) {
      if (positionList[i].id == 0) {
        positionList[i].x = currentX;
        positionList[i].y = currentY;
        print("X0: " + positionList[i].x.toString());
        print("Y0: " + positionList[i].y.toString());
      }
    }

    dijkstra(adj, 0, finish);
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
