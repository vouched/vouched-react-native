package id.vouched.rn;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;

import id.vouched.android.CardDetectResult;
import id.vouched.android.FaceDetectResult;
import id.vouched.android.VouchedSession;
import id.vouched.android.VouchedSessionParameters;
import id.vouched.android.model.AuthenticationResponse;
import id.vouched.android.model.JobResponse;
import id.vouched.android.model.Params;
import id.vouched.android.model.error.VouchedError;

public class VouchedSessionModule extends ReactContextBaseJavaModule {

    private static final String SESSION_NOT_CONFIGURED = "SESSION_NOT_CONFIGURED";
    private static final String POST_FRONT_ID_FAIL = "POST_FRONT_ID_FAIL";
    private static final String POST_FACE_FAIL = "POST_FACE_FAIL";
    private static final String CONFIRM_FAIL = "CONFIRM_FAIL";
    private static final String POST_AUTHENTICATE_FAIL = "POST_AUTHENTICATE_FAIL";

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
    public void configure(String apiKey, ReadableMap sessionParams) {
        VouchedSessionParameters.Builder builder = new VouchedSessionParameters.Builder()
                .withCallbackURL(sessionParams.getString("callbackURL"))
                .withGroupId(sessionParams.getString("groupId"));

        ReadableArray properties = sessionParams.getArray("properties");
        if (properties != null && properties.size() > 0) {
            for (int i = 0; i < properties.size(); i++) {
                if (ReadableType.Map.equals(properties.getType(i))) {
                    ReadableMap map = properties.getMap(i);
                    if (map != null) {
                        String name = map.getString("name");
                        String value = map.getString("value");
                        if (name != null && value != null) {
                            builder.addProperty(name, value);
                        }
                    }
                }
            }
        }

        VouchedSessionParameters vouchedSessionParameters = builder.build();
        session = new VouchedSession(apiKey, vouchedSessionParameters);
    }

    @ReactMethod
    public void postFrontId(ReadableMap detectResult, ReadableMap parameters, final Promise promise) {
        if (session == null) {
            promise.reject(SESSION_NOT_CONFIGURED, "session must be configured");
            return;
        }

        String distanceImage = detectResult.getString("distanceImage");
        String image = detectResult.getString("image");

        CardDetectResult cardDetectResult = new CardDetectResult(null, null, image, distanceImage);

        Params.Builder builder = new Params.Builder()
                .withBirthDate(parameters.getString("birthDate"))
                .withEmail(parameters.getString("email"))
                .withFirstName(parameters.getString("firstName"))
                .withLastName(parameters.getString("lastName"))
                .withPhone(parameters.getString("phone"));
        try {
            session.postFrontId(getReactApplicationContext(), cardDetectResult, builder, new VouchedSession.OnJobResponseListener() {
                @Override
                public void onJobResponse(JobResponse jobResponse) {
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

        FaceDetectResult faceDetectResult = new FaceDetectResult(null, null, image, distanceImage);

        try {
            session.postFace(getReactApplicationContext(), faceDetectResult, new Params.Builder(), new VouchedSession.OnJobResponseListener() {
                @Override
                public void onJobResponse(JobResponse jobResponse) {
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
    public void postAuthenticate(ReadableMap authRequest, final Promise promise) {

        if (session == null) {
            promise.reject(SESSION_NOT_CONFIGURED, "session must be configured");
            return;
        }

        String image = authRequest.getString("image");
        String jobId = authRequest.getString("jobId");
        boolean matchId = authRequest.getBoolean("matchId");

        FaceDetectResult faceDetectResult = new FaceDetectResult(null, null, image, null);

        try {
            session.postAuthenticate(getReactApplicationContext(), jobId, faceDetectResult, matchId, new VouchedSession.OnAuthenticationResponseListener() {
                @Override
                public void onAuthenticationResponse(AuthenticationResponse response) {
                    VouchedError vouchedError = response.getError();
                    if (vouchedError != null) {
                        promise.reject(POST_AUTHENTICATE_FAIL, vouchedError.getMessage());
                    } else {
                        promise.resolve(response.getResult().toJson());
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
            session.confirm(getReactApplicationContext(), new Params.Builder(), new VouchedSession.OnJobResponseListener() {
                @Override
                public void onJobResponse(JobResponse jobResponse) {
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
