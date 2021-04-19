

import UIKit
import VideoToolbox
import Vouched

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
    
    override func didOutput(pixelBuffer: CVPixelBuffer) {
        super.didOutput(pixelBuffer: pixelBuffer)
        runModel(onPixelBuffer: pixelBuffer)
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
    @objc func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {

        if currentLivenessMode != livenessMode {
            currentLivenessMode = livenessMode
            faceDetect = FaceDetect(options: FaceDetectOptionsBuilder().withLivenessMode(toLiveness(currentLivenessMode)).build())
        }
        
        let faecDetectResult = faceDetect.detect(pixelBuffer);
        if faecDetectResult == nil {
            onFaceStream!(["userDistanceImage": nil, "image": nil, "instruction" : "NO_FACE", "step": "PRE_DETECTED"]);
        } else {
            onFaceStream!([
                            "userDistanceImage": faecDetectResult?.distanceImage,
                            "image": faecDetectResult?.image,
                            "instruction" : toInstructionName(faecDetectResult!.instruction),
                            "step": toStepName(faecDetectResult!.step)]
            );
            if faecDetectResult!.step == Step.postable {
                sleep(1)
            }
        }
        
        
    }
}
