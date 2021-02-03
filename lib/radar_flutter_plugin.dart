import 'dart:async';

import 'package:flutter/services.dart';

class RadarFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('radar_flutter_plugin');

  // event handlers
  static Function(Map result) _clientLocationHandler;
  static Function(Map result) _eventHandler;
  static Function(Map result) _locationHandler;
  static Function(Map result) _errorHandler;
  static Function(Map result) _logHandler;

  // RadarFlutterPlugin() {
  //   RadarFlutterPlugin._channel
  //       .setMethodCallHandler(RadarFlutterPlugin._handleMethod);
  // }

  // static RadarFlutterPlugin shared = new RadarFlutterPlugin();

  /// initialize publishable key
  /// for background location tracking it is valuable to initialize in the native code rather than in dart
  /// accepts a string publishable key which can be accessed from your Radar dashboard
  static Future initialize(String publishableKey) async {
    var params = <String, String>{
      'publishableKey': publishableKey,
    };
    try {
      await _channel.invokeMethod('initialize', params);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// gets location permission status
  static Future<String> permissionsStatus() async {
    final String permissionsStatus =
        await _channel.invokeMethod('getPermissionsStatus');
    return permissionsStatus;
  }

  /// sets the Radar log level
  /// options are DEBUG, WARNING, ERROR and INFO
  static Future setLogLevel(String logLevel) async {
    try {
      await _channel.invokeMethod('setLogLevel', {"logLevel": logLevel});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// request location permissions
  /// required input is a boolean if you should request foreground or background
  static Future requestPermissions(bool background) async {
    try {
      await _channel
          .invokeMethod('requestPermissions', {"background": background});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// set external user id for the given device
  /// required input is a string
  static Future setUserId(String userId) async {
    try {
      await _channel.invokeMethod('setUserId', {"userId": userId});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// get current external user id
  static Future<String> getUserId() async {
    final String userId = await _channel.invokeMethod('getUserId');
    return userId;
  }

  /// set the description for the given device
  /// required input is a string
  static Future setDescription(String description) async {
    try {
      await _channel
          .invokeMethod('setDescription', {"description": description});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// set the metadata
  /// required input is a Map of key value pairs
  /// alphabet and underscore allowed characters for keys
  /// string,numeric and booleans allowed for values
  static Future setMetadata(Map<String, dynamic> metadata) async {
    try {
      await _channel.invokeMethod('setMetadata', metadata);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// get the current description
  static Future<String> getDecription() async {
    final String description = await _channel.invokeMethod('getDescription');
    return description;
  }

  /// get the user location
  /// optional string for desired accuracy (higher accuracy requested = slower response)
  /// values accepted for accuracy are low, medium and high
  /// default accuracy is medium (wifi scanning 10-100m)
  static Future<Map> getLocation([String accuracy]) async {
    try {
      final Map locationResult =
          await _channel.invokeMethod('getLocation', {"accuracy": accuracy});
      return locationResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> locationError = {'error': e.code};
      return locationError;
    }
  }

  /// get current context for the device (current geofences)
  /// optionally pass in a location (latitude,longitude and accuracy are required)
  /// if no location is passed, method will get current device location at medium accuracy
  static Future<Map> trackOnce([Map<String, dynamic> location]) async {
    try {
      if (location == null) {
        final Map trackOnceResult = await _channel.invokeMethod('trackOnce');
        return trackOnceResult;
      } else {
        final Map trackOnceResult =
            await _channel.invokeMethod('trackOnce', {"location": location});
        return trackOnceResult;
      }
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> trackError = {'error': e.code};
      return trackError;
    }
  }

  /// start ongoing location tracking with a Radar tracking preset
  /// options for the preset are efficient, continuous and responsive
  /// defaults to responsive
  static Future startTracking(String preset) async {
    var params = <String, String>{
      'preset': preset,
    };
    try {
      await _channel.invokeMethod('startTracking', params);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// start ongoing tracking with your own tracking options passed in as a map
  /// see here for options: https://radar.io/documentation/sdk/tracking
  static Future startTrackingCustom(
      Map<String, dynamic> trackingOptions) async {
    try {
      await _channel.invokeMethod('startTrackingCustom', trackingOptions);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// stop ongoing tracking
  static Future stopTracking() async {
    try {
      await _channel.invokeMethod('stopTracking');
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// check if ongoing tracking is on
  static Future<bool> isTracking() async {
    final bool isTracking = await _channel.invokeMethod('isTracking');
    return isTracking;
  }

  // static Future acceptEvent(String eventId, [String verifiedPlaceId]) async {
  //   try {
  //     if (verifiedPlaceId == null) {
  //       var params = <String, String>{
  //         "eventId": eventId,
  //       };
  //       await _channel.invokeMethod('acceptEvent', params);
  //     } else {
  //       var params = <String, String>{
  //         "eventId": eventId,
  //         "verifiedPlaceId": verifiedPlaceId
  //       };
  //       await _channel.invokeMethod('acceptEvent', params);
  //     }
  //   } on PlatformException catch (e) {
  //     print("Got error: $e");
  //   }
  // }

  // static Future rejectEvent(String eventId) async {
  //   try {
  //     await _channel.invokeMethod('rejectEvent', {"eventId": eventId});
  //   } on PlatformException catch (e) {
  //     print("Got error: $e");
  //   }
  // }

  /// get current device's metadata
  static Future<Map> getMetadata() async {
    final Map metadata = await _channel.invokeMethod('getMetadata');
    return metadata;
  }

  /// set if the advertising id should be collected (will not explicitly request but collect if present)
  /// specific to iOS
  static Future setAdIdEnabled(bool adIdEnabled) async {
    try {
      await _channel
          .invokeMethod('setAdIdEnabled', {"AdIdEnabled": adIdEnabled});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// search nearby geofences
  /// https://radar.io/documentation/api#search for information on parameters
  static Future<Map> searchGeofences(
      {Map<String, dynamic> near,
      int radius,
      int limit,
      List tags,
      Map<String, dynamic> metadata}) async {
    try {
      final Map searchGeofencesResult =
          await _channel.invokeMethod('searchGeofences', <String, dynamic>{
        "near": near,
        "radius": radius,
        "limit": limit,
        "tags": tags,
        "metadata": metadata
      });
      return searchGeofencesResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> searchError = {'error': e.code};
      return searchError;
    }
  }

  /// search nearby places
  /// https://radar.io/documentation/api#search for information on parameters
  static Future<Map> searchPlaces(Map<String, dynamic> near,
      {int radius,
      int limit,
      List chains,
      List categories,
      List groups}) async {
    try {
      final Map searchPlacesResult =
          await _channel.invokeMethod('searchPlaces', <String, dynamic>{
        "near": near,
        "radius": radius,
        "limit": limit,
        "chains": chains,
        "catgories": categories,
        "groups": groups
      });
      return searchPlacesResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> searchError = {'error': e.code};
      return searchError;
    }
  }

  /// search nearby points
  /// https://radar.io/documentation/api#search for information on parameters
  static Future<Map> searchPoints(
      {Map<String, dynamic> near, int radius, int limit, List tags}) async {
    try {
      final Map searchPointsResult = await _channel.invokeMethod(
          'searchPoints', <String, dynamic>{
        "near": near,
        "radius": radius,
        "limit": limit,
        "tags": tags
      });
      return searchPointsResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> searchError = {'error': e.code};
      return searchError;
    }
  }

  /// get context (current geofences) with a stateless function
  /// can pass in a location optionally (latitude and longitude) otherwise will request medium accuracy from the device
  static Future<Map> getContext([Map<String, dynamic> location]) async {
    try {
      if (location == null) {
        final Map contextResult = await _channel.invokeMethod('getContext');
        return contextResult;
      } else {
        final Map contextResult =
            await _channel.invokeMethod('getContext', {"location": location});
        return contextResult;
      }
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> contextError = {'error': e.code};
      return contextError;
    }
  }

  /// autocomplete a text string
  /// near parameter biases results
  /// https://radar.io/documentation/api#search for information on parameters
  static Future<Map> autocomplete(String query, Map<String, dynamic> near,
      [int limit]) async {
    try {
      final Map autocompleteResult = await _channel.invokeMethod('autocomplete',
          <String, dynamic>{"query": query, "near": near, "limit": limit});
      return autocompleteResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> autocompleteError = {'error': e.code};
      return autocompleteError;
    }
  }

  /// forward geocode a string
  /// https://radar.io/documentation/api#geocoding for more information on parameters
  static Future<Map> geocode(String query) async {
    try {
      final Map geocodeResult = await _channel
          .invokeMethod('forwardGeocode', <String, String>{"query": query});
      return geocodeResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> geocodeError = {'error': e.code};
      return geocodeError;
    }
  }

  /// reverse geocode a location (latitude and longitude as the two map keys)
  /// https://radar.io/documentation/api#geocoding for more information on parameters
  static Future<Map> reverseGeocode([Map<String, dynamic> location]) async {
    try {
      final Map geocodeResult = await _channel.invokeMethod(
          'reverseGeocode', <String, dynamic>{"location": location});
      return geocodeResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> geocodeError = {'error': e.code};
      return geocodeError;
    }
  }

  /// ip geocode based on devices IP
  /// https://radar.io/documentation/api#geocoding for more information
  static Future<Map> ipGeocode() async {
    try {
      final Map geocodeResult = await _channel.invokeMethod('ipGeocode');
      return geocodeResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> geocodeError = {'error': e.code};
      return geocodeError;
    }
  }

  /// get distance between two points (both distance and time and car,walk and bike modes)
  /// origin is optional. if not provided will use current devices location.
  /// mode options are foot,bike and car
  /// pass in metric for units, otherwise it will be imperial
  static Future<Map> getDistance(
      Map<String, double> destination, List modes, String units,
      [Map<String, double> origin]) async {
    try {
      if (origin == null) {
        final Map distanceResult = await _channel.invokeMethod(
            'getDistance', <String, dynamic>{
          "destination": destination,
          "modes": modes,
          "units": units
        });
        return distanceResult;
      } else {
        final Map distanceResult = await _channel.invokeMethod(
            'getDistance', <String, dynamic>{
          "origin": origin,
          "destination": destination,
          "modes": modes,
          "units": units
        });
        return distanceResult;
      }
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> distanceError = {'error': e.code};
      return distanceError;
    }
  }

  /// start a trip
  /// tripOptions parameters are destinationGeofenceExternalId,destinationGeofenceTag, externalId and metadata
  /// see here for more information: https://radar.io/documentation/trip-tracking
  static Future startTrip(Map<String, dynamic> tripOptions) async {
    try {
      await _channel.invokeMethod('startTrip', tripOptions);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// get current trip option set for device
  /// see here for more information: https://radar.io/documentation/trip-tracking
  static Future<Map> getTripOptions() async {
    final Map tripOptions = await _channel.invokeMethod('getTripOptions');
    return tripOptions;
  }

  /// complete current trip
  /// see here for more information: https://radar.io/documentation/trip-tracking
  static Future completeTrip() async {
    try {
      await _channel.invokeMethod('completeTrip');
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  /// cancel current trip
  /// see here for more information: https://radar.io/documentation/trip-tracking
  static Future cancelTrip() async {
    try {
      await _channel.invokeMethod('cancelTrip');
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future startForegroundService(
      Map<String, String> foregroundServiceOptions) async {
    try {
      await _channel.invokeMethod(
          'startForegroundService', foregroundServiceOptions);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future stopForegroundService() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  // static Future<Map> mockTracking(
  //     Map<String, dynamic> origin,
  //     Map<String, dynamic> destination,
  //     List mode,
  //     int steps,
  //     int interval) async {
  //   try {
  //     final Map mockTrackResult = await _channel.invokeMethod('mockTrack');
  //     return mockTrackResult;
  //   } on PlatformException catch (e) {
  //     print("Got error: $e");
  //     Map<String, String> mockTrackError = {'error': e.code};
  //     return mockTrackError;
  //   }
  // }

  static startListeners() {
    _channel.setMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "onClientLocation" &&
          _clientLocationHandler != null) {
        // print("processing client location");
        Map resultData = Map.from(methodCall.arguments);
        _clientLocationHandler(resultData);
      } else if (methodCall.method == "onEvents" && _eventHandler != null) {
        // print("processing events");
        Map resultData = Map.from(methodCall.arguments);
        _eventHandler(resultData);
      } else if (methodCall.method == "onLocation" &&
          _locationHandler != null) {
        // print("processing location");
        Map resultData = Map.from(methodCall.arguments);
        _locationHandler(resultData);
      } else if (methodCall.method == "onError" && _errorHandler != null) {
        // print("processing error");
        Map resultData = Map.from(methodCall.arguments);
        _errorHandler(resultData);
      } else if (methodCall.method == "onLog" && _logHandler != null) {
        // print("processing error");
        Map resultData = Map.from(methodCall.arguments);
        _logHandler(resultData);
      }
      return null;
    });
  }

  static onClientLocation(
      Function(Map<dynamic, dynamic> result) resultProcess) {
    _clientLocationHandler = resultProcess;
  }

  static offClientLocation() {
    _clientLocationHandler = null;
  }

  static onEvents(Function(Map<dynamic, dynamic> result) resultProcess) {
    _eventHandler = resultProcess;
  }

  static offEvents() {
    _eventHandler = null;
  }

  static onLocation(Function(Map<dynamic, dynamic> result) resultProcess) {
    _locationHandler = resultProcess;
  }

  static offLocation() {
    _locationHandler = null;
  }

  static onError(Function(Map<dynamic, dynamic> result) resultProcess) {
    _errorHandler = resultProcess;
  }

  static offError() {
    _errorHandler = null;
  }

  static onLog(Function(Map<dynamic, dynamic> result) resultProcess) {
    _logHandler = resultProcess;
  }

  static offLog() {
    _logHandler = null;
  }
}
