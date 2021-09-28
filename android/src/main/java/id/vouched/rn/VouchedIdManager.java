package id.vouched.rn;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

import id.vouched.android.exception.VouchedAssetsMissingException;

public class VouchedIdManager extends ViewGroupManager<IdCameraView> {
    public static final int COMMAND_ID_CAMERA_STOP = 15;
    public static final int COMMAND_ID_CAMERA_START = 32;

    @NonNull
    @Override
    public String getName() {
        return "IdCamera";
    }

    @NonNull
    @Override
    protected IdCameraView createViewInstance(@NonNull ThemedReactContext reactContext) {
        IdCameraView view = null;
        try {
            view = new IdCameraView(reactContext);
        } catch (VouchedAssetsMissingException e) {
            e.printStackTrace();
        }
        return view;
    }

    @ReactProp(name = "enableDistanceCheck")
    public void setEnableDistanceCheck(IdCameraView view, boolean enableDistanceCheck) throws VouchedAssetsMissingException {
        view.setEnableDistanceCheck(enableDistanceCheck);
    }

    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                IdCameraView.ON_ID_STREAM_EVENT,
                MapBuilder.of("registrationName", IdCameraView.ON_ID_STREAM_EVENT)
        );
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                "stop", COMMAND_ID_CAMERA_STOP,
                "restart", COMMAND_ID_CAMERA_START
        );
    }

    @Override
    public void receiveCommand(@NonNull IdCameraView root, int commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_ID_CAMERA_STOP:
                root.stop();
                break;
            case COMMAND_ID_CAMERA_START:
                root.start();
                break;
        }
    }
}
