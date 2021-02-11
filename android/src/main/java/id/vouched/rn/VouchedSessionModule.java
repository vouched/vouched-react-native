package id.vouched.rn;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.function.Consumer;

import id.vouched.android.CardDetectResult;
import id.vouched.android.VouchedSession;
import id.vouched.android.model.JobResponse;
import id.vouched.android.model.Params;
import id.vouched.android.model.SessionType;
import id.vouched.android.model.error.VouchedError;

public class VouchedSessionModule extends ReactContextBaseJavaModule {

    private static final String SESSION_NOT_CONFIGURED = "SESSION_NOT_CONFIGURED";
    private static final String POST_FRONT_ID_FAIL = "POST_FRONT_ID_FAIL";
    private static final String POST_FACE_FAIL = "POST_FACE_FAIL";
    private static final String CONFIRM_FAIL = "CONFIRM_FAIL";

    private VouchedSession session;

    public VouchedSessionModule(@Nullable ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @NonNull
    @Override
    public String getName() {
        return "VouchedSession";
    }

    @ReactMethod
    public void configure(String apiKey) {
        session = new VouchedSession(SessionType.idVerificationWithFace, apiKey);
    }

    @ReactMethod
    public void postFrontId(ReadableMap detectResult, final Promise promise) {
        if (session == null) {
            promise.reject(SESSION_NOT_CONFIGURED, "session must be configured");
            return;
        }

        String distanceImage = detectResult.getString("distanceImage");
        String image = detectResult.getString("image");

        CardDetectResult cardDetectResult = new CardDetectResult(null, null, image, distanceImage);

        try {
            session.postFrontId(getReactApplicationContext(), cardDetectResult, new Params.Builder(), new Consumer<JobResponse>() {
                @Override
                public void accept(JobResponse jobResponse) {
                    VouchedError jobError = jobResponse.getError();
                    if (jobError != null) {
                        promise.reject(POST_FRONT_ID_FAIL, jobError.getMessage());
                    } else {
                        promise.resolve(jobResponse.getJob().toJson());
                    }
                }
            });
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void postFace(ReadableMap detectResult, final Promise promise) {
        if (session == null) {
            promise.reject(SESSION_NOT_CONFIGURED, "session must be configured");
            return;
        }

        String distanceImage = detectResult.getString("userDistanceImage");
        String image = detectResult.getString("image");

//        TODO: update SDK for this use case
//        FaceDetectResult faceDetectResult = new FaceDetectResult(null, null, image, distanceImage);

        try {
//            session.postFrontId(getReactApplicationContext(), faceDetectResult, new Params.Builder(), new Consumer<JobResponse>() {
            session.postFace(getReactApplicationContext(), image, new Params.Builder(), new Consumer<JobResponse>() {
                @Override
                public void accept(JobResponse jobResponse) {
                    VouchedError jobError = jobResponse.getError();
                    if (jobError != null) {
                        promise.reject(POST_FACE_FAIL, jobError.getMessage());
                    } else {
                        promise.resolve(jobResponse.getJob().toJson());
                    }
                }
            });
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void confirm(final Promise promise) {
        if (session == null) {
            promise.reject(SESSION_NOT_CONFIGURED, "session must be configured");
            return;
        }

        try {
            session.confirm(getReactApplicationContext(), new Params.Builder(), new Consumer<JobResponse>() {
                @Override
                public void accept(JobResponse jobResponse) {
                    VouchedError jobError = jobResponse.getError();
                    if (jobError != null) {
                        promise.reject(CONFIRM_FAIL, jobError.getMessage());
                    } else {
                        promise.resolve(jobResponse.getJob().toJson());
                    }
                }
            });
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
