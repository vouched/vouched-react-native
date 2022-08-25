package id.vouched.rn;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
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

import id.vouched.android.BarcodeDetect;
import id.vouched.android.BarcodeResult;
import id.vouched.android.exception.VouchedAssetsMissingException;

public class BarcodeCameraView extends ConstraintLayout 
    implements LifecycleEventListener, BarcodeDetect.OnBarcodeResultListener {

    public static final String ON_BARCODE_STREAM_EVENT = "onBarcodeStream";
    private static final Size DESIRED_PREVIEW_BARCODE_SIZE = new Size(1080, 1920);

    private final ThemedReactContext mThemedReactContext;
    private final CameraSelector cameraSelector;
    private final Activity activity;
    private PreviewView previewView;
    private ProcessCameraProvider cameraProvider;
    private Preview previewUseCase;
    private ImageAnalysis analysisUseCase;

    private Handler handler;
    private HandlerThread handlerThread;

    private BarcodeDetect barcodeDetect;

    private boolean isRendered = false;
    private boolean isStopped = false;

    public BarcodeCameraView(@NonNull ThemedReactContext themedReactContext) {
        super(themedReactContext);
        mThemedReactContext = themedReactContext;
        activity = themedReactContext.getCurrentActivity();
        barcodeDetect = new BarcodeDetect(this);
        cameraSelector = new CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build();

        ConstraintLayout layout = (ConstraintLayout) LayoutInflater.from(themedReactContext).inflate(R.layout.id_camera, this, true);
        previewView = layout.findViewById(R.id.preview_view);
        if (previewView == null) {
            System.out.println("previewView is null");
        }

        handlerThread = new HandlerThread("inference");
        handlerThread.start();
        handler = new Handler(handlerThread.getLooper());

        startCamera();
        setupLayoutHack();
    }

    @Override
    public void onHostResume() {
        handlerThread = new HandlerThread("inference");
        handlerThread.start();
        handler = new Handler(handlerThread.getLooper());
        bindAllCameraUseCases();
    }

    @Override
    public void onHostPause() {
        if (handlerThread != null) {
            handlerThread.quitSafely();
            try {
                handlerThread.join();
                handlerThread = null;
                handler = null;
            } catch (final InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onHostDestroy() {
        if (cameraProvider != null) {
            cameraProvider.unbindAll();
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
        builder.setTargetResolution(DESIRED_PREVIEW_BARCODE_SIZE);
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
        builder.setTargetResolution( DESIRED_PREVIEW_BARCODE_SIZE);
        analysisUseCase = builder.build();

        analysisUseCase.setAnalyzer(
                ContextCompat.getMainExecutor(activity),
                new ImageAnalysis.Analyzer() {
                    @SuppressLint("UnsafeExperimentalUsageError")
                    @Override
                    public void analyze(@NonNull ImageProxy imageProxy) {
                        try {
                            if (barcodeDetect != null) {
                                barcodeDetect.findBarcode(imageProxy);
                            } 
                        } catch (Exception e) {
                            System.out.println("Failed to process image. Error: " + e.getLocalizedMessage());
                        }
                    }
                });

        cameraProvider.bindToLifecycle((LifecycleOwner) activity, cameraSelector, analysisUseCase);
    }

    @Override
    public void onBarcodeResult(BarcodeResult barcodeResult) {
        if (barcodeResult != null) {
            isRendered = true;
            sendBarcodeDetectEvent(barcodeResult);
        }
    }

    private void sendBarcodeDetectEvent(BarcodeResult barcodeResult) {
        WritableMap event = Arguments.createMap();
        event.putString("value", barcodeResult.getValue());
        event.putString("image", barcodeResult.getImage());
        mThemedReactContext
                .getJSModule(RCTEventEmitter.class)
                .receiveEvent(getId(), ON_BARCODE_STREAM_EVENT, event);
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
    }

    public void start() {
        bindAllCameraUseCases();
        isStopped = false;
        isRendered = false;
    }

}

