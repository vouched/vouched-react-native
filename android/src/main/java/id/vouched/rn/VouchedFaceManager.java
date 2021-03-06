package id.vouched.rn;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class VouchedFaceManager extends SimpleViewManager<FaceCameraView> {

    public static final int COMMAND_FACE_CAMERA_STOP = 87;
    public static final int COMMAND_FACE_CAMERA_START = 95;

    @NonNull
    @Override
    public String getName() {
        return "FaceCamera";
    }

    @NonNull
    @Override
    protected FaceCameraView createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new FaceCameraView(reactContext);
    }

    @ReactProp(name = "livenessMode")
    public void setLivenessMode(FaceCameraView view, String livenessMode) {
        view.setLivenessMode(livenessMode);
    }

    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                FaceCameraView.ON_FACE_STREAM_EVENT,
                MapBuilder.of("registrationName", FaceCameraView.ON_FACE_STREAM_EVENT)
        );
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                "stop", COMMAND_FACE_CAMERA_STOP,
                "restart", COMMAND_FACE_CAMERA_START
        );
    }

    @Override
    public void receiveCommand(@NonNull FaceCameraView root, int commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_FACE_CAMERA_STOP:
                root.stop();
                break;
            case COMMAND_FACE_CAMERA_START:
                root.start();
                break;
        }
    }
}
