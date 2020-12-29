import 'dart:async';

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

class RadarFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('radar_flutter_plugin');

  static Function(Map result) _clientLocationHandler;
  static Function(Map result) _eventHandler;
  static Function(Map result) _locationHandler;
  static Function(Map result) _errorHandler;

  // RadarFlutterPlugin() {
  //   RadarFlutterPlugin._channel
  //       .setMethodCallHandler(RadarFlutterPlugin._handleMethod);
  // }

  // static RadarFlutterPlugin shared = new RadarFlutterPlugin();

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

  static Future<String> permissionsStatus() async {
    final String permissionsStatus =
        await _channel.invokeMethod('getPermissionsStatus');
    return permissionsStatus;
  }

  static Future setLogLevel(String logLevel) async {
    try {
      await _channel.invokeMethod('setLogLevel', {"logLevel": logLevel});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future requestPermissions(bool background) async {
    try {
      await _channel
          .invokeMethod('requestPermissions', {"background": background});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future setUserId(String userId) async {
    try {
      await _channel.invokeMethod('setUserId', {"userId": userId});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future<String> getUserId() async {
    final String userId = await _channel.invokeMethod('getUserId');
    return userId;
  }

  static Future setDescription(String description) async {
    try {
      await _channel
          .invokeMethod('setDescription', {"description": description});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future setMetadata(Map<String, String> metadata) async {
    try {
      await _channel.invokeMethod('setMetadata', metadata);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future<String> getDecription() async {
    final String description = await _channel.invokeMethod('getDescription');
    return description;
  }

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

  static Future startTrackingCustom(
      Map<String, dynamic> trackingOptions) async {
    try {
      await _channel.invokeMethod('startTrackingCustom', trackingOptions);
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future stopTracking() async {
    try {
      await _channel.invokeMethod('stopTracking');
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

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

  static Future<Map> getMetadata() async {
    final Map metadata = await _channel.invokeMethod('getMetadata');
    return metadata;
  }

  static Future setAdIdEnabled(bool adIdEnabled) async {
    try {
      await _channel
          .invokeMethod('setAdIdEnabled', {"AdIdEnabled": adIdEnabled});
    } on PlatformException catch (e) {
      print("Got error: $e");
    }
  }

  static Future<Map> searchGeofences(
      [Map<String, dynamic> near,
      int radius,
      int limit,
      List tags,
      Map<String, dynamic> metadata]) async {
    try {
      final Map searchGeofencesResult =
          await _channel.invokeMethod('searchGeofences', <String, dynamic>{
        "near": near,
        "radius": radius,
        "limit": limit,
        "tags": tags
        // ,
        // "metadata": metadata
      });
      return searchGeofencesResult;
    } on PlatformException catch (e) {
      print("Got error: $e");
      Map<String, String> searchError = {'error': e.code};
      return searchError;
    }
  }

  static Future<Map> searchPlaces(Map<String, dynamic> near,
      [int radius,
      int limit,
      List chains,
      List categories,
      List groups]) async {
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

  static Future<Map> searchPoints(
      [Map<String, dynamic> near, int radius, int limit, List tags]) async {
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

  // static Future startTrip(Map<String, dynamic> tripOptions) async {
  //   try {
  //     await _channel.invokeMethod('startTrip', tripOptions);
  //   } on PlatformException catch (e) {
  //     print("Got error: $e");
  //   }
  // }

  // static Future<Map> getTripOptions() async {
  //   final Map tripOptions = await _channel.invokeMethod('getTripOptions');
  //   return tripOptions;
  // }

  // static Future completeTrip() async {
  //   try {
  //     await _channel.invokeMethod('completeTrip');
  //   } on PlatformException catch (e) {
  //     print("Got error: $e");
  //   }
  // }

  // static Future cancelTrip() async {
  //   try {
  //     await _channel.invokeMethod('cancelTrip');
  //   } on PlatformException catch (e) {
  //     print("Got error: $e");
  //   }
  // }

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
      print("in method call handler logic");
      if (methodCall.method == "onClientLocation" &&
          _clientLocationHandler != null) {
        print("processing client location");
        Map resultData = Map.from(methodCall.arguments);
        _clientLocationHandler(resultData);
      } else if (methodCall.method == "onEvents" && _eventHandler != null) {
        print("processing events");
        Map resultData = Map.from(methodCall.arguments);
        _eventHandler(resultData);
      } else if (methodCall.method == "onLocation" &&
          _locationHandler != null) {
        print("processing location");
        Map resultData = Map.from(methodCall.arguments);
        _locationHandler(resultData);
      } else if (methodCall.method == "onError" && _errorHandler != null) {
        print("processing error");
        Map resultData = Map.from(methodCall.arguments);
        _errorHandler(resultData);
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
}
