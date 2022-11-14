import 'dart:convert';

import 'package:floorplans/element/rectelement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SearchRoom extends SearchDelegate {
  Future<List<String?>> getData() async {
    List<String?> name=[];
    final String response = await rootBundle.loadString('assets/testjson.json');
    final Map<String, dynamic> database = await json.decode(response);
    List<dynamic> data = database["children"][0]["children"];

    for (dynamic i in data) {
      if (i["type"] == "rect") {
        final RectElement d = RectElement.fromJson(i);
        name.add(d.roomName);
        // print(d.roomName);
      }
    }
    return name;
  }

  List listname=[];
  void convertFutureListToList() async {
    Future<List> _futureOfList = getData() as Future<List>;
    listname = await _futureOfList ;
    print(listname);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var i in listname) {
      if (i.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(i);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result,style: TextStyle(color: Colors.green),),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    convertFutureListToList();
    List<String> matchQuery = [];
    for (var i in listname) {
      if (i.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(i);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result,style: TextStyle(color: Colors.blue),),
        );
      },
    );
  }
}