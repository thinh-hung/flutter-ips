import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floorplans/element/rectelement.dart';
import 'package:floorplans/model/LocationModel.dart';
import 'package:floorplans/showResultSearch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'function/utils.dart';
import 'model/RoomModel.dart';

class SearchRoom extends SearchDelegate {
  static int idLocation = 0;
  static int getLocationId(int t) {
    if (t == 0) {
      return 0;
    }
    return idLocation;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    List<Map<String, dynamic>> roomWithID = [];

    var snapshot = (await FirebaseFirestore.instance.collection('Room').get());
    var documents = [];
    snapshot.docs.forEach((element) {
      var document = element.data();
      documents.add(document);
    });
    documents.forEach((element) {
      int id = element['location_id'] ?? -1;
      String name = "Phòng " + element['room_name'];
      if (id != -1) {
        roomWithID.add({"id": id, "name": name});
      }
    });
    return roomWithID;
  }

  List listname = [];
  void convertFutureListToList() async {
    Future<List> _futureOfList = getData() as Future<List>;
    listname = await _futureOfList;
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
          title: Text(
            result,
            style: TextStyle(color: Colors.green),
          ),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    convertFutureListToList();
    List<Map<String, dynamic>> matchQuery = [];
    for (var i in listname) {
      if (i['name'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add({"id": i['id'], "name": i['name']});
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return InkWell(
            onTap: () async {
              Map<String, dynamic> dataSearch =
                  await getDataResult(result['id']);
              close(context, result['id']);
              _navigateAndDisplaySelection(context, dataSearch);
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           ShowResultSearch(locationResult: result['id']),
              //     ));
              // Map<String, dynamic> dataSearch = await getDataResult(id);
            },
            child: ListTile(
              title: Text(
                result['name'],
                style: TextStyle(color: Colors.blue),
              ),
            ));
      },
    );
  }

  Future<Map<String, dynamic>> getDataResult(int id) async {
    Location location = await getLocation(id);
    Room room = await getRoomAreaByLocation_Id(location);
    Map<String, dynamic> dataSearch = {
      "location": location,
      "room": room,
    };
    return dataSearch;
  }

  Future<void> _navigateAndDisplaySelection(
      BuildContext context, Map<String, dynamic> dataSearch) async {
    // print("id $id");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShowResultSearch(locationResult: dataSearch)),
    );
    print(result);
    idLocation = result;
  }
}
