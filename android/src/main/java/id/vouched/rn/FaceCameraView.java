package id.vouched.rn;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.util.Size;
import android.view.Choreographer;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.ExecutionException;

import id.vouched.android.FaceDetect;
import id.vouched.android.FaceDetectOptions;
import id.vouched.android.FaceDetectResult;
import id.vouched.android.liveness.LivenessMode;

public class FaceCameraView extends ConstraintLayout implements LifecycleEventListener, FaceDetect.OnDetectResultListener {
    public static final String ON_FACE_STREAM_EVENT = "onFaceStream";
    private static final Size DESIRED_PREVIEW_SIZE = new Size(720, 1280);

    private final ThemedReactContext mThemedReactContext;
    private final CameraSelector cameraSelector;
    private final Activity activity;
    private PreviewView previewView;
    private ProcessCameraProvider cameraProvider;
    private Preview previewUseCase;
    private ImageAnalysis analysisUseCase;

    private FaceDetect faceDetect;

    private boolean isRendered = false;
    private boolean isStopped = false;

    public FaceCameraView(@NonNull ThemedReactContext themedReactContext) {
        super(themedReactContext);

        mThemedReactContext = themedReactContext;
        activity = themedReactContext.getCurrentActivity();
        faceDetect = new FaceDetect(themedReactContext, FaceDetectOptions.defaultOptions(), this);
        cameraSelector = new CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_FRONT).build();

        ConstraintLayout layout = (ConstraintLayout) LayoutInflater.from(themedReactContext).inflate(R.layout.face_camera, this, true);
        previewView = layout.findViewById(R.id.preview_view);
        if (previewView == null) {
            System.out.println("previewView is null");
        }

        startCamera();
        setupLayoutHack();
    }

    public void setLivenessMode(String value) {
        try {
            LivenessMode livenessMode = LivenessMode.valueOf(value);
            faceDetect = new FaceDetect(mThemedReactContext, new FaceDetectOptions.Builder().withLivenessMode(livenessMode).build(), this);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            faceDetect = new FaceDetect(mThemedReactContext, new FaceDetectOptions.Builder().withLivenessMode(LivenessMode.NONE).build(), this);
        }

    }

    @Override
    public void onHostResume() {
        if (faceDetect != null) {
            faceDetect.resume();
        }
        bindAllCameraUseCases();
    }

    @Override
    public void onHostPause() {
        if (cameraProvider != null) {
            cameraProvider.unbindAll();
        }
        if (faceDetect != null) {
            faceDetect.stop();
        }
    }

    @Override
    public void onHostDestroy() {
        if (cameraProvider != null) {
            cameraProvider.unbindAll();
        }
        if (faceDetect != null) {
            faceDetect.stop();
        }
    }


    private void startCamera() {
        final ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(mThemedReactContext);
        cameraProviderFuture.addListener(new Runnable() {
            @Override
            public void run() {
                try {
                    cameraProvider = cameraProviderFuture.get();
                    bindAllCameraUseCases();
                } catch (ExecutionException | InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, ContextCompat.getMainExecutor(mThemedReactContext));
    }

    private void bindAllCameraUseCases() {
        if (cameraProvider != null) {
            // As required by CameraX API, unbinds all use cases before trying to re-bind any of them.
            cameraProvider.unbindAll();
            bindPreviewUseCase();
            bindAnalysisUseCase();
        }
    }

    private void bindPreviewUseCase() {
        if (cameraProvider == null) {
            return;
        }
        if (previewUseCase != null) {
            cameraProvider.unbind(previewUseCase);
        }

        Preview.Builder builder = new Preview.Builder();
        builder.setTargetResolution(DESIRED_PREVIEW_SIZE);
        previewUseCase = builder.build();
        previewUseCase.setSurfaceProvider(previewView.getSurfaceProvider());
        cameraProvider.bindToLifecycle((LifecycleOwner) activity, cameraSelector, previewUseCase);
    }

    private void bindAnalysisUseCase() {
        if (cameraProvider == null) {
            return;
        }
        if (analysisUseCase != null) {
            cameraProvider.unbind(analysisUseCase);
        }

        ImageAnalysis.Builder builder = new ImageAnalysis.Builder();
        builder.setTargetResolution(DESIRED_PREVIEW_SIZE);
        analysisUseCase = builder.build();

        analysisUseCase.setAnalyzer(
                ContextCompat.getMainExecutor(activity),
                new ImageAnalysis.Analyzer() {
                    @SuppressLint("UnsafeExperimentalUsageError")
                    @Override
                    public void analyze(@NonNull ImageProxy imageProxy) {
                        try {
                            if (faceDetect != null) {
                                faceDetect.processImageProxy(imageProxy, null);
                            }
                        } catch (Exception e) {
                            System.out.println("Failed to process image. Error: " + e.getLocalizedMessage());
                        }
                    }
                });

        cameraProvider.bindToLifecycle((LifecycleOwner) activity, cameraSelector, analysisUseCase);
    }

    @Override
    public void onFaceDetectResult(FaceDetectResult faceDetectResult) {
        isRendered = true;
        sendFaceDetectEvent(faceDetectResult);
    }

    private void sendFaceDetectEvent(FaceDetectResult faceDetectResult) {
        WritableMap event = Arguments.createMap();
        event.putString("step", faceDetectResult.getStep().name());
        event.putString("instruction", faceDetectResult.getInstruction().name());
        event.putString("image", faceDetectResult.getImage());
        event.putString("userDistanceImage", faceDetectResult.getUserDistanceImage());
        mThemedReactContext
                .getJSModule(RCTEventEmitter.class)
                .receiveEvent(getId(), ON_FACE_STREAM_EVENT, event);
    }

    private void setupLayoutHack() {
        Choreographer.getInstance().postFrameCallback(new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                if (isRendered) {
                    Choreographer.getInstance().postFrameCallback(this);
                    return;
                }

                manuallyLayoutChildren();
                getViewTreeObserver().dispatchOnGlobalLayout();
                Choreographer.getInstance().postFrameCallback(this);

            }
        });
    }

    private void manuallyLayoutChildren() {
        for (int i = 0; i < getChildCount(); i++) {
            View child = getChildAt(i);
            child.measure(MeasureSpec.makeMeasureSpec(getMeasuredWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getMeasuredHeight(), MeasureSpec.EXACTLY));
            child.layout(0, 0, child.getMeasuredWidth(), child.getMeasuredHeight());
        }
    }

    public void stop() {
        if (isStopped) return;
        isStopped = true;

        if (cameraProvider != null) {
            cameraProvider.unbindAll();
        }
        if (faceDetect != null) {
            faceDetect.stop();
        }
    }

    public void start() {
        if (faceDetect != null) {
            faceDetect.resume();
        }
        bindAllCameraUseCases();
        isStopped = false;
        isRendered = false;
    }
}
