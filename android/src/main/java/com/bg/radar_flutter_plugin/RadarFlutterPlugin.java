package com.bg.radar_flutter_plugin;

import android.Manifest;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.util.Log;
import android.os.Looper;
import android.os.Handler;
import android.location.Location;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import io.radar.sdk.Radar;
import io.radar.sdk.RadarReceiver;
import io.radar.sdk.RadarTrackingOptions;
import io.radar.sdk.model.RadarEvent;
import io.radar.sdk.model.RadarUser;

/** RadarFlutterPlugin */
public class RadarFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Activity activity;
    private Registrar registrar;

    private Context applicationContext;

//    private void setContext(Context context) {
//        this.applicationContext = context;
//    }

//    private Activity getActivity() {
//        return registrar != null ? registrar.activity() : activity;
//    }
//
//    private void setActivity(Activity activity) {
//        this.activity = activity;
//    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
//        setActivity(activityPluginBinding.getActivity());
        activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
//        setActivity(null);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "radar_flutter_plugin");
        channel.setMethodCallHandler(this);
        applicationContext = flutterPluginBinding.getApplicationContext();
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "radar_flutter_plugin");
        final RadarFlutterPlugin plugin = new RadarFlutterPlugin();
        channel.setMethodCallHandler(plugin);
        plugin.applicationContext = registrar.context();
        plugin.activity = registrar.activity();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
        try {
            switch (call.method) {
                case "initialize":
                    initialize(call, result);
                    break;
                case "getPermissionsStatus":
                    getPermissionStatus(result);
                    break;
                case "setLogLevel":
                    setLogLevel(call, result);
                    break;
                case "requestPermissions":
                    requestPermissions(call, result);
                    break;
                case "setUserId":
                    setUserId(call, result);
                    break;
                case "getUserId":
                    getUserId(result);
                    break;
                case "setDescription":
                    setDescription(call, result);
                    break;
                case "setMetadata":
                    setMetadata(call, result);
                    break;
                case "getDescription":
                    getDescription(result);
                    break;
                case "trackOnce":
                    trackOnce(call, result);
                    break;
                case "startTracking":
                    startTracking(call, result);
                    break;
                case "startTrackingCustom":
                    startTrackingCustom(call, result);
                    break;
                case "stopTracking":
                    stopTracking(result);
                    break;
                case "isTracking":
                    isTracking(result);
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        } catch (Error e) {
            result.error(e.toString(), e.getMessage(), e.getCause());
        }

    }
    private void runOnMainThread(final Runnable runnable) {
        if (Looper.getMainLooper().getThread() == Thread.currentThread())
           runnable.run();
        else {
           Handler handler = new Handler(Looper.getMainLooper());
           handler.post(runnable);
        }
     }

    private void initialize(MethodCall call, Result result) {
        final String publishableKey = call.argument("publishableKey");
        Radar.initialize(applicationContext,publishableKey);
        result.success(true);
    }

    private void getPermissionStatus(Result result) {
        boolean foreground = ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
        if (Build.VERSION.SDK_INT >= 29) {
            if (foreground) {
                boolean background = ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED;
                result.success(background ? "GRANTED_BACKGROUND" : "GRANTED_FOREGROUND");
            } else {
                result.success("DENIED");
            }
        } else {
            result.success(foreground ? "GRANTED_BACKGROUND" : "DENIED");
        }
    }

    private void setLogLevel(MethodCall call, Result result) {
        final String level = call.argument("logLevel");
        switch (level) {
            case "DEBUG":
                Radar.setLogLevel(Radar.RadarLogLevel.DEBUG);
                break;
            case "ERROR":
                Radar.setLogLevel(Radar.RadarLogLevel.ERROR);
                break;
            case "INFO":
                Radar.setLogLevel(Radar.RadarLogLevel.INFO);
                break;
            case "WARNING":
                Radar.setLogLevel(Radar.RadarLogLevel.WARNING);
                break;
            default:
                Radar.setLogLevel(Radar.RadarLogLevel.NONE);
                break;
        }
        result.success(null);
    }

    private void requestPermissions(MethodCall call, Result result) {
        final Boolean background = call.argument("background");
        if (activity != null) {
            if (Build.VERSION.SDK_INT >= 23) {
                int requestCode = 0;
                if (background && Build.VERSION.SDK_INT >= 29) {
                    ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_BACKGROUND_LOCATION}, requestCode);
                } else {
                    ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, requestCode);
                }
            }
        }
        result.success(true);
    }

    private void setUserId(MethodCall call, Result result) {
        final String userId = call.argument("userId");
        Radar.setUserId(userId);
        result.success(true);
    }

    private void getUserId(Result result) {
        final String userId =  Radar.getUserId();
        result.success(userId);
    }

    private void setMetadata(MethodCall call, Result result) {
        final HashMap metadata = (HashMap) call.argument("metadata");
        JSONObject jsonMetadata = new JSONObject(metadata);
        // does this only work for strings?
        Radar.setMetadata(jsonMetadata);
        result.success(null);
    }

    private void setDescription(MethodCall call, Result result) {
        final String description = call.argument("description");
        Radar.setDescription(description);
        result.success(null);
    }

    private void getDescription(Result result) {
        final String currentDescription = Radar.getDescription();
        result.success(currentDescription);
    }

    private void trackOnce(MethodCall call, final Result result) {
        Radar.RadarTrackCallback callback = new Radar.RadarTrackCallback() {
            @Override
            public void onComplete(final Radar.RadarStatus status, final Location location, final RadarEvent[] events, final RadarUser user) {
                runOnMainThread(new Runnable() {
                    @Override
                    public void run() {
                        JSONObject obj = new JSONObject();
                        try {
                            obj.put("status", status.toString());
                            if (location != null) {
                                obj.put("location", Radar.jsonForLocation(location));
                            }
                            if (events != null) {
                                obj.put("events", RadarEvent.toJson(events));
                            }                                     if (events != null) {
                                obj.put("events", RadarEvent.toJson(events));
                            }
                            if (user != null) {
                                obj.put("user", user.toJson());
                            }
                        } catch (JSONException e) {
                            result.error("TRACK_ONCE_ERROR", "An unexcepted error happened during the trackOnce callback logic" + e.getMessage(), null);
                        }
                        HashMap<String,Object> hObj = new Gson().fromJson(obj.toString(), HashMap.class);
                        result.success(hObj);
                    }});
            }
        };
        if (call.argument("location") != null) {
            final HashMap locationMap = (HashMap) call.argument("location");
            double latitude = (Double) locationMap.get("latitude");
            double longitude = (Double) locationMap.get("longitude");
            double accuracy = (Double) locationMap.get("accuracy");
            float fAccuracy = (float)accuracy;
            Location location = new Location("RadarFlutterPlugin");
            location.setLatitude(latitude);
            location.setLongitude(longitude);
            location.setAccuracy(fAccuracy);
            Radar.trackOnce(location, callback);
        }
        else {
            Radar.trackOnce(callback);
        }
    }

    private void startTracking(MethodCall call, Result result) {
        final String preset = call.argument("preset");
        switch (preset) {
            case "efficient":
                Radar.startTracking(RadarTrackingOptions.EFFICIENT);
                break;
            case "continuous":
                Radar.startTracking(RadarTrackingOptions.CONTINUOUS);
                break;
            case "responsive":
                Radar.startTracking(RadarTrackingOptions.RESPONSIVE);
                break;
            default:
                Radar.startTracking(RadarTrackingOptions.EFFICIENT);
                break;
        }
        result.success(null);
    }

    private void startTrackingCustom(MethodCall call, Result result) {
        final JSONObject trackingOptions = (JSONObject) call.arguments;
        RadarTrackingOptions options = RadarTrackingOptions.fromJson(trackingOptions);
        Radar.startTracking(options);
        result.success(null);
    }

    private void stopTracking(Result result) {
        Radar.stopTracking();
        result.success(null);
    }

    private void isTracking(Result result) {
        final Boolean isTracking = Radar.isTracking();
        result.success(isTracking);
    }
};