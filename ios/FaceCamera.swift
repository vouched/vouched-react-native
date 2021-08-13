

import UIKit
import VideoToolbox
import VouchedCore

class FaceCamera : BaseCamera {
    
    @objc var onFaceStream: RCTDirectEventBlock?
    @objc var livenessMode: String = "NONE"
    
    private var faceDetect: FaceDetect!
    private var currentLivenessMode: String = "NONE"
    
    init(frame: CGRect) {
        super.init(frame: frame, position: .front)
                
        faceDetect = FaceDetect(options: FaceDetectOptionsBuilder().withLivenessMode(toLiveness(currentLivenessMode)).build())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didOutput(sampleBuffer: CMSampleBuffer) {
        super.didOutput(sampleBuffer: sampleBuffer)
        runModel(onSampleBuffer: sampleBuffer)
    }
    
    @objc override func start() {
        faceDetect = FaceDetect(options: FaceDetectOptionsBuilder().withLivenessMode(toLiveness(currentLivenessMode)).build())
        super.start()
    }
    
    func toLiveness(_ livenessStr: String) -> LivenessMode {
        switch(livenessStr) {
        case "NONE":
            return .none
        case "MOUTH_MOVEMENT":
            return .mouthMovement
        case "DISTANCE":
            return .distance
        case "BLINKING":
            return .blinking
        default:
            return .none
        }
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    @objc func runModel(onSampleBuffer sampleBuffer: CMSampleBuffer) {

        if currentLivenessMode != livenessMode {
            currentLivenessMode = livenessMode
            faceDetect = FaceDetect(options: FaceDetectOptionsBuilder().withLivenessMode(toLiveness(currentLivenessMode)).build())
        }
        
        let faceDetectResult = faceDetect.detect(sampleBuffer);
        if let faceDetectResult = faceDetectResult as? FaceDetectResult {
            onFaceStream!([
                            "userDistanceImage": faceDetectResult.distanceImage,
                            "image": faceDetectResult.image,
                            "instruction" : toInstructionName(faceDetectResult.instruction),
                            "step": toStepName(faceDetectResult.step)]
            );
            if faceDetectResult.step == Step.postable {
                sleep(1)
            }
        } else {
            onFaceStream!(["userDistanceImage": nil, "image": nil, "instruction" : "NO_FACE", "step": "PRE_DETECTED"]);
        }
        
    }
}
