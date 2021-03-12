import 'dart:async';

import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:ambbook_driver/profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home1 extends StatelessWidget {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  final Geolocator geolocator = Geolocator();
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  GoogleMapController _controller;

  static const LatLng _center = const LatLng(13.115415, 77.6367932);
  //Location _location = Location();
  Position _currentPosition;
  Set<Marker> _markers = {};
  String Latitude, Longitude;
  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;

    CameraPosition(
        target: LatLng(double.parse(Latitude), double.parse(Longitude)),
        zoom: 11);

    _markers.add(Marker(
        markerId: MarkerId('user'),
        position: LatLng(
          double.parse(Latitude),
          double.parse(Longitude),
        )));
  }

  bool emergency = false;
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Colors.black,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
          ),
          drawer: Drawer(
              child: Container(
                  child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 50),
                curve: Curves.fastLinearToSlowEaseIn,
                child: Text(
                  "Ambbook".toString().toUpperCase(),
                  textScaleFactor: 1.7,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
              ),
              ListTile(
                title: Text(
                  "Profile",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profile()),
                  );
                },
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
              ),
            ],
          ))),
          body: SafeArea(
              child: StreamBuilder(
                  stream: firestoreInstance
                      .collection("hospital")
                      .doc("3LELjo7kyASwZFEwaL43oUAoTDq1")
                      .collection("ambulance")
                      .where("id", isEqualTo: firebaseUser.uid)
                      .snapshots(),
                  builder: (context1, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                            child: SpinKitFadingCircle(
                          color: Color(0xFFef7f1a),
                          duration: const Duration(milliseconds: 2000),
                        ));

                      default:
                        DocumentSnapshot ds = snapshot.data.documents[0];
                        print(ds.data());
                        Latitude = ds.data()["latitude"];
                        Longitude = ds.data()["longitude"];
                        emergency = ds.data()["emergency"];
                        return Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!emergency)
                                  (Container(
                                    child: Center(
                                        child: Text(
                                      "Looking for Users",
                                      textScaleFactor: 1.5,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    )),
                                  )),
                                SizedBox(
                                  height: 20,
                                ),
                                if (!emergency)
                                  (Container(
                                    child: Center(
                                        child: Text(
                                      "Please wait...",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300),
                                    )),
                                  )),
                                if (emergency)
                                  (Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: new BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),

                                            blurRadius: 6,
                                            offset: Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "User Details",
                                          textScaleFactor: 1.2,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          height: 300,
                                          child: GoogleMap(
                                            markers: _markers,
                                            onMapCreated: _onMapCreated,
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: _center,
                                              zoom: 11.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Table(children: [
                                          TableRow(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                                child: Text(
                                                  "Name",
                                                  textScaleFactor: 1,
                                                ),
                                              ),
                                              Text(ds.data()["user name"],
                                                  textScaleFactor: 1),
                                            ],
                                          ),
                                          TableRow(children: [
                                            SizedBox(
                                                height: 30,
                                                child: Text("phone")),
                                            Text(ds.data()["user phone"]),
                                          ]),
                                          TableRow(children: [
                                            SizedBox(
                                                height: 30,
                                                child: Text("Location")),
                                            Text(ds.data()["latitude"] +
                                                "," +
                                                ds.data()["longitude"]),
                                          ]),
                                        ])
                                      ],
                                    ),
                                  ))
                              ],
                            ));
                    }
                  }))),
    );
  }
}
