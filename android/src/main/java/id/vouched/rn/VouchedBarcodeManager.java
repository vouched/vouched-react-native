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

public class VouchedBarcodeManager extends ViewGroupManager<BarcodeCameraView> {
    public static final int COMMAND_BARCODE_CAMERA_STOP = 25;
    public static final int COMMAND_BARCODE_CAMERA_START = 624;

    @NonNull
    @Override
    public String getName() {
        return "BarcodeCamera";
    }

    @NonNull
    @Override
    protected BarcodeCameraView createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new BarcodeCameraView(reactContext);
    }

    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                BarcodeCameraView.ON_BARCODE_STREAM_EVENT,
                MapBuilder.of("registrationName", BarcodeCameraView.ON_BARCODE_STREAM_EVENT)
        );
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                "stop", COMMAND_BARCODE_CAMERA_STOP,
                "restart", COMMAND_BARCODE_CAMERA_START
        );
    }

    @Override
    public void receiveCommand(@NonNull BarcodeCameraView root, int commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_BARCODE_CAMERA_STOP:
                root.stop();
                break;
            case COMMAND_BARCODE_CAMERA_START:
                root.start();
                break;
        }
    }
}

