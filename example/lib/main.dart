import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
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
    initRadar();
  }

  Future<void> initRadar() async {
    print("starting radar");
    try {
      await RadarFlutterPlugin.initialize("<yourPublishableKey>");
    } on PlatformException catch (e) {
      print(e.message);
    }
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

    // Map<String, String> metadata = {"k1": "v1"};
    // RadarFlutterPlugin.setMetadata(metadata);
    Map nearbyGeofences = await RadarFlutterPlugin.searchGeofences(
        {
          "latitude": 40.704103,
          "longitude": -73.987067,
          "accuracy": 50.0,
        },
        550,
        5,
        ["store"]);
    print(nearbyGeofences["geofences"]);
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
          // Text('User Location permissions: $_permissionStatus\n'),
          // child: locationPermissions(),
          LocationPermissions(),
          TrackOnce(),
          RaisedButton(
            color: Colors.blueAccent,
            onPressed: () {
              RadarFlutterPlugin.startTracking('continuous');
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

// String _permissionStatus = 'Unknown';

// @override
// void initState() {
//   super.initState();
//   initHomeState();
// }

// // Platform messages are asynchronous, so we initialize in an async method.
// Future<void> initHomeState() async {
//   String permissionStatus;
//   Map locationState;
//   // Platform messages may fail, so we use a try/catch PlatformException.
//   try {
//     permissionStatus = await RadarFlutterPlugin.permissionsStatus;
//   } on PlatformException {
//     permissionStatus = 'Failed to get permissions.';
//   }

//   try {
//     locationState = await RadarFlutterPlugin.trackOnce();
//     developer.log(locationState['user']['_id'], name: 'radar user id');
//   } on PlatformException {
//     developer.log('issue with trackOnce', name: 'radar');
//   }

//   // If the widget was removed from the tree while the asynchronous platform
//   // message was in flight, we want to discard the reply rather than calling
//   // setState to update our non-existent appearance.
//   if (!mounted) return;

//   setState(() {
//     _permissionStatus = permissionStatus;
//   });
// }

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
    // Using the callback State.setState() is the only way to get the build
    // method to rerun with the updated state value.
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
        // This closes the dialog. `context` means the BuildContext, which is
        // available by default inside of a State object. If you are working
        // with an AlertDialog in a StatelessWidget, then you would need to
        // pass a reference to the BuildContext.
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

// to figure out event sink

// location.onLocationChanged.listen((LocationData currentLocation) {
//   // Use current location
// });
