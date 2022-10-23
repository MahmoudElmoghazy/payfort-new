package com.reactnativepayfort;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.bridge.Callback;

import com.payfort.fortpaymentsdk.FortSdk;
import com.payfort.fortpaymentsdk.callbacks.FortCallBackManager;
import com.payfort.fortpaymentsdk.callbacks.FortCallback;
import com.payfort.fortpaymentsdk.callbacks.FortInterfaces;
import com.payfort.fortpaymentsdk.domain.model.FortRequest;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

@ReactModule(name = PayfortModule.NAME)
public class PayfortModule extends ReactContextBaseJavaModule
  implements ActivityEventListener {

  public static final String NAME = "Payfort";

  private FortCallBackManager fortCallback = FortCallback.Factory.create();
  private static ReactApplicationContext reactContext;

  private Activity context = null;

  public PayfortModule(ReactApplicationContext reactContext) {
        super(reactContext);

        this.reactContext = reactContext;
        this.reactContext.addActivityEventListener(this);

        this.context = getCurrentActivity();
   }


    @Override
    @NonNull
    public String getName() {
        return NAME;
    }


    @ReactMethod
    public void getDeviceId(Callback successCallback){
        try {
          successCallback.invoke(FortSdk.getDeviceId(getCurrentActivity()));
        catch (Exception e) {
          Log.d("Exception", String.valueOf(e));
        }
    }

    @ReactMethod
    public void Pay(String parameters, Callback successCallback, Callback errorCallback) {
      try {
        Map<String, Object> map = new TreeMap<String, Object>();
        JSONObject jsonObject = new JSONObject(parameters);

        String ENV = jsonObject.getBoolean("isLive") ? FortSdk.ENVIRONMENT.PRODUCTION : FortSdk.ENVIRONMENT.TEST;

        for (Iterator<String> it = jsonObject.keys(); it.hasNext(); ) {
          String key = it.next();

          if(!key.equals("isLive")) {
            map.put(key, jsonObject.get(key).toString());
          }
        }

        // .. create fucking request
        FortRequest fortrequest = new FortRequest();
        fortrequest.setRequestMap(map);

        context = getCurrentActivity();

        FortSdk.getInstance().registerCallback(context, fortrequest, ENV, 5, fortCallback, true, new FortInterfaces.OnTnxProcessed() {
          @Override
          public void onCancel(Map<String, Object> requestMap, Map<String, Object> responseMap) {
            // Toast.makeText(reactContext, "Payment cancel by user", Toast.LENGTH_SHORT).show();
            Log.d("Hello", "onCancel() called with: map = [" + requestMap + "], map1 = [" + responseMap + "]");
            errorCallback.invoke(converMapToJson(responseMap));
          }

          @Override
          public void onSuccess(Map<String, Object> requestMap, Map<String, Object> responseMap) {
            //Toast.makeText(reactContext, "Payment Success", Toast.LENGTH_SHORT).show();
            Log.d("Hello", "onSuccess() called with: map = [" + requestMap + "], map1 = [" + responseMap + "]");
            successCallback.invoke(converMapToJson(responseMap));

          }

          @Override
          public void onFailure(Map<String, Object> requestMap, Map<String, Object> responseMap) {
            //Toast.makeText(reactContext, "Payment fail", Toast.LENGTH_SHORT).show();
            Log.d("Hello", "onFailure() called with: map = [" + requestMap + "], map1 = [" + responseMap + "]");
            errorCallback.invoke(converMapToJson(responseMap));
          }
        });
      } catch (Exception e) {
        Log.d("Exception", String.valueOf(e));
//        errorCallback.invoke(e);
      }

    }

  private String converMapToJson(Map<String, Object> source){
    Gson gson=new Gson();
    Type gsonType = new TypeToken<HashMap>(){}.getType();
    String gsonString = gson.toJson(source,gsonType);
    return gsonString;
  }

  @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    try {
        fortCallback.onActivityResult(requestCode, resultCode, data);
    }  catch (Exception e) {
            Log.d("Exception", String.valueOf(e));
          }
      }

  @Override
  public void onNewIntent(Intent intent) {

  }


}
