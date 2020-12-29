# Radar Flutter Plugin

[Radar](https://radar.io) is location data infrastructure. You can use Radar SDKs and APIs to add location context to your apps with just a few lines of code.

## Documentation

See the Radar overview documentation [here](https://radar.io/documentation).

## Support

This is a community developed plugin. 

Flutter support:
* [x] iOS
* [x] Android

## Features

* User management
* Geofencing
* Geo APIs (geocoding, distance, autocomplete)
* Search (geofences, points and places)
* Location tracking and context (foreground and background)

## Planned features
* Trip tracking
* Mock tracking
* Accept/reject events

## Setup
### Android
#### **Change the minSdkVersion for Android**

radar_flutter_plugin is compatible only from version 16 of Android SDK so you should change this in **android/app/build.gradle** if needed:
```dart
Android {
  defaultConfig {
     minSdkVersion: 16
```
#### **Add permissions for Location**
We need to add the permission to access location:

In the **android/app/src/main/AndroidManifest.xml** let’s add:

```dart 
<manifest>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    ...
 </manifest>
```

#### **Add MainApplication**
 Open the `MainApplication` class for your project. **Note that `MainApplication`
is not created by default through `flutter create <Project>`, so you may need to
create it**. 

Add code to extend the Flutter Application class
(`FlutterApplication`) that imports and initializes Reader SDK:

```java
package <YOUR_PACKAGE_NAME>;

import io.flutter.app.FlutterApplication;
import io.flutter.view.FlutterMain;
import io.radar.sdk.Radar;

public class MainApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        Radar.initialize(this,"<yourRadarPublishableKey>");
        FlutterMain.startInitialization(this);
    }
}
```

If you create `MainApplication` class in above step, update `AndroidManifest.xml` in your project:

```xml
<application
  <!-- use custom "MainApplication" class instead of "io.flutter.app.FlutterApplication" -->
  android:name=".MainApplication" 
  ... />
</application>
```

In `MainActivity` you might need the following engine registration:
```java
public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
```

### **IOS**

#### **Add permissions for Location**
In the **ios/Runner/Info.plist** let’s add:

```xml
<dict>  
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Your iOS 11 and higher background location usage description goes here. e.g., "This app uses your location in the background to recommend places nearby."</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Your iOS 10 and lower background location usage description goes here. e.g., "This app uses your location in the background to recommend places nearby."</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Your foreground location usage description goes here. e.g., "This app uses your location in the foreground to recommend places nearby."</string>
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>location</string>
  </array>
...
</dict>
```

For location permissions on iOS see more at: [https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services)

#### **Initialize Radar**

```objective-c
package <YOUR_PACKAGE_NAME>;

import io.flutter.app.FlutterApplication;
import io.flutter.view.FlutterMain;
import io.radar.sdk.Radar;

public class MainApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        Radar.initialize(this,"<yourRadarPublishableKey>");
        FlutterMain.startInitialization(this);
    }
}
```

## Usage
To use this plugin, add `radar_flutter_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  radar_flutter_plugin: ^0.0.1
```

See [here](https://radar.io/documentation/tutorials) for example applications of Radar and the [example app](https://github.com/brettguenther/radar_flutter_plugin/tree/main/example) for relevant functions.

