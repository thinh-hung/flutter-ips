import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:matrix2d/matrix2d.dart';

import 'deskelement.dart';

class Dijkstra {

  Matrix2d c = Matrix2d();
  List<DeskElement> positionList = [];
  List<List<double>> adj = [];
  void addEdge(adj, int dinh1, int dinh2, double dodai) {
    adj[dinh1][dinh2] = dodai;
  }

/**
* Trong nay, cac dinh khong co canh noi voi nhau se co khoang cach la -1
*/
  // List dijkstra(List<List<double>> graph, int s) {
  //   List<double> dist = List<double>.filled(graph.length, 0, growable: true);
  //
  //   for (int i = 0; i < graph.length; i++) {
  //     dist[i] = double.infinity;
  //   }
  //   dist[s] = 0;
  //   List<int> visit = List<int>.filled(graph.length, 0, growable: true);
  //   for (int i = 0; i < graph.length; i++) {
  //     int v = closestVertice(graph[s], visit);
  //     for (int j = 0; j < graph[v].length; j++) {
  //       if (graph[v][j] != -1) {
  //         // neu co canh noi giua v va j
  //         double currentDist = dist[v] + graph[v][j];
  //         if (currentDist < dist[j]) {
  //           dist[j] = currentDist;
  //         }
  //       }
  //     }
  //   }
  //   return dist; // in ra la do cai nay
  // }
  void dijkstra(List<List<double>> graph,int start, int finsih){
    List<int> back=  List<int>.filled(graph.length, -1, growable: true);//luu dinh cha
    List<double> weight = List<double>.filled(graph.length, double.infinity, growable: true);// luu trong so
    List<int> mark= List<int>.filled(graph.length, 0, growable: true);//danh dau dinh
    print("----------------------");
    int connect;
    int start1=start;
    back[start] = 0;
    weight[start] = 0.0;
    do{
      connect =-1;
      double min = double.infinity;
      for(int j=0;j<graph.length;j++){
        if(mark[j]==0){
          if(graph[start][j] != -1 && weight[j]>weight[start]+graph[start][j]){
            weight[j] = weight[start]+graph[start][j];
            back[j]=start;
          }
          if(min > weight[j]){
            min = weight[j];
            connect=j;
          }
        }
      }
      start= connect;
      mark[start]=1;
    }while(connect !=1 && start!=finsih);
    print("trong so: "+weight[finsih].toString());
    print("duong đi: ");
    printPath(start1, finsih, back);

  }
  void printPath(int start,int finish,List<int> back){
    if(start != finish)
      {
        printPath(start, back[finish], back);
        print(back[finish].toString()+"->"+finish.toString());
      }
  }

  double distance(int a, int b){
    DeskElement A= positionList [a];
    DeskElement B= positionList [b];

    for(int i=0;i<positionList .length;i++){
      if(int.parse(positionList[i].getID()) == a){
         A = positionList [i];

      }
      if(int.parse(positionList[i].getID()) == b){
         B = positionList [i];

      }
    }
    double x = (B.getX()-A.getX())*(B.getX()-A.getX());
    double y = (B.getY()-A.getY())*(B.getY()-A.getY());
    return double.parse(sqrt(x+y).toStringAsFixed(2));
  }


  Future<void> dijkstraCaculate() async {
    int positionLength = await getDeskLength();
    // for test purpose
    // positionLength = 4;
    initAdj(adj, positionLength);


    addEdge(adj, 1, 2, distance(2, 1));
    addEdge(adj, 1, 2, distance(2, 1));

    addEdge(adj, 1, 3, distance(3, 1));
    addEdge(adj, 3, 1, distance(3, 1));

    addEdge(adj, 1, 30, distance(30, 1));
    addEdge(adj, 30, 1, distance(30, 1));

    addEdge(adj, 1, 29, distance(29, 1));
    addEdge(adj, 29, 1, distance(29, 1));

    addEdge(adj, 1, 4, distance(4, 1));
    addEdge(adj, 4, 1, distance(4, 1));

    addEdge(adj, 1, 5, distance(5, 1));
    addEdge(adj, 5, 1, distance(5, 1));

    addEdge(adj, 1, 25, distance(25, 1));
    addEdge(adj, 25, 1, distance(25, 1));

    addEdge(adj, 2, 3, distance(3, 2));
    addEdge(adj, 3, 2, distance(3, 2));

    addEdge(adj, 2, 30, distance(30, 2));
    addEdge(adj, 30, 2, distance(30, 2));

    addEdge(adj, 2, 29, distance(29, 2));
    addEdge(adj, 29, 2, distance(29, 2));

    addEdge(adj, 2, 4, distance(4, 2));
    addEdge(adj, 4, 2, distance(4, 2));

    addEdge(adj, 2, 5, distance(5, 2));
    addEdge(adj, 5, 2, distance(5, 2));

    addEdge(adj, 3, 30, distance(30, 3));
    addEdge(adj, 30, 3, distance(30, 3));

    addEdge(adj, 3, 29, distance(29, 3));
    addEdge(adj, 29, 3, distance(29, 3));

    addEdge(adj, 3, 4, distance(4, 3));
    addEdge(adj, 4, 3, distance(4, 3));

    addEdge(adj, 4, 30, distance(30, 4));
    addEdge(adj, 30, 4, distance(30, 4));

    addEdge(adj, 4, 29, distance(29, 4));
    addEdge(adj, 29, 4, distance(29, 4));

    addEdge(adj, 4, 5, distance(5, 4));
    addEdge(adj, 5, 4, distance(5, 4));




    dijkstra(adj,1, 5); // tu dinh so 2 di den tat ca
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
    positionList  = desk;
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
