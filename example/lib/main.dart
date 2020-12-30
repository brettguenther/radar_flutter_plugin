import 'package:flutter/material.dart';
import 'dart:async';
import 'package:radar_flutter_plugin/radar_flutter_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setupRadar();
  }

  Future<void> setupRadar() async {
    // print("starting radar");
    // try {
    //   await RadarFlutterPlugin.initialize("<yourPublishableKey>");
    // } on PlatformException catch (e) {
    //   print(e.message);
    // }
    RadarFlutterPlugin.setLogLevel("DEBUG");
    RadarFlutterPlugin.setUserId("flutter-uuid");
    RadarFlutterPlugin.setDescription("Flutter Example User");
    String userString = await RadarFlutterPlugin.getUserId();
    print(userString);

    RadarFlutterPlugin.onClientLocation((result) {
      print(result);
    });
    RadarFlutterPlugin.onEvents((result) {
      print(result);
    });
    RadarFlutterPlugin.onLocation((result) {
      print(result);
    });
    RadarFlutterPlugin.onError((result) {
      print(result);
    });
    RadarFlutterPlugin.startListeners();

    Map<String, String> metadata = {"mKey": "mValue"};
    RadarFlutterPlugin.setMetadata(metadata);
    Map userMetadata = await RadarFlutterPlugin.getMetadata();
    print("current metadata: ");
    print(userMetadata);
    // Map nearbyGeofences = await RadarFlutterPlugin.searchGeofences(
    //     {
    //       "latitude": 40.704103,
    //       "longitude": -73.987067,
    //     },
    //     5000,
    //     5,
    //     ["store"]);
    // print("nearby geofences output:");
    // print(nearbyGeofences["geofences"]);

    // Map context = await RadarFlutterPlugin.getContext({
    //   "latitude": 40.704103,
    //   "longitude": -73.987067,
    // });
    // print("context output:");
    // print(context["context"]);

    // Map nearbyPlaces = await RadarFlutterPlugin.searchPlaces(
    //     {"latitude": 40.704103, "longitude": -73.987067},
    //     5000,
    //     5,
    //     ["starbucks"]);
    // print("nearby places output:");
    // print(nearbyPlaces["places"]);

    // Map nearbyPoints = await RadarFlutterPlugin.searchPoints(
    //     {
    //       "latitude": 40.704103,
    //       "longitude": -73.987067,
    //     },
    //     5000,
    //     5,
    //     ["store"]);
    // print("nearby points output:");
    // print(nearbyPoints["points"]);

    // Map addresses =
    //     await RadarFlutterPlugin.geocode("20 Jay St, Brooklyn, NY, 11222");
    // print(addresses["addresses"]);
    // Map addressesR = await RadarFlutterPlugin.reverseGeocode(
    //     {"latitude": 40.704103, "longitude": -73.987067});
    // print(addressesR["addresses"]);
    // Map ipAddress = await RadarFlutterPlugin.ipGeocode();
    // print(ipAddress);

    // Map addressesAutocomplete = await RadarFlutterPlugin.autocomplete(
    //     "20 Jay", {"latitude": 40.7033, "longitude": -73.986});
    // print(addressesAutocomplete);

    // Map distance = await RadarFlutterPlugin.getDistance(
    //     {"latitude": 40.70390, "longitude": -73.98670},
    //     ["CAR", "BIKE"],
    //     "METRIC",
    //     {"latitude": 40.7033, "longitude": -73.986});
    // print(distance);

    // Map<String, String> tripOptions = {
    //   "externalId": "flutterTripAB",
    //   "destinationGeofenceTag": "store",
    //   "destinationGeofenceExternalId": "123",
    //   "mode": "car"
    // };
    // RadarFlutterPlugin.startTrip(tripOptions);
    // Map currentTripOptions = await RadarFlutterPlugin.getTripOptions();
    // print(currentTripOptions);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        child: Column(children: [
          LocationPermissions(),
          TrackOnce(),
          RaisedButton(
            color: Colors.blueAccent,
            onPressed: () {
              // RadarFlutterPlugin.startTracking('continuous');
              Map<String, dynamic> trackingOptions = {
                "desiredStoppedUpdateInterval": 180,
                "desiredMovingUpdateInterval": 60,
                "desiredSyncInterval": 50,
                "desiredAccuracy": 'high',
                "stopDuration": 140,
                "stopDistance": 70,
                "sync": 'all',
                "replay": 'none',
                "showBlueBar": true
              };
              RadarFlutterPlugin.startTrackingCustom(trackingOptions);
              showAlertDialog(context, 'now tracking continuously');
            },
            child: Text("StartTracking"),
          ),
          RaisedButton(
            color: Colors.blueAccent,
            onPressed: () {
              RadarFlutterPlugin.stopTracking();
            },
            child: Text("StopTracking"),
          ),
          RaisedButton(
            color: Colors.blueAccent,
            onPressed: () {
              RadarFlutterPlugin.requestPermissions(true);
            },
            child: Text("Request Permissions"),
          ),
          RaisedButton(
            color: Colors.blueAccent,
            onPressed: () {
              RadarFlutterPlugin.trackOnce({
                "latitude": 40.704103,
                "longitude": -73.987067,
                "accuracy": 50.0,
              });
            },
            child: Text("Track Once With Location"),
          )
        ]),
      ),
    ));
  }
}

class LocationPermissions extends StatefulWidget {
  @override
  _LocationPermissionsState createState() => _LocationPermissionsState();
}

class _LocationPermissionsState extends State<LocationPermissions> {
  String _permissionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getPermissionsStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$_permissionStatus',
          style: TextStyle(fontSize: 30),
        ),
        RaisedButton(
          color: Colors.blueAccent,
          child: Text('Get Permissions'),
          onPressed: () {
            _getPermissionsStatus();
          },
        ),
      ],
    );
  }

  // this private method is run whenever the button is pressed
  Future _getPermissionsStatus() async {
    String permissionsString = await RadarFlutterPlugin.permissionsStatus();
    setState(() {
      _permissionStatus = permissionsString;
    });
  }
}

class TrackOnce extends StatefulWidget {
  @override
  _TrackOnceState createState() => _TrackOnceState();
}

class _TrackOnceState extends State<TrackOnce> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('TrackOnce()'),
      color: Colors.blueAccent,
      onPressed: () {
        _showTrackOnceDialog();
      },
    );
  }

  Future<void> _showTrackOnceDialog() async {
    var trackResponse = await RadarFlutterPlugin.trackOnce();
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Dialog title"),
      content: Text(trackResponse['status']),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

showAlertDialog(BuildContext context, String textDisplay) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Radar plugin"),
    content: Text(textDisplay),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
