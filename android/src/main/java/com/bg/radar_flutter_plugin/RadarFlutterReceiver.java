package com.bg.radar_flutter_plugin;

import android.content.Context;
import android.location.Location;
import android.util.Log;

import io.radar.sdk.Radar;
import io.radar.sdk.RadarReceiver;
import io.radar.sdk.model.RadarEvent;
import io.radar.sdk.model.RadarUser;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import com.google.gson.Gson;

public class RadarFlutterReceiver extends RadarReceiver {
    @Override
    public void onEventsReceived(Context context, RadarEvent[] events, RadarUser user) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("events", RadarEvent.toJson(events));
            obj.put("user", user.toJson());
            HashMap<String,Object> hObj = new Gson().fromJson(obj.toString(), HashMap.class);
            // RadarFlutterPlugin.channel.invokeMethod("onEvents",hObj);
            RadarFlutterPlugin.eventStreamHandler.send(hObj);
        } catch (JSONException e) {
            Log.d("RadarFlutterPlugin", "Error in client location handling: " + e.getMessage());
        }
//            invokeMethodOnUiThread("clientLocation",hObj);
//            this.channel.invokeMethod("clientLocation",hObj);
    }

    public void onClientLocationUpdated(Context context, Location location, boolean stopped, Radar.RadarLocationSource locationSource) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("location", Radar.jsonForLocation(location));
            obj.put("stopped", stopped);
            obj.put("locationSource", locationSource.name());
            HashMap<String,Object> hObj = new Gson().fromJson(obj.toString(), HashMap.class);
//             RadarFlutterPlugin.channel.invokeMethod("onClientLocation",hObj);
            RadarFlutterPlugin.clientLocationStreamHandler.send(hObj);
        } catch (JSONException e) {
            Log.d("RadarFlutterPlugin", "Error in client location handling: "  + e.getMessage());
        }
//            invokeMethodOnUiThread("clientLocation",hObj);
//            this.channel.invokeMethod("clientLocation",hObj);
    }

    @Override
    public void onLocationUpdated(Context context, Location location, RadarUser user) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("location", Radar.jsonForLocation(location));
            obj.put("user", user.toJson());
            HashMap<String,Object> hObj = new Gson().fromJson(obj.toString(), HashMap.class);
            // RadarFlutterPlugin.channel.invokeMethod("onLocation",hObj);
            RadarFlutterPlugin.locationStreamHandler.send(hObj);
        } catch (JSONException e) {
            Log.d("RadarFlutterPlugin", "Error in location handling: "  + e.getMessage());
        }
    }

    @Override
    public void onError(Context context, Radar.RadarStatus status) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("status", status.toString());
            HashMap<String,Object> hObj = new Gson().fromJson(obj.toString(), HashMap.class);
            // RadarFlutterPlugin.channel.invokeMethod("onError",hObj);
            RadarFlutterPlugin.errorStreamHandler.send(hObj);
        } catch (JSONException e) {
            Log.d("RadarFlutterPlugin", "Error in error handling:  "  + e.getMessage());
        }
    }

    @Override
    public void onLog(Context context,String message) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("message", message);
            HashMap<String,Object> hObj = new Gson().fromJson(obj.toString(), HashMap.class);
            // RadarFlutterPlugin.channel.invokeMethod("onLog",hObj);
            RadarFlutterPlugin.logStreamHandler.send(hObj);
        } catch (JSONException e) {
            Log.d("RadarFlutterPlugin", "Error in log handling:  "  + e.getMessage());
        }
    }
}