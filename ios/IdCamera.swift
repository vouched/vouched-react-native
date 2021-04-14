

import UIKit
import VideoToolbox
import Vouched

class IdCamera : BaseCamera {
    
    @objc var onIdStream: RCTDirectEventBlock?
    @objc var enableDistanceCheck: Bool = false
    
    private var cardDetect: CardDetect!
    private var currentEnableDistanceCheck: Bool = false
    
    init(frame: CGRect) {
        super.init(frame: frame, position: .back)
                
        cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(currentEnableDistanceCheck).build())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didOutput(pixelBuffer: CVPixelBuffer) {
        super.didOutput(pixelBuffer: pixelBuffer)
        runModel(onPixelBuffer: pixelBuffer)
    }
    
    @objc override func start() {
        cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(currentEnableDistanceCheck).build())
        super.start()
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    @objc func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {

        if currentEnableDistanceCheck != enableDistanceCheck {
            currentEnableDistanceCheck = enableDistanceCheck
            cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(currentEnableDistanceCheck).build())
        }
        
        let cardDetectResult = cardDetect.detect(pixelBuffer);
        if cardDetectResult == nil {
            onIdStream!(["distanceImage": nil, "image": nil, "instruction" : "NO_CARD", "step": "PRE_DETECTED"]);
        } else {
            onIdStream!([
                            "distanceImage": cardDetectResult?.distanceImage,
                            "image": cardDetectResult?.image,
                            "instruction" : toInstructionName(cardDetectResult!.instruction),
                            "step": toStepName(cardDetectResult!.step)]
            );
            if cardDetectResult!.step == Step.postable {
                sleep(1)
            }
        }
    }

}

