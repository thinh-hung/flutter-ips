import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:matrix2d/matrix2d.dart';

import 'deskelement.dart';

class Dijkstra {
  Matrix2d c = Matrix2d();
  double totalPathValue = 0.0;
  List<DeskElement> positionList = [];
  List<DeskElement> wayPoint = [];
  List<String> floorLisst = ['assets/floorplan.json', 'assets/floor2.json'];
  List<List<double>> adj = [];
  late double x, y;
  void addEdge(adj, int dinh1, int dinh2, double dodai) {
    adj[dinh1][dinh2] = dodai;
  }

  //láy danh sách đih đường đi
  List<DeskElement> getWayPoint() {
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
    print("----------------------");
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
    print("trong so: " + weight[finsih].toString());
    print("duong đi: ");
    printPath(start1, finsih, back);
    for (int i = 0; i < positionList.length; i++) {
      if (positionList[i].getID() == finsih) {
        wayPoint.add(positionList[i]);
      }
    }
    print("len: " + wayPoint.length.toString());
    for (int i = 0; i < wayPoint.length; i++) {
      print(wayPoint[i].deskId.toString());
    }
    print("++++++++++++++++++++++++++++++++S+++");
  }

  void printPath(int start, int finish, List<int> back) {
    wayPoint.clear();
    if (start != finish) {
      printPath(start, back[finish], back);
      // print(back[finish].toString()+"->"+finish.toString());
      for (int i = 0; i < positionList.length; i++) {
        if (positionList[i].getID() == back[finish]) {
          wayPoint.add(positionList[i]);
        }
      }
    }
  }

  double distance(int a, int b) {
    DeskElement A = positionList[0];
    DeskElement B = positionList[1];

    for (int i = 0; i < positionList.length; i++) {
      if (positionList[i].getID() == a) {
        A = positionList[i];
      }
      if (positionList[i].getID() == b) {
        B = positionList[i];
      }
    }
    double x = (B.getX() - A.getX()) * (B.getX() - A.getX());
    double y = (B.getY() - A.getY()) * (B.getY() - A.getY());
    return double.parse(sqrt(x + y).toStringAsFixed(2));
  }

  Future<void> dijkstraCaculate() async {
    int positionLength = await getDeskLength();
    print("..........................................................");
    print(positionLength);

    // for test purpose
    // positionLength = 4;
    initAdj(adj, positionLength);
    // de search nó

    addEdge(adj, 1, 2, distance(2, 1));
    addEdge(adj, 1, 2, distance(2, 1));

    addEdge(adj, 1, 3, distance(3, 1));
    addEdge(adj, 3, 1, distance(3, 1));

    addEdge(adj, 1, 30, distance(30, 1));
    addEdge(adj, 30, 1, distance(30, 1));

    addEdge(adj, 1, 29, distance(29, 1));
    addEdge(adj, 29, 1, distance(29, 1));

    addEdge(adj, 1, 32, distance(32, 1));
    addEdge(adj, 32, 1, distance(32, 1));

    addEdge(adj, 1, 33, distance(33, 1));
    addEdge(adj, 33, 1, distance(33, 1));

    addEdge(adj, 1, 34, distance(34, 1));
    addEdge(adj, 34, 1, distance(34, 1));

    addEdge(adj, 1, 4, distance(4, 1));
    addEdge(adj, 4, 1, distance(4, 1));

    addEdge(adj, 1, 5, distance(5, 1));
    addEdge(adj, 5, 1, distance(5, 1));

    addEdge(adj, 2, 3, distance(3, 2));
    addEdge(adj, 3, 2, distance(3, 2));

    addEdge(adj, 2, 30, distance(30, 2));
    addEdge(adj, 30, 2, distance(30, 2));

    addEdge(adj, 2, 29, distance(29, 2));
    addEdge(adj, 29, 2, distance(29, 2));

    addEdge(adj, 2, 32, distance(32, 2));
    addEdge(adj, 32, 2, distance(32, 2));

    addEdge(adj, 2, 33, distance(33, 2));
    addEdge(adj, 33, 2, distance(33, 2));

    addEdge(adj, 2, 34, distance(34, 2));
    addEdge(adj, 34, 2, distance(34, 2));

    addEdge(adj, 2, 4, distance(4, 2));
    addEdge(adj, 4, 2, distance(4, 2));

    addEdge(adj, 2, 5, distance(5, 2));
    addEdge(adj, 5, 2, distance(5, 2));

    addEdge(adj, 3, 30, distance(30, 3));
    addEdge(adj, 30, 3, distance(30, 3));

    addEdge(adj, 3, 29, distance(29, 3));
    addEdge(adj, 29, 3, distance(29, 3));

    addEdge(adj, 3, 32, distance(32, 3));
    addEdge(adj, 32, 3, distance(32, 3));

    addEdge(adj, 3, 33, distance(33, 3));
    addEdge(adj, 33, 3, distance(33, 3));

    addEdge(adj, 3, 34, distance(34, 3));
    addEdge(adj, 34, 3, distance(34, 3));

    addEdge(adj, 3, 4, distance(4, 3));
    addEdge(adj, 4, 3, distance(4, 3));

    addEdge(adj, 4, 29, distance(29, 4));
    addEdge(adj, 29, 4, distance(29, 4));

    addEdge(adj, 4, 32, distance(32, 4));
    addEdge(adj, 32, 4, distance(32, 4));

    addEdge(adj, 4, 34, distance(34, 4));
    addEdge(adj, 34, 4, distance(34, 4));

    addEdge(adj, 4, 5, distance(5, 4));
    addEdge(adj, 5, 4, distance(5, 4));

    addEdge(adj, 5, 6, distance(6, 5));
    addEdge(adj, 6, 5, distance(6, 5));

    addEdge(adj, 5, 30, distance(30, 5));
    addEdge(adj, 30, 5, distance(30, 5));

    addEdge(adj, 5, 32, distance(32, 5));
    addEdge(adj, 32, 5, distance(32, 5));

    addEdge(adj, 5, 34, distance(34, 5));
    addEdge(adj, 34, 5, distance(34, 5));

    addEdge(adj, 6, 7, distance(7, 6));
    addEdge(adj, 7, 6, distance(7, 6));

    addEdge(adj, 7, 8, distance(8, 7));
    addEdge(adj, 8, 7, distance(8, 7));

    addEdge(adj, 8, 14, distance(14, 8));
    addEdge(adj, 14, 8, distance(14, 8));

    addEdge(adj, 8, 9, distance(9, 8));
    addEdge(adj, 9, 8, distance(9, 8));

    addEdge(adj, 9, 10, distance(10, 9));
    addEdge(adj, 10, 9, distance(10, 9));

    addEdge(adj, 10, 11, distance(11, 10));
    addEdge(adj, 11, 10, distance(11, 10));

    addEdge(adj, 11, 12, distance(12, 11));
    addEdge(adj, 12, 11, distance(12, 11));

    addEdge(adj, 12, 13, distance(13, 12));
    addEdge(adj, 13, 12, distance(13, 12));

    addEdge(adj, 14, 15, distance(15, 14));
    addEdge(adj, 15, 14, distance(15, 14));

    addEdge(adj, 15, 16, distance(16, 15));
    addEdge(adj, 16, 15, distance(16, 15));

    addEdge(adj, 16, 17, distance(17, 16));
    addEdge(adj, 17, 16, distance(17, 16));

    addEdge(adj, 17, 18, distance(18, 17));
    addEdge(adj, 18, 17, distance(18, 17));

    addEdge(adj, 17, 23, distance(23, 17));
    addEdge(adj, 23, 17, distance(23, 17));

    addEdge(adj, 18, 19, distance(19, 18));
    addEdge(adj, 19, 18, distance(19, 18));

    addEdge(adj, 19, 20, distance(20, 19));
    addEdge(adj, 20, 19, distance(20, 19));

    addEdge(adj, 20, 21, distance(21, 20));
    addEdge(adj, 21, 20, distance(21, 20));

    addEdge(adj, 20, 12, distance(12, 20));
    addEdge(adj, 12, 20, distance(12, 20));

    addEdge(adj, 20, 15, distance(15, 20));
    addEdge(adj, 15, 20, distance(15, 20));

    addEdge(adj, 21, 22, distance(22, 21));
    addEdge(adj, 22, 21, distance(22, 21));

    addEdge(adj, 23, 24, distance(24, 23));
    addEdge(adj, 24, 23, distance(24, 23));

    addEdge(adj, 24, 25, distance(25, 24));
    addEdge(adj, 25, 24, distance(25, 24));

    addEdge(adj, 25, 32, distance(32, 25));
    addEdge(adj, 32, 25, distance(32, 25));

    addEdge(adj, 32, 26, distance(26, 32));
    addEdge(adj, 26, 32, distance(26, 32));

    addEdge(adj, 32, 34, distance(34, 32));
    addEdge(adj, 34, 32, distance(34, 32));

    addEdge(adj, 26, 28, distance(28, 26));
    addEdge(adj, 28, 26, distance(28, 26));

    addEdge(adj, 26, 27, distance(27, 26));
    addEdge(adj, 27, 26, distance(27, 26));

    addEdge(adj, 27, 31, distance(31, 27));
    addEdge(adj, 31, 27, distance(31, 27));

    addEdge(adj, 28, 33, distance(33, 28));
    addEdge(adj, 33, 28, distance(33, 28));

    addEdge(adj, 33, 29, distance(29, 33));
    addEdge(adj, 29, 33, distance(29, 33));

    addEdge(adj, 29, 30, distance(30, 29));
    addEdge(adj, 30, 29, distance(30, 29));

    addEdge(adj, 29, 34, distance(34, 29));
    addEdge(adj, 34, 29, distance(34, 29));

    addEdge(adj, 30, 34, distance(34, 30));
    addEdge(adj, 34, 30, distance(34, 30));

    //tầng trên
    addEdge(adj, 35, 36, distance(36, 35));
    addEdge(adj, 36, 35, distance(36, 35));

    addEdge(adj, 35, 37, distance(37, 35));
    addEdge(adj, 37, 35, distance(37, 35));

    addEdge(adj, 35, 38, distance(38, 35));
    addEdge(adj, 38, 35, distance(38, 35));

    addEdge(adj, 35, 55, distance(55, 35));
    addEdge(adj, 55, 35, distance(55, 35));

    addEdge(adj, 36, 38, distance(38, 36));
    addEdge(adj, 38, 36, distance(38, 36));

    addEdge(adj, 36, 37, distance(37, 36));
    addEdge(adj, 37, 36, distance(37, 36));

    addEdge(adj, 36, 55, distance(55, 36));
    addEdge(adj, 55, 36, distance(55, 36));

    addEdge(adj, 37, 38, distance(38, 37));
    addEdge(adj, 38, 37, distance(38, 37));

    addEdge(adj, 37, 55, distance(55, 37));
    addEdge(adj, 55, 37, distance(55, 37));

    addEdge(adj, 38, 55, distance(55, 38));
    addEdge(adj, 55, 38, distance(55, 38));

    addEdge(adj, 55, 39, distance(39, 55));
    addEdge(adj, 39, 55, distance(39, 55));

    addEdge(adj, 39, 40, distance(40, 39));
    addEdge(adj, 40, 39, distance(40, 39));

    addEdge(adj, 39, 68, distance(68, 39));
    addEdge(adj, 68, 39, distance(68, 39));

    addEdge(adj, 40, 41, distance(41, 40));
    addEdge(adj, 41, 40, distance(41, 40));

    addEdge(adj, 41, 42, distance(42, 41));
    addEdge(adj, 42, 41, distance(42, 41));

    addEdge(adj, 41, 46, distance(46, 41));
    addEdge(adj, 46, 41, distance(46, 41));

    addEdge(adj, 41, 50, distance(50, 41));
    addEdge(adj, 50, 41, distance(50, 41));

    addEdge(adj, 42, 43, distance(43, 42));
    addEdge(adj, 43, 42, distance(43, 42));

    addEdge(adj, 43, 44, distance(44, 43));
    addEdge(adj, 44, 43, distance(44, 43));

    addEdge(adj, 44, 45, distance(45, 44));
    addEdge(adj, 45, 44, distance(45, 44));

    addEdge(adj, 46, 47, distance(47, 46));
    addEdge(adj, 47, 46, distance(47, 46));

    addEdge(adj, 47, 48, distance(48, 47));
    addEdge(adj, 48, 47, distance(48, 47));

    addEdge(adj, 48, 49, distance(49, 48));
    addEdge(adj, 49, 48, distance(49, 48));

    addEdge(adj, 50, 51, distance(51, 50));
    addEdge(adj, 51, 50, distance(51, 50));

    addEdge(adj, 51, 52, distance(52, 51));
    addEdge(adj, 52, 51, distance(52, 51));

    addEdge(adj, 52, 53, distance(53, 52));
    addEdge(adj, 53, 52, distance(53, 52));

    addEdge(adj, 53, 57, distance(57, 53));
    addEdge(adj, 57, 53, distance(57, 53));

    addEdge(adj, 53, 63, distance(63, 53));
    addEdge(adj, 63, 53, distance(63, 53));

    addEdge(adj, 53, 58, distance(58, 53));
    addEdge(adj, 58, 53, distance(58, 53));

    addEdge(adj, 53, 66, distance(66, 53));
    addEdge(adj, 66, 53, distance(66, 53));

    addEdge(adj, 66, 65, distance(65, 66));
    addEdge(adj, 65, 66, distance(65, 66));

    addEdge(adj, 66, 64, distance(64, 66));
    addEdge(adj, 64, 66, distance(64, 66));

    addEdge(adj, 66, 63, distance(63, 66));
    addEdge(adj, 63, 66, distance(63, 66));

    addEdge(adj, 66, 58, distance(58, 66));
    addEdge(adj, 58, 66, distance(58, 66));

    addEdge(adj, 66, 57, distance(57, 66));
    addEdge(adj, 57, 66, distance(57, 66));

    addEdge(adj, 66, 59, distance(59, 66));
    addEdge(adj, 59, 66, distance(59, 66));

    addEdge(adj, 66, 62, distance(62, 66));
    addEdge(adj, 62, 66, distance(62, 66));

    addEdge(adj, 62, 64, distance(64, 62));
    addEdge(adj, 64, 62, distance(64, 62));

    addEdge(adj, 62, 65, distance(65, 62));
    addEdge(adj, 65, 62, distance(65, 62));

    addEdge(adj, 62, 58, distance(58, 62));
    addEdge(adj, 58, 62, distance(58, 62));

    addEdge(adj, 62, 59, distance(59, 62));
    addEdge(adj, 59, 62, distance(59, 62));

    addEdge(adj, 57, 54, distance(54, 57));
    addEdge(adj, 54, 57, distance(54, 57));

    addEdge(adj, 57, 58, distance(58, 57));
    addEdge(adj, 58, 57, distance(58, 57));

    addEdge(adj, 54, 56, distance(56, 54));
    addEdge(adj, 56, 54, distance(56, 54));

    addEdge(adj, 58, 59, distance(59, 58));
    addEdge(adj, 59, 58, distance(59, 58));

    addEdge(adj, 59, 60, distance(60, 59));
    addEdge(adj, 60, 59, distance(60, 59));

    addEdge(adj, 60, 61, distance(61, 60));
    addEdge(adj, 61, 60, distance(61, 60));

    addEdge(adj, 63, 64, distance(64, 63));
    addEdge(adj, 64, 63, distance(64, 63));

    addEdge(adj, 64, 65, distance(65, 64));
    addEdge(adj, 65, 64, distance(65, 64));

    addEdge(adj, 65, 67, distance(67, 65));
    addEdge(adj, 67, 65, distance(67, 65));

    addEdge(adj, 67, 68, distance(68, 67));
    addEdge(adj, 68, 67, distance(68, 67));

    addEdge(adj, 67, 69, distance(69, 67));
    addEdge(adj, 69, 67, distance(69, 67));

    addEdge(adj, 69, 70, distance(70, 69));
    addEdge(adj, 70, 69, distance(70, 69));

    addEdge(adj, 69, 71, distance(71, 69));
    addEdge(adj, 71, 69, distance(71, 69));

    addEdge(adj, 70, 71, distance(71, 70));
    addEdge(adj, 71, 70, distance(71, 70));

    addEdge(adj, 71, 72, distance(72, 71));
    addEdge(adj, 72, 71, distance(72, 71));

    addEdge(adj, 72, 35, distance(35, 72));
    addEdge(adj, 35, 72, distance(35, 72));

    //cau thang 1
    addEdge(adj, 2, 35, 5);
    addEdge(adj, 35, 2, 5);
    //cau thang 2
    addEdge(adj, 30, 70, 5);
    addEdge(adj, 70, 30, 5);
    //cau thang 3
    addEdge(adj, 31, 62, 5);
    addEdge(adj, 62, 31, 5);
    //cau thang 4
    addEdge(adj, 6, 40, 5);
    addEdge(adj, 40, 6, 5);

    Timer.periodic(Duration(seconds: 2), (timer) {
      for (int i = 0; i < positionList.length; i++) {
        if (positionList[i].deskId == 0) {
          positionList[i].x += 0;
          positionList[i].y += 10;
          x = positionList[i].x;
          y = positionList[i].y;
          // print("X0: "+positionList[i].x.toString());
          // print("Y0: "+positionList[i].y.toString());
        }
      }
      // for(int i=0;i<positionList.length;i++){
      //   if(positionList[i].deskId == 0){
      //     print("start: "+positionList[i].deskId.toString()+"-"+positionList[i].x.toString()+"-"+positionList[i].y.toString());
      //   }
      // }
      double min = 99999;
      int vitri = 0;
      for (int i = 1; i <= 35; i++) {
        if (min > distance(i, 0)) {
          min = distance(i, 0);
          vitri = i;
        }
      }
      //print(vitri);
      addEdge(adj, 0, vitri, min);
      addEdge(adj, vitri, 0, min);
      dijkstra(adj, 0, 6);
    });
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
    for (int i = 0; i < floorLisst.length; i++) {
      final String response = await rootBundle.loadString(floorLisst[i]);
      final Map<String, dynamic> database = await json.decode(response);
      List<dynamic> data = database["children"][1]["children"];

      for (dynamic it in data) {
        if (it["type"] == "desk") {
          final DeskElement d = DeskElement.fromJson(it); // Parse data
          desk.add(d); // and organization to List
        }
      }
    }
    positionList = desk;

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
