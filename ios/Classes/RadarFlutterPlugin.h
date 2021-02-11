#import <Flutter/Flutter.h>

@interface RadarFlutterPlugin : NSObject<FlutterPlugin>
@end

@interface LocationStreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end

@interface ClientLocationStreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end

@interface EventStreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end

@interface ErrorStreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end

@interface LogStreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end
