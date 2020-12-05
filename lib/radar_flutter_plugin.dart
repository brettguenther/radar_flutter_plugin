import 'dart:async';

import 'package:flutter/services.dart';

class RadarFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('radar_flutter_plugin');

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

  // static Future<Map> getContext([Map<String, dynamic> location]) async {}
  // static Future<Map> searchGeofences(Map<String, dynamic> location,[int radius, int limit, List tags]) async {}
}
