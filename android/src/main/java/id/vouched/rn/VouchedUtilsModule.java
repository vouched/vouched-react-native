package id.vouched.rn;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.List;

import id.vouched.android.VouchedUtils;
import id.vouched.android.model.Insight;
import id.vouched.android.model.Job;
import id.vouched.rn.utils.ReactNativeJson;

public class VouchedUtilsModule extends ReactContextBaseJavaModule {

    public VouchedUtilsModule(@Nullable ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @NonNull
    @Override
    public String getName() {
        return "VouchedUtils";
    }

    @ReactMethod
    public void extractInsights(ReadableMap jobMap, final Promise promise) {

        try {
            JSONObject jobJson = ReactNativeJson.convertMapToJson(jobMap);
            Job job = Job.fromJson(jobJson.toString());
            List<Insight> insights = VouchedUtils.extractInsights(job);
            promise.resolve(new Gson().toJson(insights));
        } catch (JSONException e) {
            promise.reject(e);
        }
    }
}
