#import "RadarFlutterPlugin.h"
#import <RadarSDK/RadarSDK.h>
#import <CoreLocation/CoreLocation.h>

@interface RadarFlutterPlugin() <RadarDelegate>
 @property (strong, nonatomic) FlutterMethodChannel *channel;
 @property (strong, readwrite) CLLocationManager *locationManager;
@end

@implementation RadarFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"radar_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  RadarFlutterPlugin* instance = [[RadarFlutterPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.locationManager = [[CLLocationManager alloc] init];
   [Radar setDelegate:self];
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
      // [Radar setMetadata:nil];
      // NSMutableDictionary *mutableDict = [NSMutableDictionary new];
      // for(NSString *key in [metadataDict allKeys]) {
      //   NSLog(@"%@ : %@",key, [metadataDict objectForKey:key]);
      //   NSLog(@"%@", [key class]);
      //   NSLog(@"%@", [[metadataDict objectForKey:key] class]);
      //   NSString *valueStr = [NSString stringWithString:[metadataDict objectForKey:key]];
      //   NSString *keyStr = [NSString stringWithString:key];
      //   [mutableDict setObject:valueStr forKey:keyStr];
      // }
      // [Radar setMetadata:mutableDict];
      [Radar setMetadata:metadataDict];
      result(nil);
    }
    else if ([@"getDescription" isEqualToString:call.method]) {
      result([Radar getDescription]);
    }
    else if ([@"getLocation" isEqualToString:call.method]) {
      [self getLocation:call withResult:result];
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
                  NSDictionary *userDict= [user dictionaryValue];
                  if ([userDict objectForKey:@"trip"]) {
                    NSMutableDictionary *newUserDict = [[NSMutableDictionary alloc] init];
                    [newUserDict addEntriesFromDictionary:userDict];
                    NSDictionary *tripDict = [[userDict objectForKey:@"trip"] dictionaryValue];
                    [newUserDict setObject:tripDict forKey:@"trip"];
                    [dict setObject:newUserDict forKey:@"user"];
                  } else {
                    [dict setObject:userDict forKey:@"user"];
                  }
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
    else if ([@"getContext" isEqualToString:call.method]) {
      [self getContext:call withResult:result];
    }
    else if ([@"searchPlaces" isEqualToString:call.method]) {
      [self searchPlaces:call withResult:result];
    }
    else if ([@"searchPoints" isEqualToString:call.method]) {
      [self searchPoints:call withResult:result];
    }
    else if ([@"autocomplete" isEqualToString:call.method]) {
      [self autocomplete:call withResult:result];
    }
    else if ([@"forwardGeocode" isEqualToString:call.method]) {
      [self geocode:call withResult:result];
    }
    else if ([@"reverseGeocode" isEqualToString:call.method]) {
      [self reverseGeocode:call withResult:result];
    }
    else if ([@"ipGeocode" isEqualToString:call.method]) {
      [self ipGeocode:call withResult:result];
    }
    else if ([@"getDistance" isEqualToString:call.method]) {
      [self getDistance:call withResult:result];
    }
    else if ([@"startTrip" isEqualToString:call.method]) {
       NSDictionary *optionsDict = call.arguments;
      //  NSMutableDictionary *mutableDict = [NSMutableDictionary new];
      //  for(NSString *key in [optionsDict allKeys]) {
        //  NSLog(@"%@ : %@",key, [optionsDict objectForKey:key]);
        //  NSLog(@"%@", [key class]);
        //  NSLog(@"%@", [[optionsDict objectForKey:key] class]);
        //  NSString *valueStr = [NSString stringWithString:[optionsDict objectForKey:key]];
        //  NSString *keyStr = [NSString stringWithString:key];
        //  [mutableDict setObject:valueStr forKey:keyStr];
      //  }
       RadarTripOptions *options = [[RadarTripOptions alloc] initWithExternalId:optionsDict[@"externalId"]];
       options.destinationGeofenceTag = optionsDict[@"destinationGeofenceTag"];
       options.destinationGeofenceExternalId = optionsDict[@"destinationGeofenceExternalId"];
       NSString *modeStr = optionsDict[@"mode"];
       if ([modeStr isEqualToString:@"foot"]) {
           options.mode = RadarRouteModeFoot;
       } else if ([modeStr isEqualToString:@"bike"]) {
           options.mode = RadarRouteModeBike;
       } else {
           options.mode = RadarRouteModeCar;
       }
        if (optionsDict[@"metadata"] != [NSNull null]) {
            options.metadata = optionsDict[@"metadata"];
        }
        else {
          NSMutableDictionary *dict = [NSMutableDictionary new];
          options.metadata = dict;
        }
      //  NSMutableDictionary *dict = [NSMutableDictionary new];
      //  options.metadata = dict;
       [Radar startTripWithOptions:options];

      result(nil);
    }
    else if ([@"getTripOptions" isEqualToString:call.method]) {
      RadarTripOptions *options = [Radar getTripOptions];
      NSMutableDictionary *dict = [NSMutableDictionary new];
      if (options != nil) {
          [dict setObject:options.destinationGeofenceExternalId forKey:@"destinationGeofenceExternalId"];
          [dict setObject:options.externalId forKey:@"externalId"];
          [dict setObject:options.destinationGeofenceTag forKey:@"destinationGeofenceTag"];
          if (options.metadata != nil) {
            [dict setObject:options.metadata forKey:@"metadata"];
          }
      }
      result(dict);
    }
    else if ([@"completeTrip" isEqualToString:call.method]) {
      [Radar completeTrip];
    }
    else if ([@"cancelTrip" isEqualToString:call.method]) {
      [Radar cancelTrip];
    }
    // else if ([@"mockTrack" isEqualToString:call.method]) {
    //   [self mockTracking:call withResult:result];
    // }
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

- (void)getLocation:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  RadarLocationCompletionHandler completionHandler = ^(RadarStatus status, CLLocation *location, BOOL stopped) {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
    if (location) {
        [dict setObject:[Radar dictionaryForLocation:location] forKey:@"location"];
    }
    [dict setObject:@(stopped) forKey:@"stopped"];
    result(dict);
  };
  NSString *accuracyString = call.arguments[@"accuracy"];
  if (accuracyString != nil) {
      NSArray *acccuracyOptions = @[@"low", @"medium", @"high"];
      int setAccuracy = [acccuracyOptions indexOfObject:accuracyString];
      switch (setAccuracy) {
          case 0:
            [Radar getLocationWithDesiredAccuracy:RadarTrackingOptionsDesiredAccuracyLow completionHandler:completionHandler];
            break;
          case 1:
            [Radar getLocationWithDesiredAccuracy:RadarTrackingOptionsDesiredAccuracyMedium completionHandler:completionHandler];
            break;
          case 2:
            [Radar getLocationWithDesiredAccuracy:RadarTrackingOptionsDesiredAccuracyHigh completionHandler:completionHandler];
            break;
          default:
            [Radar getLocationWithDesiredAccuracy:RadarTrackingOptionsDesiredAccuracyMedium completionHandler:completionHandler];
            break;
      }
  } else {
    [Radar getLocationWithCompletionHandler:completionHandler];
  }
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
        if (call.arguments[@"near"] != [NSNull null]) {
          NSLog(@"not nill near dict");
          NSDictionary *nearDict = call.arguments[@"near"];
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
        if (tags == [NSNull null]) {
          tags = nil;
        }
        
        NSNumber *limitNumber = call.arguments[@"limit"];
        int limit;
        if (limitNumber != nil && [limitNumber isKindOfClass:[NSNumber class]]) {
            limit = [limitNumber intValue];
        } else {
            limit = 10;
        }
        NSDictionary *metadata = nil;
        if (call.arguments[@"metadata"] != [NSNull null]) {
            metadata = call.arguments[@"metadata"];
        }
        if (near != nil) {
            [Radar searchGeofencesNear:near radius:radius tags:tags metadata:metadata limit:limit completionHandler:completionHandler];
        } else {
            [Radar searchGeofencesWithRadius:radius tags:tags metadata:metadata limit:limit completionHandler:completionHandler];
        }
}

- (void)getContext:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  RadarContextCompletionHandler completionHandler = ^(RadarStatus status, CLLocation * _Nullable location, RadarContext * _Nullable context) {
      NSMutableDictionary *dict = [NSMutableDictionary new];
      [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
      if (location) {
          [dict setObject:[Radar dictionaryForLocation:location] forKey:@"location"];
      }
      if (context) {
          [dict setObject:[context dictionaryValue] forKey:@"context"];
      }
      result(dict);
  };
  if (call.arguments[@"location"] != nil) {
    NSDictionary *locationDict = call.arguments[@"location"];
    NSNumber *latitudeNumber = locationDict[@"latitude"];
    NSNumber *longitudeNumber = locationDict[@"longitude"];
    NSNumber *accuracyNumber = locationDict[@"accuracy"];
    double latitude = [latitudeNumber doubleValue];
    double longitude = [longitudeNumber doubleValue];
    double accuracy = accuracyNumber ? [accuracyNumber doubleValue] : -1;
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) altitude:-1 horizontalAccuracy:accuracy verticalAccuracy:-1 timestamp:[NSDate date]];
    [Radar getContextForLocation:location completionHandler:completionHandler];
  } else {
    [Radar getContextWithCompletionHandler:completionHandler];
  }
}

- (void)searchPlaces:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  RadarSearchPlacesCompletionHandler completionHandler = ^(RadarStatus status, CLLocation * _Nullable location, NSArray<RadarPlace *> * _Nullable places) {
      if (status == RadarStatusSuccess) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
        if (location) {
            [dict setObject:[Radar dictionaryForLocation:location] forKey:@"location"];
        }
        if (places) {
            [dict setObject:[RadarPlace arrayForPlaces:places] forKey:@"places"];
        }
        result(dict);
      }
  };

  CLLocation *near;
  if (call.arguments[@"near"] != [NSNull null]) {
      NSDictionary *nearDict = call.arguments[@"near"];
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
  NSNumber *limitNumber = call.arguments[@"limit"];
  int limit;
  if (limitNumber != nil && [limitNumber isKindOfClass:[NSNumber class]]) {
      limit = [limitNumber intValue];
  } else {
      limit = 10;
  }
  NSArray *chains = call.arguments[@"chains"];
  if (chains == [NSNull null]) {
    chains = nil;
  }
  NSArray *categories = call.arguments[@"categories"];
    if (categories == [NSNull null]) {
    categories = nil;
  }
  NSArray *groups = call.arguments[@"groups"];
  if (groups == [NSNull null]) {
    groups = nil;
  }
  if (near != nil) {
      [Radar searchPlacesNear:near radius:radius chains:chains categories:categories groups:groups limit:limit completionHandler:completionHandler];
  } else {
      [Radar searchPlacesWithRadius:radius chains:chains categories:categories groups:groups limit:limit completionHandler:completionHandler];
  }
}

- (void)searchPoints:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  RadarSearchPlacesCompletionHandler completionHandler = ^(RadarStatus status, CLLocation * _Nullable location, NSArray<RadarPoint *> * _Nullable points) {
      if (status == RadarStatusSuccess) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
        if (location) {
            [dict setObject:[Radar dictionaryForLocation:location] forKey:@"location"];
        }
        if (points) {
          [dict setObject:[RadarPoint arrayForPoints:points] forKey:@"points"];
        }
        result(dict);
      }
  };

  CLLocation *near;
  if (call.arguments[@"near"] != [NSNull null]) {
      NSDictionary *nearDict = call.arguments[@"near"];
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
  if (tags == [NSNull null]) {
    tags = nil;
  }
  NSNumber *limitNumber = call.arguments[@"limit"];
  int limit;
  if (limitNumber != nil && [limitNumber isKindOfClass:[NSNumber class]]) {
      limit = [limitNumber intValue];
  } else {
      limit = 10;
  }
  if (near != nil) {
      [Radar searchPointsNear:near radius:radius tags:tags limit:limit completionHandler:completionHandler];
  } else {
      [Radar searchPointsWithRadius:radius tags:tags limit:limit completionHandler:completionHandler];
  }
}

- (void)autocomplete:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *query = call.arguments[@"query"];
    CLLocation *near;
    NSDictionary *nearDict = call.arguments[@"near"];
    if (nearDict) {
        NSNumber *latitudeNumber = nearDict[@"latitude"];
        NSNumber *longitudeNumber = nearDict[@"longitude"];
        double latitude = [latitudeNumber doubleValue];
        double longitude = [longitudeNumber doubleValue];
        near = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
    }
    NSNumber *limitNumber = call.arguments[@"limit"];
    int limit;
    if (limitNumber != nil && [limitNumber isKindOfClass:[NSNumber class]]) {
        limit = [limitNumber intValue];
    } else {
        limit = 10;
    }

    [Radar autocompleteQuery:query near:near limit:limit completionHandler:^(RadarStatus status, NSArray<RadarAddress *> * _Nullable addresses) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
        if (addresses) {
            [dict setObject:[RadarAddress arrayForAddresses:addresses] forKey:@"addresses"];
        }
        result(dict);
    }];
}

- (void)geocode:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *query = call.arguments[@"query"];
    [Radar geocodeAddress:query completionHandler:^(RadarStatus status, NSArray<RadarAddress *> * _Nullable addresses) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
        if (addresses) {
            [dict setObject:[RadarAddress arrayForAddresses:addresses] forKey:@"addresses"];
        }
        result(dict);
    }];
}

- (void)reverseGeocode:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  RadarGeocodeCompletionHandler completionHandler = ^(RadarStatus status, NSArray<RadarAddress *> * _Nullable addresses) {
      NSMutableDictionary *dict = [NSMutableDictionary new];
      [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
      if (addresses) {
          [dict setObject:[RadarAddress arrayForAddresses:addresses] forKey:@"addresses"];
      }
      result(dict);
  };

  NSDictionary *locationDict = call.arguments[@"location"];
  if (locationDict) {
      NSNumber *latitudeNumber = locationDict[@"latitude"];
      NSNumber *longitudeNumber = locationDict[@"longitude"];
      double latitude = [latitudeNumber doubleValue];
      double longitude = [longitudeNumber doubleValue];
      CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];

      [Radar reverseGeocodeLocation:location completionHandler:completionHandler];
  } else {
      [Radar reverseGeocodeWithCompletionHandler:completionHandler];
  }
}

- (void)ipGeocode:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  [Radar ipGeocodeWithCompletionHandler:^(RadarStatus status, RadarAddress * _Nullable address, BOOL proxy) {
      NSMutableDictionary *dict = [NSMutableDictionary new];
      [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
      if (address) {
          [dict setObject:[address dictionaryValue] forKey:@"address"];
          [dict setValue:@(proxy) forKey:@"proxy"];
      }
      result(dict);
  }];
}

- (void)getDistance:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  RadarRouteCompletionHandler completionHandler = ^(RadarStatus status, RadarRoutes * _Nullable routes) {
      NSMutableDictionary *dict = [NSMutableDictionary new];
      [dict setObject:[Radar stringForStatus:status] forKey:@"status"];
      if (routes) {
          [dict setObject:[routes dictionaryValue] forKey:@"routes"];
      }
      result(dict);
  };

  NSDictionary *optionsDict = call.arguments;

  CLLocation *origin;
  if (call.arguments[@"origin"]) {
      NSDictionary *originDict = optionsDict[@"origin"];
      NSNumber *originLatitudeNumber = originDict[@"latitude"];
      NSNumber *originLongitudeNumber = originDict[@"longitude"];
      double originLatitude = [originLatitudeNumber doubleValue];
      double originLongitude = [originLongitudeNumber doubleValue];
      origin = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(originLatitude, originLongitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
  }
  NSDictionary *destinationDict = optionsDict[@"destination"];
  NSNumber *destinationLatitudeNumber = destinationDict[@"latitude"];
  NSNumber *destinationLongitudeNumber = destinationDict[@"longitude"];
  double destinationLatitude = [destinationLatitudeNumber doubleValue];
  double destinationLongitude = [destinationLongitudeNumber doubleValue];
  CLLocation *destination = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(destinationLatitude, destinationLongitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
  NSArray *modesArr = optionsDict[@"modes"];
  RadarRouteMode modes = 0;
  if (modesArr != nil) {
      if ([modesArr containsObject:@"FOOT"] || [modesArr containsObject:@"foot"]) {
          modes = modes | RadarRouteModeFoot;
      }
      if ([modesArr containsObject:@"BIKE"] || [modesArr containsObject:@"bike"]) {
          modes = modes | RadarRouteModeBike;
      }
      if ([modesArr containsObject:@"CAR"] || [modesArr containsObject:@"car"]) {
          modes = modes | RadarRouteModeCar;
      }
  } else {
      modes = RadarRouteModeCar;
  }
  NSString *unitsStr = optionsDict[@"units"];
  RadarRouteUnits units;
  if (unitsStr != nil && [unitsStr isKindOfClass:[NSString class]]) {
      units = [unitsStr isEqualToString:@"METRIC"] || [unitsStr isEqualToString:@"metric"] ? RadarRouteUnitsMetric : RadarRouteUnitsImperial;
  } else {
      units = RadarRouteUnitsImperial;
  }

  if (call.arguments[@"origin"]) {
      [Radar getDistanceFromOrigin:origin destination:destination modes:modes units:units completionHandler:completionHandler];
  } else {
      [Radar getDistanceToDestination:destination modes:modes units:units completionHandler:completionHandler];
  }
}

-(void)mockTracking:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  NSDictionary *optionsDict = call.arguments;

  NSDictionary *originDict = optionsDict[@"origin"];
  NSNumber *originLatitudeNumber = originDict[@"latitude"];
  NSNumber *originLongitudeNumber = originDict[@"longitude"];
  double originLatitude = [originLatitudeNumber doubleValue];
  double originLongitude = [originLongitudeNumber doubleValue];
  CLLocation *origin = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(originLatitude, originLongitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
  NSDictionary *destinationDict = optionsDict[@"destination"];
  NSNumber *destinationLatitudeNumber = destinationDict[@"latitude"];
  NSNumber *destinationLongitudeNumber = destinationDict[@"longitude"];
  double destinationLatitude = [destinationLatitudeNumber doubleValue];
  double destinationLongitude = [destinationLongitudeNumber doubleValue];
  CLLocation *destination = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(destinationLatitude, destinationLongitude) altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
  NSString *modeStr = optionsDict[@"mode"];
  RadarRouteMode mode = RadarRouteModeCar;
  if ([modeStr isEqualToString:@"FOOT"] || [modeStr isEqualToString:@"foot"]) {
      mode = RadarRouteModeFoot;
  } else if ([modeStr isEqualToString:@"BIKE"] || [modeStr isEqualToString:@"bike"]) {
      mode = RadarRouteModeBike;
  } else if ([modeStr isEqualToString:@"CAR"] || [modeStr isEqualToString:@"car"]) {
      mode = RadarRouteModeCar;
  }
  NSNumber *stepsNumber = optionsDict[@"steps"];
  int steps;
  if (stepsNumber != nil && [stepsNumber isKindOfClass:[NSNumber class]]) {
      steps = [stepsNumber intValue];
  } else {
      steps = 10;
  }
  NSNumber *intervalNumber = optionsDict[@"interval"];
  double interval;
  if (intervalNumber != nil && [intervalNumber isKindOfClass:[NSNumber class]]) {
      interval = [intervalNumber doubleValue];
  } else {
      interval = 1;
  }

  [Radar mockTrackingWithOrigin:origin destination:destination mode:mode steps:steps interval:interval completionHandler:^(RadarStatus status, CLLocation *location, NSArray<RadarEvent *> *events, RadarUser *user) {
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
  }];
}

#pragma mark - RadarDelegate Methods
- (void)didReceiveEvents:(NSArray<RadarEvent *> *)events user:(RadarUser *)user {
  // clean up when dictionaryValue decodes the user.trip
  NSDictionary *userDict= [user dictionaryValue];
  if ([userDict objectForKey:@"trip"]) {
    NSMutableDictionary *newUserDict = [[NSMutableDictionary alloc] init];
    [newUserDict addEntriesFromDictionary:userDict];
    NSDictionary *tripDict = [[userDict objectForKey:@"trip"] dictionaryValue];
    [newUserDict setObject:tripDict forKey:@"trip"];
    NSDictionary *dict = @{@"events": [RadarEvent arrayForEvents:events], @"user": newUserDict};
      [_channel invokeMethod:@"onEvents" arguments:dict];
  }
  else {
    NSDictionary *dict = @{@"events": [RadarEvent arrayForEvents:events], @"user": userDict};
      [_channel invokeMethod:@"onEvents" arguments:dict];
  }
  // NSDictionary *dict = @{@"events": [RadarEvent arrayForEvents:events], @"user": [user dictionaryValue]};
}

- (void)didUpdateLocation:(CLLocation *)location user:(RadarUser *)user {
  // clean up when dictionaryValue decodes the user.trip
  NSDictionary *userDict= [user dictionaryValue];
  if ([userDict objectForKey:@"trip"]) {
    NSMutableDictionary *newUserDict = [[NSMutableDictionary alloc] init];
    [newUserDict addEntriesFromDictionary:userDict];
    NSDictionary *tripDict = [[userDict objectForKey:@"trip"] dictionaryValue];
    [newUserDict setObject:tripDict forKey:@"trip"];
    NSDictionary *dict = @{@"location": [Radar dictionaryForLocation:location], @"user": newUserDict };
      [_channel invokeMethod:@"onLocation" arguments:dict];

  }
  else {
    NSDictionary *dict = @{@"location": [Radar dictionaryForLocation:location], @"user": userDict};
      [_channel invokeMethod:@"onLocation" arguments:dict];

  }
}

- (void)didUpdateClientLocation:(CLLocation *)location stopped:(BOOL)stopped source:(RadarLocationSource)source {
  NSDictionary *dict = @{@"location": [Radar dictionaryForLocation:location], @"stopped": @(stopped), @"source": [Radar stringForSource:source]};
  [_channel invokeMethod:@"onClientLocation" arguments:dict];
}

- (void)didFailWithStatus:(RadarStatus)status {
  NSDictionary *dict = @{@"status": [Radar stringForStatus:status]};
  [_channel invokeMethod:@"onError" arguments:dict];
}

- (void)didLogMessage:(NSString *)message {
  NSDictionary *dict = @{@"message": message};
  [_channel invokeMethod:@"onLog" arguments:dict];
}

@end


