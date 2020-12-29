# radar_flutter_plugin

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
* Geo APIs


## Planned features
* Location permission change listening
* fg service creation
* Trip tracking
* Mock tracking
* Accept/reject events

## Setup
### Change the minSdkVersion for Android

radar_flutter_plugin is compatible only from version 19 of Android SDK so you should change this in **android/app/build.gradle**:
```dart
Android {
  defaultConfig {
     minSdkVersion: 19
```
### Add permissions for Location
We need to add the permission to access location:

#### **Android**
In the **android/app/src/main/AndroidManifest.xml** let’s add:

```dart 
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
 <application
```

### Add receiver and foreground service


```dart
        <receiver
            android:name=".MyRadarReceiver"
            android:enabled="true"
            android:exported="false">
            <intent-filter>
                <action android:name="io.radar.sdk.RECEIVED" />
            </intent-filter>
        </receiver>
```

### Add MainApplication
 Open the `MainApplication` class for your project. **Note that `MainApplication`
is not created by default through `flutter create <Project>`, so you may need to
create it**. Add code to extend the Flutter Application class
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

#### **IOS**

### adjust plist
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

### initialize Radar in appDelegate

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

For location permissions on iOS see more at: [https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services)

## Usage
To use this plugin, add `radar_flutter_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  radar_flutter_plugin: ^1.0.0
```