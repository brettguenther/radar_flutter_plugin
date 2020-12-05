package com.bg.radar_flutter_plugin;

import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.Iterator;

public class FlutterRadarUtils {
//    static WritableMap mapForJson(JSONObject obj) throws JSONException {
//        if (obj == null) {
//            return null;
//        }
//
//        WritableMap writableMap = new WritableNativeMap();
//        Iterator<String> iterator = obj.keys();
//        while (iterator.hasNext()) {
//            String key = iterator.next();
//            Object value = obj.get(key);
//            if (value instanceof JSONObject) {
//                writableMap.putMap(key, mapForJson((JSONObject)value));
//            } else if (value instanceof JSONArray) {
//                writableMap.putArray(key, arrayForJson((JSONArray)value));
//            } else if (value instanceof  Boolean) {
//                writableMap.putBoolean(key, (Boolean)value);
//            } else if (value instanceof Integer) {
//                writableMap.putInt(key, (Integer)value);
//            } else if (value instanceof Double) {
//                writableMap.putDouble(key, (Double)value);
//            } else if (value instanceof String)  {
//                writableMap.putString(key, (String)value);
//            }
//        }
//        return writableMap;
//    }
    public static HashMap<String, String> jsonToMap(String t) throws JSONException {

        HashMap<String, String> map = new HashMap<String, String>();
        JSONObject jObject = new JSONObject(t);
        Iterator<?> keys = jObject.keys();

        while( keys.hasNext() ){
            String key = (String)keys.next();
            String value = jObject.getString(key);
            map.put(key, value);

        }
        return map;
//        System.out.println("json : "+jObject);
//        System.out.println("map : "+map);
    }
}
