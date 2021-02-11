package id.vouched.rn;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.media.Image;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.android.cameraview.CameraView;

import java.nio.ByteBuffer;
import java.util.Timer;
import java.util.TimerTask;
import java.util.function.Consumer;

import id.vouched.android.CardDetect;
import id.vouched.android.CardDetectResult;
import id.vouched.android.Step;
import id.vouched.android.env.ImageUtils;
import id.vouched.android.CardDetectOptions;

public class IdCameraView extends CameraView implements LifecycleEventListener {
    public static final String ON_ID_STREAM_EVENT = "onIdStream";

    private final ThemedReactContext mThemedReactContext;
    private int[] rgbBytes;
    private byte[][] yuvBytes = new byte[3][];
    private boolean isProcessingFrame = false;

    private CardDetect cardDetect;

    public IdCameraView(ThemedReactContext themedReactContext, boolean fallbackToOldApi) {
        super(themedReactContext, true);
        mThemedReactContext = themedReactContext;
        themedReactContext.addLifecycleEventListener(this);

        addCallback(new Callback() {

            @Override
            public void onCameraOpened(CameraView cameraView) {
                super.onCameraOpened(cameraView);
            }

            @Override
            public void onCameraClosed(CameraView cameraView) {
                super.onCameraClosed(cameraView);
            }

            @Override
            public void onPictureTaken(CameraView cameraView, byte[] data, int deviceOrientation) {
                super.onPictureTaken(cameraView, data, deviceOrientation);
            }

            @Override
            public void onRecordingStart(CameraView cameraView, String path, int videoOrientation, int deviceOrientation) {
                super.onRecordingStart(cameraView, path, videoOrientation, deviceOrientation);
            }

            @Override
            public void onRecordingEnd(CameraView cameraView) {
                super.onRecordingEnd(cameraView);
            }

            @Override
            public void onVideoRecorded(CameraView cameraView, String path, int videoOrientation, int deviceOrientation) {
                super.onVideoRecorded(cameraView, path, videoOrientation, deviceOrientation);
            }

            @Override
            public void onFramePreview(CameraView cameraView, final Image.Plane[] planes, final int width, final int height, int orientation) {
                super.onFramePreview(cameraView, planes, width, height, orientation);

                if (isProcessingFrame) {
                    return;
                }

                if (cardDetect != null) {
                    isProcessingFrame = true;

                    if (rgbBytes == null) {
                        rgbBytes = new int[width * height];
                    }

                    fillBytes(planes, yuvBytes);
                    final int yRowStride = planes[0].getRowStride();
                    final int uvRowStride = planes[1].getRowStride();
                    final int uvPixelStride = planes[1].getPixelStride();

                    Runnable convertImageAndDetect = new Runnable() {
                        @Override
                        public void run() {
                            Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

                            ImageUtils.convertYUV420ToARGB8888(
                                    yuvBytes[0],
                                    yuvBytes[1],
                                    yuvBytes[2],
                                    width,
                                    height,
                                    yRowStride,
                                    uvRowStride,
                                    uvPixelStride,
                                    rgbBytes);

                            bitmap.setPixels(rgbBytes, 0, width, 0, 0, width, height);
                            cardDetect.processImage(bitmap, null, null, mBgHandler);
                        }
                    };

                    mBgHandler.post(convertImageAndDetect);
                }
            }

            @Override
            public void onMountError(CameraView cameraView) {
                super.onMountError(cameraView);
            }
        });
    }

    @Override
    public void stop() {
        super.stop();
    }


    public void setEnableDistanceCheck(boolean enableDistanceCheck) {
        cardDetect = new CardDetect(
                mThemedReactContext.getCurrentActivity().getAssets(),
                new CardDetectOptions.Builder().withEnableDistanceCheck(enableDistanceCheck).build(),
                new Consumer<CardDetectResult>() {
                    @Override
                    public void accept(CardDetectResult cardDetectResult) {
                        sendCardDetectEvent(cardDetectResult);
                        // if result is postable, give time to stop camera
                        if (Step.POSTABLE.equals(cardDetectResult.getStep())) {
                            Timer timer = new Timer();
                            timer.schedule(new TimerTask() {
                                @Override
                                public void run() {
                                    isProcessingFrame = false;
                                }
                            }, 1000);
                        } else {
                            isProcessingFrame = false;
                        }
                    }
                });
    }

    private void sendCardDetectEvent(CardDetectResult cardDetectResult) {
        WritableMap event = Arguments.createMap();
        event.putString("step", cardDetectResult.getStep().name());
        event.putString("instruction", cardDetectResult.getInstruction().name());
        event.putString("image", cardDetectResult.getImage());
        event.putString("distanceImage", cardDetectResult.getDistanceImage());
        mThemedReactContext
                .getJSModule(RCTEventEmitter.class)
                .receiveEvent(getId(), ON_ID_STREAM_EVENT, event);
    }

    protected void fillBytes(final Image.Plane[] planes, final byte[][] yuvBytes) {
        // Because of the variable row stride it's not possible to know in
        // advance the actual necessary dimensions of the yuv planes.
        for (int i = 0; i < planes.length; ++i) {
            final ByteBuffer buffer = planes[i].getBuffer();
            if (yuvBytes[i] == null) {
                yuvBytes[i] = new byte[buffer.capacity()];
            }
            buffer.get(yuvBytes[i]);
        }
    }

    @Override
    public void onHostResume() {
        start();
    }

    @Override
    public void onHostPause() {
    }

    @Override
    public void onHostDestroy() {
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void requestLayout() {
        // React handles this for us, so we don't need to call super.requestLayout();
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        View preview = getView();
        if (null == preview) {
            return;
        }
        float width = right - left;
        float height = bottom - top;
        float ratio = getAspectRatio().toFloat();
        int orientation = getResources().getConfiguration().orientation;
        int correctHeight;
        int correctWidth;
        this.setBackgroundColor(Color.BLACK);
        if (orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE) {
            if (ratio * height < width) {
                correctHeight = (int) (width / ratio);
                correctWidth = (int) width;
            } else {
                correctWidth = (int) (height * ratio);
                correctHeight = (int) height;
            }
        } else {
            if (ratio * width > height) {
                correctHeight = (int) (width * ratio);
                correctWidth = (int) width;
            } else {
                correctWidth = (int) (height / ratio);
                correctHeight = (int) height;
            }
        }
        int paddingX = (int) ((width - correctWidth) / 2);
        int paddingY = (int) ((height - correctHeight) / 2);
        preview.layout(paddingX, paddingY, correctWidth + paddingX, correctHeight + paddingY);
    }

}

