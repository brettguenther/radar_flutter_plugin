#import "RadarFlutterPlugin.h"
#import <RadarSDK/RadarSDK.h>
#import <CoreLocation/CoreLocation.h>

@interface RadarFlutterPlugin()
 @property (strong, readwrite) CLLocationManager *locationManager;
@end

@implementation RadarFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"radar_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  RadarFlutterPlugin* instance = [[RadarFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.locationManager = [[CLLocationManager alloc] init];
//    [Radar setDelegate:self];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initialize" isEqualToString:call.method]) {
      [self initialize:call withResult:result];
    }
    else if ([@"getPermissionsStatus" isEqualToString:call.method]) {
      [self getPermissionsStatus:result];
    }
    else if ([@"setLogLevel" isEqualToString:call.method]) {
      [self setLogLevel:call withResult:result];
    }
    else if ([@"requestPermissions" isEqualToString:call.method]) {
      [self requestPermissions:call withResult:result];
    }
    else if ([@"setUserId" isEqualToString:call.method]) {
      NSString *userId = call.arguments[@"userId"];
      [Radar setUserId:userId];
      result(nil);
    }
    else if ([@"getUserId" isEqualToString:call.method]) {
      result([Radar getUserId]);
    }
    else if ([@"setDescription" isEqualToString:call.method]) {
      NSString *descriptionString = call.arguments[@"description"];
      [Radar setDescription:descriptionString];
      result(nil);
    }
    else if ([@"setMetadata" isEqualToString:call.method]) {
      NSDictionary *metadataDict = call.arguments;
      [Radar setMetadata:metadataDict];
      result(nil);
    }
    else if ([@"getDescription" isEqualToString:call.method]) {
      result([Radar getDescription]);
    }
    else if ([@"trackOnce" isEqualToString:call.method]) {
      RadarTrackCompletionHandler completionHandler = ^(RadarStatus status, CLLocation *location, NSArray<RadarEvent *> *events, RadarUser *user) {
          if (status == RadarStatusSuccess) {
              NSMutableDictionary *dict = [NSMutableDictionary new];
              [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
              if (location) {
                  [dict setObject:[Radar dictionaryForLocation:location] forKey:@"location"];
              }
              if (events) {
                  [dict setObject:[RadarEvent arrayForEvents:events] forKey:@"events"];
              }
              if (user) {
                  [dict setObject:[user dictionaryValue] forKey:@"user"];
              }
              result(dict);
          }
      };
      if (call.arguments[@"location"]) {
        NSDictionary *locationDict = call.arguments[@"location"];
        NSNumber *latitudeNumber = locationDict[@"latitude"];
        NSNumber *longitudeNumber = locationDict[@"longitude"];
        NSNumber *accuracyNumber = locationDict[@"accuracy"];
        double latitude = [latitudeNumber doubleValue];
        double longitude = [longitudeNumber doubleValue];
        double accuracy = accuracyNumber ? [accuracyNumber doubleValue] : -1;
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) altitude:-1 horizontalAccuracy:accuracy verticalAccuracy:-1 timestamp:[NSDate date]];
        [Radar trackOnceWithLocation:location completionHandler:completionHandler];
      } else {        
        [Radar trackOnceWithCompletionHandler:completionHandler];
      }
    }
    else if ([@"startTracking" isEqualToString:call.method]) {
      [self startTracking:call withResult:result];
    }
    else if ([@"startTrackingCustom" isEqualToString:call.method]) {
      NSDictionary *trackOptionsDict = call.arguments;
      RadarTrackingOptions *options = [RadarTrackingOptions trackingOptionsFromDictionary:trackOptionsDict];
      [Radar startTrackingWithOptions:options];
      result(nil);
    }
    else if ([@"stopTracking" isEqualToString:call.method]) {
      [Radar stopTracking];
      result(nil);
    }
    else if ([@"isTracking" isEqualToString:call.method]) {
      BOOL isTracking = [Radar isTracking];
        result(isTracking ? @"True" : @"False" );
    }
    else if ([@"getMetadata" isEqualToString:call.method]) {
        result([Radar getMetadata]);
      }
    else if ([@"setAdIdEnabled" isEqualToString:call.method]) {
      BOOL setAdId = call.arguments[@"AdIdEnabled"];
      [Radar setAdIdEnabled:setAdId];
      result(nil);
    }
    else if ([@"searchGeofences" isEqualToString:call.method]) {
      [self searchGeofences:call withResult:result];
    }
    //   else if ([@"getContext" isEqualToString:call.method]) {
    //   }
    // else if ([@"acceptEvent" isEqualToString:call.method]) {
    //   if (call.arguments[@"verifiedPlaceId"]) {
    //     NSString *eventIdString = call.arguments["eventId"];
    //     NSString *verifiedPlaceIdString = call.arguments["verifiedPlaceId"];
    //     [Radar acceptEventId:eventIdString verifiedPlaceId:verifiedPlaceIdString];
    //   } else {
    //     NSString *eventIdString = call.arguments["eventId"];
    //     [Radar acceptEventId:eventIdString verifiedPlaceId:nil];
    //   }
    //   result(nil);
    // }
    // else if ([@"rejectEvent" isEqualToString:call.method]) {
    //   NSString *eventIdString = call.arguments["eventId"];
    //   [Radar rejectEventId:eventIdString];
    // }
  //   else if ([@"searchPlaces" isEqualToString:call.method]) {
  //   }
  //   else if ([@"searchPoints" isEqualToString:call.method]) {
  //   }
  //   else if ([@"autocomplete" isEqualToString:call.method]) {
  //   }
  //   else if ([@"forwardGeocode" isEqualToString:call.method]) {
  //   }
  //   else if ([@"reverseGeocode" isEqualToString:call.method]) {
  //   }
  //   else if ([@"ipGeocode" isEqualToString:call.method]) {
  //   }
  //   else if ([@"getDistance" isEqualToString:call.method]) {
  //     RadarRouteCompletionHandler completionHandler = ^(RadarStatus status, RadarRoutes * _Nullable routes) {
  //       NSMutableDictionary *dict = [NSMutableDictionary new];
  //       [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
  //       if (routes) {
  //           [dict setObject:[routes dictionaryValue] forKey:@"routes"];
  //       }
  //       result(dict);
  //     };
  //     NSDictionary *optionsDict = call.arguments;
  //     CLLocation *origin;
  //     NSDictionary *originDict = optionsDict[@"origin"];
  //     if (originDict) {
  //         NSNumber *originLatitudeNumber = originDict[@"latitude"];
  //         NSNumber *originLongitudeNumber = originDict[@"longitude"];
  //         double originLatitude = [originLatitudeNumber doubleValue];
  //         double originLongitude = [originLongitudeNumber doubleValue];
  //         origin = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(originLatitude, originLongitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
  //     }
  //     NSDictionary *destinationDict = optionsDict[@"destination"];
  //     NSNumber *destinationLatitudeNumber = destinationDict[@"latitude"];
  //     NSNumber *destinationLongitudeNumber = destinationDict[@"longitude"];
  //     double destinationLatitude = [destinationLatitudeNumber doubleValue];
  //     double destinationLongitude = [destinationLongitudeNumber doubleValue];
  //     CLLocation *destination = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(destinationLatitude, destinationLongitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
  //     NSArray *modesArr = optionsDict[@"modes"];
  //     RadarRouteMode modes = 0;
  //     if (modesArr != nil) {
  //         if ([modesArr containsObject:@"FOOT"] || [modesArr containsObject:@"foot"]) {
  //             modes = modes | RadarRouteModeFoot;
  //         }
  //         if ([modesArr containsObject:@"BIKE"] || [modesArr containsObject:@"bike"]) {
  //             modes = modes | RadarRouteModeBike;
  //         }
  //         if ([modesArr containsObject:@"CAR"] || [modesArr containsObject:@"car"]) {
  //             modes = modes | RadarRouteModeCar;
  //         }
  //     } else {
  //         modes = RadarRouteModeCar;
  //     }
  //     NSString *unitsStr = optionsDict[@"units"];
  //     RadarRouteUnits units;
  //     if (unitsStr != nil && [unitsStr isKindOfClass:[NSString class]]) {
  //         units = [unitsStr isEqualToString:@"METRIC"] || [unitsStr isEqualToString:@"metric"] ? RadarRouteUnitsMetric : RadarRouteUnitsImperial;
  //     } else {
  //         units = RadarRouteUnitsImperial;
  //     }

  //     if (origin) {
  //         [Radar getDistanceFromOrigin:origin destination:destination modes:modes units:units completionHandler:completionHandler];
  //     } else {
  //         [Radar getDistanceToDestination:destination modes:modes units:units completionHandler:completionHandler];
  //     }
  //   }
  //   else if ([@"startTrip" isEqualToString:call.method]) {
  //     NSDictionary *optionsDict = call.arguments;
  //     RadarTripOptions *options = [RadarTripOptions tripOptionsFromDictionary:optionsDict];
  //     [Radar startTripWithOptions:options];
  //   }
  //   else if ([@"getTripOptions" isEqualToString:call.method]) {
  // //    RadarTripOptions *options = [Radar getTripOptions];
  //   }
  //   else if ([@"stopTrip" isEqualToString:call.method]) {
  //     [Radar stopTrip];
  //   }
  //   else if ([@"mockTracking" isEqualToString:call.method]) {
  //   }
    else {
      result(FlutterMethodNotImplemented);
    }
}

- (void) initialize:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *publishableKey = call.arguments[@"publishableKey"];
    [Radar initializeWithPublishableKey:publishableKey];
    result(nil);
}

- (void) getPermissionsStatus:(FlutterResult)result {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSString *statusStr;
    switch (status) {
        case kCLAuthorizationStatusDenied:
            statusStr = @"DENIED";
            break;
        case kCLAuthorizationStatusRestricted:
            statusStr = @"DENIED";
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            statusStr = @"GRANTED_BACKGROUND";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            statusStr = @"GRANTED_FOREGROUND";
            break;
        default:
            statusStr = @"DENIED";
            break;
    }
    result(statusStr);
}

- (void) setLogLevel:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  NSString *logLevelString= call.arguments[@"logLevel"];
  if([logLevelString isEqualToString:@"DEBUG"]) {
      [Radar setLogLevel:RadarLogLevelDebug];
    }
  else if([logLevelString isEqualToString:@"WARNING"]) {
      [Radar setLogLevel:RadarLogLevelWarning];
    }
  else if([logLevelString isEqualToString:@"ERROR"]) {
      [Radar setLogLevel:RadarLogLevelError];
    }
  else if([logLevelString isEqualToString:@"INFO"]) {
      [Radar setLogLevel:RadarLogLevelInfo];
    }
    else {
      [Radar setLogLevel:RadarLogLevelNone];
    }
    result(nil);
}

- (void) requestPermissions:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  BOOL background = call.arguments[@"background"];
//  CLLocationManager *locationManager = [[CLLocationManager new] init];
  if (background) {
      [self.locationManager requestAlwaysAuthorization];
  } else {
      [self.locationManager requestWhenInUseAuthorization];
  }
  result(nil);
}

- (void) startTracking:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  NSString *presetString= call.arguments[@"preset"];
  NSArray *presets = @[@"efficient", @"responsive", @"continuous"];
  int preset = [presets indexOfObject:presetString];
  switch (preset) {
      case 0:
        [Radar startTrackingWithOptions:RadarTrackingOptions.efficient];
        break;
      case 1:
        [Radar startTrackingWithOptions:RadarTrackingOptions.responsive];
        break;
      case 2:
        [Radar startTrackingWithOptions:RadarTrackingOptions.continuous];
        break;
      default:
        [Radar startTrackingWithOptions:RadarTrackingOptions.responsive];
        break;
  }
  result(nil);
}
- (void)searchGeofences:(FlutterMethodCall *)call withResult:(FlutterResult)result {
        RadarSearchGeofencesCompletionHandler completionHandler = ^(RadarStatus status, CLLocation * _Nullable location, NSArray<RadarGeofence *> * _Nullable geofences) {
            if (status == RadarStatusSuccess) {
              NSMutableDictionary *dict = [NSMutableDictionary new];
              [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
              if (location) {
                  [dict setObject:[Radar dictionaryForLocation:location] forKey:@"location"];
              }
              if (geofences) {
                  [dict setObject:[RadarGeofence arrayForGeofences:geofences] forKey:@"geofences"];
              }
              result(dict);
            }
        };

        CLLocation *near;
        NSDictionary *nearDict = call.arguments[@"near"];
        if (nearDict) {
            NSNumber *latitudeNumber = nearDict[@"latitude"];
            NSNumber *longitudeNumber = nearDict[@"longitude"];
            double latitude = [latitudeNumber doubleValue];
            double longitude = [longitudeNumber doubleValue];
            near = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
        }
        NSNumber *radiusNumber = call.arguments[@"radius"];
        int radius;
        if (radiusNumber != nil && [radiusNumber isKindOfClass:[NSNumber class]]) {
            radius = [radiusNumber intValue];
        } else {
            radius = 1000;
        }
        NSArray *tags = call.arguments[@"tags"];
//        NSString *tagsString = [tags componentsJoinedByString:@","];
//        NSDictionary *metadata = call.arguments[@"metadata"];
        NSDictionary *metadata = nil;
//        NSLog(@"metadata present: %@", metadata);
        NSNumber *limitNumber = call.arguments[@"limit"];
        int limit;
        if (limitNumber != nil && [limitNumber isKindOfClass:[NSNumber class]]) {
            limit = [limitNumber intValue];
        } else {
            limit = 10;
        }

        if (near) {
            [Radar searchGeofencesNear:near radius:radius tags:tags metadata:metadata limit:limit completionHandler:completionHandler];
        } else {
            [Radar searchGeofencesWithRadius:radius tags:tags metadata:metadata limit:limit completionHandler:completionHandler];
        }
}
@end
